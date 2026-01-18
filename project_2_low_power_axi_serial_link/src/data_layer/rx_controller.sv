// -----------------------------------------------------------------------
//              RX CONTROLLER
//
// Author: Filippo Christen
// Date: 29.06.2025
//
// Function:
// - Extract credits from the byte stream.
// - Delete ignore data.
//
// -----------------------------------------------------------------------


module rx_controller #(
    // AXI parameters
    parameter int unsigned AR_BYTE,
    parameter int unsigned R_BYTE,
    parameter int unsigned AW_BYTE,
    parameter int unsigned W_BYTE,
    parameter int unsigned B_BYTE,
    parameter int unsigned MAX_AXI_BYTE,

    // Data layer
    parameter int unsigned CREDIT_TRANSM_INTERVAL, // Max credit transmission interval in clock cycles

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

    // Physical layer interface signals
    // Serial → AXI
    input  logic [7:0] s_data_i,
    input  logic s_valid_i,
    output logic s_ready_o,

    // Network layer interface signals
    // Serial → AXI
    output logic [7:0] a_data_o,
    output logic a_valid_o,
    input logic a_ready_i,

    // Credit control signals
    output logic [4:0] c_received_o,

    // --- Configuration ---
    input logic [7:0] cfg_credit_transm_interval
);

// INTERNAL SIGNALS
logic [$clog2(CREDIT_TRANSM_INTERVAL):0] c_count_d, c_count_q;
logic [$clog2(MAX_AXI_BYTE):0] rx_count_d, rx_count_q;
logic [2:0] header_d, header_q;

typedef enum {
    Idle,
    Receive,
    Interruption
} rx_ctrl_state_e;

rx_ctrl_state_e rx_ctrl_state_q, rx_ctrl_state_d;

// Inputs: s_data_i, s_valid_i, a_ready_i
always_comb begin
    // Default assignments
    rx_ctrl_state_d = rx_ctrl_state_q;
    c_count_d = c_count_q;
    rx_count_d = rx_count_q;
    header_d = header_q;

    a_data_o = '0;
    a_valid_o = '0;
    s_ready_o = 1'b1; // Note: a_ready_i is assumed never cause problems due to credit based flow control
    c_received_o = '0;

    unique case (rx_ctrl_state_q)
        Idle: begin
            if (s_valid_i) begin
                if (s_data_i[7:5] == AW_HEADER || s_data_i[7:5] == W_HEADER || s_data_i[7:5] == AR_HEADER || s_data_i[7:5] == R_HEADER || s_data_i[7:5] == B_HEADER) begin
                    // Extract credits and pass header along to the FIFO
                    c_received_o = s_data_i[4:0];
                    a_data_o = {s_data_i[7:5], 5'b00000};
                    a_valid_o = 1'b1;
                    header_d = s_data_i[7:5];
                    rx_ctrl_state_d = Receive;
                end else if (s_data_i[7:5] == CREDIT_HEADER1) begin
                    c_received_o = s_data_i[4:0];
                end
            end
        end

        Receive: begin
            if (s_valid_i) begin
                if (c_count_q == cfg_credit_transm_interval) begin
                    c_received_o = s_data_i[4:0];
                    c_count_d = 0;

                    // Check if there is interruption
                    if (s_data_i[7:5] == CREDIT_HEADER2) begin
                        rx_ctrl_state_d = Interruption;
                    end else if (s_data_i[7:5] != CREDIT_HEADER1) begin
                        // DEBUG
                        $display("ERROR: Credit expected at receiver but received header = %b at time %t", s_data_i[7:5], $time);
                    end
                end else begin
                    a_data_o = s_data_i;
                    a_valid_o = 1'b1;

                    if (header_q == AW_HEADER && rx_count_q == AW_BYTE) begin
                        rx_count_d = 0;
                        c_count_d = 0;
                        rx_ctrl_state_d = Idle;
                    end else if (header_q == W_HEADER && rx_count_q == W_BYTE) begin
                        rx_count_d = 0;
                        c_count_d = 0;
                        rx_ctrl_state_d = Idle;
                    end else if (header_q == AR_HEADER && rx_count_q == AR_BYTE) begin
                        rx_count_d = 0;
                        c_count_d = 0;
                        rx_ctrl_state_d = Idle;
                    end else if (header_q == R_HEADER && rx_count_q == R_BYTE) begin
                        rx_count_d = 0;
                        c_count_d = 0;
                        rx_ctrl_state_d = Idle;
                    end else if (header_q == B_HEADER && rx_count_q == B_BYTE) begin
                        rx_count_d = 0;
                        c_count_d = 0;
                        rx_ctrl_state_d = Idle;
                    end else begin
                        rx_count_d = rx_count_q + 1;
                        c_count_d = c_count_q + 1;
                    end
                end
            end
        end

        Interruption: begin
            if (s_valid_i) begin
                if (s_data_i[7:5] == CREDIT_HEADER1) begin
                    c_received_o = s_data_i[4:0];
                    rx_ctrl_state_d = Receive;
                end else if (s_data_i[7:5] == CREDIT_HEADER2) begin
                    c_received_o = s_data_i[4:0];
                end else begin
                    // Invalid state
                end
            end
        end       
    endcase
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        rx_ctrl_state_q <= Idle;
        c_count_q <= 0;
        rx_count_q <= 0;
        header_q <= '0;
    end else begin
        rx_ctrl_state_q <= rx_ctrl_state_d;
        c_count_q <= c_count_d;
        rx_count_q <= rx_count_d;
        header_q <= header_d;
    end
end

endmodule