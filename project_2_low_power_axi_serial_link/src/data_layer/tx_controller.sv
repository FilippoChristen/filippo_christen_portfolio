// -----------------------------------------------------------------------
//              TX CONTROLLER
//
// Author: Filippo Christen
// Date: 29.06.2025
//
// Function:
// - Interleave credits into the byte stream.
//
// -----------------------------------------------------------------------

module tx_controller #(
    // AXI parameters
    parameter int unsigned AR_BYTE,
    parameter int unsigned R_BYTE,
    parameter int unsigned AW_BYTE,
    parameter int unsigned W_BYTE,
    parameter int unsigned B_BYTE,
    parameter int unsigned MAX_AXI_BYTE,

    // Data layer
    parameter int unsigned CREDIT_TRANSM_INTERVAL, // Max credit transmission interval in clock cycles
                                                   // Note: Has to be larger than B_BYTE

    // Headers
    parameter logic [2:0] AW_HEADER,
    parameter logic [2:0] W_HEADER,
    parameter logic [2:0] AR_HEADER,
    parameter logic [2:0] R_HEADER,
    parameter logic [2:0] B_HEADER,
    parameter logic [2:0] CREDIT_HEADER1, // Credit packet. No interruption
    parameter logic [2:0] CREDIT_HEADER2 // Credit packet. Communicate interruption
)(
    // Clock & Reset
    input  logic clk_i,
    input  logic rst_ni,

    // Network layer interface signals
    // AXI → Serial
    input logic [7:0] a_data_i,
    input logic a_valid_i,
    output logic a_ready_o,

    // Physical layer interface signals
    // AXI → Serial
    output logic [7:0] s_data_o,
    output logic s_valid_o,
    input  logic s_ready_i,

    // Credit control signals
    // Return C.C.
    input logic [4:0] c_to_transmit_i,
    output logic c_transmitted_o,
    // Avail C.C.
    input logic [7:0] c_avail_i,
    output logic c_consumed_o,

    // --- Configuration ---
    input logic [7:0] cfg_credit_transm_interval,
    input logic [7:0] cfg_credit_transm_threshold
);

// INTERNAL SIGNALS
logic [$clog2(CREDIT_TRANSM_INTERVAL):0] c_count_d, c_count_q;
logic [$clog2(MAX_AXI_BYTE):0] tx_count_d, tx_count_q;
logic [2:0] header_d, header_q;

typedef enum {
    Idle,
    Transmit,
    Interruption
} tx_ctrl_state_e;

tx_ctrl_state_e tx_ctrl_state_q, tx_ctrl_state_d;

logic enough_credits;
assign enough_credits = (c_avail_i >= cfg_credit_transm_interval) ? 1'b1 : 1'b0;

