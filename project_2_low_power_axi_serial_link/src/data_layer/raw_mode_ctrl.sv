// -----------------------------------------------------------------------
//              RAW MODE CONTROL
//
// TODO: Does not work currently
//
// Author: Filippo Christen
// Date: 18.07.2025
//
// Note:
// - LSFR data is transmitted as AR frame over serial link.
// - Once raw_en is asserted, the whole test sequence will play through
//   even if raw_en deasserts. This causes no issues as raw signals are
//   automatically decoupled in data link layer when raw_en is deasserted.
//
// Function:
// - Allows for direct feeding of byte sized data in compatible format.
//
// -----------------------------------------------------------------------

module raw_mode_ctrl #(
    parameter logic [7:0] TX_LSFR_SEED,
    parameter logic [7:0] RX_LSFR_SEED,
    parameter int unsigned AR_BIT, 
    parameter logic [2:0] AR_HEADER
)(
    input logic clk_i,
    input logic rst_ni,

    input logic raw_en_i, 
    input logic raw_transmit_i,

    // RAW input (from serial link)
    input logic [7:0] raw_data_i,
    input logic raw_valid_i,
    output logic raw_ready_o,
    // RAW output (to serial link)
    output logic [7:0] raw_data_o,
    output logic raw_valid_o,
    input logic raw_ready_i,

    // Evaluation
    output logic [7:0] tx_byte_count_o,
    output logic [7:0] rx_byte_count_o,
    output logic [7:0] errors_o,

    // Configuration
    input logic [7:0] cfg_raw_test_length
);

// LOCAL PARAMETERS
localparam int unsigned AR_BYTE = ((AR_BIT + 7) / 8); 

// INTERNAL WIRES
logic tx_lfsr_en, rx_lfsr_en;
logic [7:0] tx_raw_data, rx_raw_data;

// TX LOGIC
typedef enum {
    Tx_Idle,
    Tx_Header,
    Tx_Data
} tx_state_e;

tx_state_e tx_state_q, tx_state_d;

logic [7:0] tx_byte_count_d; // How many RAW bytes are transmitted
logic [$clog2(AR_BYTE):0] tx_count_d, tx_count_q; // How many bytes of AR frame are transmitted

always_comb begin
    // Default assignments
    raw_valid_o = '0;
    tx_lfsr_en = '0;
    raw_data_o = '0;
    tx_byte_count_d = '0;
    tx_count_d = '0;
    tx_state_d = tx_state_q;

    unique case (tx_state_q)
        Tx_Idle: begin
            if (raw_en_i && raw_transmit_i) begin 
                tx_state_d = Tx_Header;
            end
        end 

        Tx_Header: begin
            tx_byte_count_d = tx_byte_count_o;
            raw_valid_o = 1'b1;
            if (raw_ready_i) begin
                raw_data_o = {AR_HEADER, 5'b00000};
                tx_state_d = Tx_Data;
            end
        end 

        Tx_Data: begin
            raw_valid_o = 1'b1;
            if (raw_ready_i) begin
                tx_lfsr_en = 1'b1;
                raw_data_o = tx_raw_data;
                tx_byte_count_d = tx_byte_count_o + 1;
                tx_count_d = tx_count_q + 1;
            end else begin
                tx_byte_count_d = tx_byte_count_o;
                tx_count_d = tx_count_q;
            end

            if (tx_byte_count_o == cfg_raw_test_length) begin
                tx_state_d = Tx_Idle;
            end else if (tx_count_d == AR_BYTE-1) begin
                tx_state_d = Tx_Header;
            end
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        tx_state_q <= Tx_Idle;
        tx_byte_count_o <= '0;
        tx_count_q <= '0;
    end else begin
        tx_state_q <= tx_state_d;
        tx_byte_count_o <= tx_byte_count_d;
        tx_count_q <= tx_count_d;
    end
end

// RX LOGIC
typedef enum {
    Rx_Idle,
    Rx_Header,
    Rx_Data
} rx_state_e;

rx_state_e rx_state_q, rx_state_d;

logic [7:0] rx_byte_count_d, errors_d; // How many RAW bytes are received
logic [$clog2(AR_BYTE):0] rx_count_d, rx_count_q; // How many bytes of AR frame are received

always_comb begin
    raw_ready_o = '0;
    errors_d = errors_o;
    rx_lfsr_en = '0;

    rx_byte_count_d = '0;
    rx_count_d = '0;

    rx_state_d = rx_state_q;

    unique case (rx_state_q)
        Rx_Idle: begin
            errors_d = '0;
            if (raw_en_i) begin
                rx_state_d = Rx_Header;
            end
        end

        Rx_Header: begin
            raw_ready_o = 1'b1;
            rx_byte_count_d = rx_byte_count_o;
            if (raw_valid_i && raw_data_i[7:5] == AR_HEADER) begin
                rx_state_d = Rx_Data;
            end
        end

        Rx_Data: begin
            raw_ready_o = 1'b1;
            if (raw_valid_i) begin
                rx_lfsr_en = 1'b1;
                rx_byte_count_d = rx_byte_count_o + 1;
                rx_count_d = rx_count_q + 1;
                if (rx_raw_data != raw_data_i) begin
                    errors_d = errors_o + 1;
                end
            end else begin
                rx_byte_count_d = rx_byte_count_o;
                rx_count_d = rx_count_q;
            end

            if (rx_byte_count_o == cfg_raw_test_length) begin
                rx_state_d = Rx_Idle;
            end else if (rx_count_d == AR_BYTE-1) begin
                rx_state_d = Rx_Header;
            end
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        rx_state_q <= Rx_Idle;
        rx_byte_count_o <= '0;
        errors_o <= '0;
        rx_count_q <= '0;
    end else begin
        rx_state_q <= rx_state_d;
        rx_byte_count_o <= rx_byte_count_d;
        errors_o <= errors_d;
        rx_count_q <= rx_count_d;
    end
end

// INSTANCES
lfsr_8bit #(
    .SEED(TX_LSFR_SEED)
) i_tx_lfsr_8bit (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .en_i(tx_lfsr_en),
    .refill_way_oh(), // Output not needed
    .refill_way_bin(tx_raw_data)
);

lfsr_8bit #(
    .SEED(RX_LSFR_SEED)
) i_rx_lfsr_8bit (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .en_i(rx_lfsr_en),
    .refill_way_oh(), // Output not needed
    .refill_way_bin(rx_raw_data)
);

endmodule