always_comb begin
    // Default assignments
    tx_ctrl_state_d = tx_ctrl_state_q;
    c_count_d = c_count_q;
    tx_count_d = tx_count_q;
    header_d = header_q;

    s_data_o = '0;
    s_valid_o = '0;
    a_ready_o = '0;

    c_transmitted_o = '0;
    c_consumed_o = '0;

    unique case (tx_ctrl_state_q)
        Idle: begin
            if (c_count_q == cfg_credit_transm_interval && c_to_transmit_i >= cfg_credit_transm_threshold) begin
                if (s_ready_i) begin
                    // Transmit credits
                    s_data_o = {CREDIT_HEADER1, c_to_transmit_i};
                    s_valid_o = 1'b1;
                    a_ready_o = '0;
                    c_transmitted_o = 1'b1;
                    c_count_d = 0;
                end else begin
                    // Wakeup TX PHY
                    s_valid_o = 1'b1;
                end
            end else begin
                if (c_count_q == cfg_credit_transm_interval) begin
                    c_count_d = 0;
                end else begin
                    c_count_d = c_count_q + 1;
                end

                if (a_valid_i) begin
                    // Peek header and check if transmission can happen
                    // Note: - Transmission of credits with header
                    if (a_data_i[7:5] == AW_HEADER || a_data_i[7:5] == W_HEADER || a_data_i[7:5] == AR_HEADER || a_data_i[7:5] == R_HEADER) begin
                        if (enough_credits) begin
                            if (s_ready_i) begin
                                s_data_o = {a_data_i[7:5], c_to_transmit_i};
                                s_valid_o = 1'b1;
                                a_ready_o = 1'b1;
                                c_count_d = 0;
                                header_d = a_data_i[7:5];
                                c_transmitted_o = 1'b1;
                                c_consumed_o = 1'b1;
                                tx_ctrl_state_d = Transmit;
                            end else begin
                                // Wakeup TX PHY
                                s_valid_o = 1'b1;
                            end
                        end                        
                    end else if (a_data_i[7:5] == B_HEADER) begin
                        if (c_avail_i >= B_BYTE) begin
                            if (s_ready_i) begin
                                s_data_o = {a_data_i[7:5], c_to_transmit_i};
                                s_valid_o = 1'b1;
                                a_ready_o = 1'b1;
                                c_count_d = 0;
                                header_d = a_data_i[7:5];
                                c_transmitted_o = 1'b1;
                                c_consumed_o = 1'b1;
                                tx_ctrl_state_d = Transmit;
                            end else begin
                                // Wakeup TX PHY
                                s_valid_o = 1'b1;
                            end
                        end
                    end else begin
                        // TODO: add assertion for this illegal state
                    end
                end
            end
        end

        Transmit: begin
            // Note: don't care about s_ready_i as it is assumed to stay high --> NO!! It can change when transmission is starting
            if (s_ready_i) begin
                if (c_count_q == cfg_credit_transm_interval) begin
                    // Check if transmission can happen and transmit credits
                    if (enough_credits) begin
                        s_data_o = {CREDIT_HEADER1, c_to_transmit_i};
                        tx_ctrl_state_d = Transmit;
                    end else begin
                        s_data_o = {CREDIT_HEADER2, c_to_transmit_i};
                        tx_ctrl_state_d = Interruption;
                    end
                    s_valid_o = 1'b1;
                    a_ready_o = '0;
                    c_transmitted_o = 1'b1;
                    c_count_d = 0;
                end else begin
                    // Assumption: data will stay valid
                    s_data_o = a_data_i;
                    s_valid_o = 1'b1;
                    a_ready_o = 1'b1;
                    c_consumed_o = 1'b1;

                    if (header_q == AW_HEADER && tx_count_q == AW_BYTE) begin
                        tx_count_d = 0;
                        c_count_d = 0;
                        tx_ctrl_state_d = Idle;
                    end else if (header_q == W_HEADER && tx_count_q == W_BYTE) begin
                        tx_count_d = 0;
                        c_count_d = 0;
                        tx_ctrl_state_d = Idle;
                    end else if (header_q == AR_HEADER && tx_count_q == AR_BYTE) begin
                        tx_count_d = 0;
                        c_count_d = 0;
                        tx_ctrl_state_d = Idle;
                    end else if (header_q == R_HEADER && tx_count_q == R_BYTE) begin
                        tx_count_d = 0;
                        c_count_d = 0;
                        tx_ctrl_state_d = Idle;
                    end else if (header_q == B_HEADER && tx_count_q == B_BYTE) begin
                        tx_count_d = 0;
                        c_count_d = 0;
                        tx_ctrl_state_d = Idle;
                    end else begin
                        tx_count_d = tx_count_q + 1;
                        c_count_d = c_count_q + 1;
                    end
                end
            end else begin
                // If PHY wrapper not ready
                s_valid_o = 1'b1;
                s_data_o = a_data_i;
            end
        end

        Interruption: begin
            if (enough_credits) begin
                s_data_o = {CREDIT_HEADER1, c_to_transmit_i};
                tx_ctrl_state_d = Transmit;
                s_valid_o = 1'b1;
                a_ready_o = '0;
                c_transmitted_o = 1'b1;
                c_count_d = '0;
            end else begin
                if (c_count_q == cfg_credit_transm_interval) begin
                    c_count_d = '0;
                    if (c_to_transmit_i >= cfg_credit_transm_threshold) begin
                        s_data_o = {CREDIT_HEADER2, c_to_transmit_i};
                        s_valid_o = 1'b1;
                        a_ready_o = '0;
                        c_transmitted_o = 1'b1;
                    end
                end else begin
                    c_count_d = c_count_q + 1;
                end
            end
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        tx_ctrl_state_q <= Idle;
        c_count_q <= 0;
        tx_count_q <= 0;
        header_q <= '0;
    end else begin
        tx_ctrl_state_q <= tx_ctrl_state_d;
        c_count_q <= c_count_d;
        tx_count_q <= tx_count_d;
        header_q <= header_d;
    end
end

endmodule