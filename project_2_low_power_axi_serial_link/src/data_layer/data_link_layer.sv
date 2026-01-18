// -----------------------------------------------------------------------
//              DATA LAYER
//
// Author: Filippo Christen
// Date: 26.06.2025
//
// Function:
// - Convert data into PHY-compatible format and viceversa through 
//   serialization and deserialization.
// - Handle backpressure through a credit-based flow-control.
// - Buffering of data.
//
// -----------------------------------------------------------------------

module data_link_layer #(
    // AXI parameters
    // Bit width of AXI channels
    parameter int unsigned AR_BIT, 
    parameter int unsigned R_BIT,
    parameter int unsigned AW_BIT,
    parameter int unsigned W_BIT,
    parameter int unsigned B_BIT,
    parameter int unsigned MAX_AXI_BIT,

    // FIFO & CDC parameters 
    // Note: FIFO depth given as 2**DEPTH.
    parameter int unsigned TX_FIFO_DEPTH,
    parameter int unsigned TX_CDC_DEPTH,
    parameter int unsigned RX_FIFO_DEPTH,
    parameter int unsigned RX_CDC_DEPTH,

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
    // Clocks & Reset
    input  logic clk_i,
    input  logic clk_tx_i,
    input  logic clk_rx_i,
    input  logic rst_ni,

    // Network layer interface signals
    // AXI → Serial
    input logic [MAX_AXI_BIT-1:0] a_data_i,
    input logic [2:0] a_header_i,
    input logic a_valid_i,
    output logic a_ready_o,
    // Serial → AXI
    output logic [MAX_AXI_BIT-1:0] a_data_o,
    output logic [2:0] a_header_o,
    output logic a_valid_o,
    input logic a_ready_i,

    // Physical layer interface signals
    // AXI → Serial
    output logic [7:0] s_data_o,
    output logic s_valid_o,
    input  logic s_ready_i,
    // Serial → AXI
    input  logic [7:0] s_data_i,
    input  logic s_valid_i,
    output logic s_ready_o,

    // RAW MODE
    input logic raw_en_i, 
    // RAW input
    input logic [7:0] raw_data_i,
    input logic raw_valid_i,
    output logic raw_ready_o,
    // RAW output
    output logic [7:0] raw_data_o,
    output logic raw_valid_o,
    input logic raw_ready_i,

    // Configuration
    input logic [7:0] cfg_credit_initial_amount, 
    input logic [7:0] cfg_credit_transm_interval,
    input logic [7:0] cfg_credit_transm_threshold
);

// LOCAL PARAMETERS
localparam int unsigned MAX_AXI_BYTE = ((MAX_AXI_BIT + 7) / 8);
localparam int unsigned AR_BYTE = ((AR_BIT + 7) / 8); 
localparam int unsigned R_BYTE = ((R_BIT + 7) / 8);
localparam int unsigned AW_BYTE = ((AW_BIT + 7) / 8);
localparam int unsigned W_BYTE = ((W_BIT + 7) / 8);
localparam int unsigned B_BYTE = ((B_BIT + 7) / 8);

// INTERNAL SIGNALS

// AXI --> Serial (TX pipeline)
// 1 is pre FIFO buffer, 2 is after, 3 is after TX ctrl
// Note: a and b are for the RAW bypass
logic [7:0] a_data_ser1a, a_data_ser1b, a_data_ser2, a_data_ser3;
logic a_valid_ser1a, a_valid_ser1b, a_valid_ser2, a_valid_ser3;
logic a_ready_ser1a, a_ready_ser1b, a_ready_ser2, a_ready_ser3;

// Serial --> AXI (RX pipeline)
// 1 is post FIFO buffer, 2 is before, 3 is before RX ctrl
// Note: a and b are for the RAW bypass
logic [7:0] s_data_ser1a, s_data_ser1b, s_data_ser2, s_data_ser3; 
logic s_valid_ser1a, s_valid_ser1b, s_valid_ser2, s_valid_ser3; 
logic s_ready_ser1a, s_ready_ser1b, s_ready_ser2, s_ready_ser3; 

// Control signals
logic c_released; // Data released from RX FIFO (basically successful HS)
logic c_transmitted; // Credit transmitted
logic [4:0] c_to_transmit, c_received; // Up to 2**5 = 32
logic [7:0] c_avail; // Up to 2**8 = 256
logic c_consumed;


// AVAILABLE CREDIT CONTROL
// Inputs: c_received, c_consumed
// Outputs: c_avail

logic [7:0] c_avail_amount_q, c_avail_amount_d;
assign c_avail = c_avail_amount_q;

always_comb begin
    // Update available credits
    // Note: always add c_received. If none received c_received = '0
    if (c_consumed) begin
        c_avail_amount_d = c_avail_amount_q + c_received - 1'b1;
    end else begin
        c_avail_amount_d = c_avail_amount_q + c_received;
    end
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        c_avail_amount_q <= cfg_credit_initial_amount;
    end else begin
        c_avail_amount_q <= c_avail_amount_d;
    end
end


// RETURN CREDIT CONTROL
// Inputs: c_released, c_transmitted
// Outputs: c_to_transmit

logic [7:0] c_to_transmit_amount_q, c_to_transmit_amount_d;

always_comb begin
    c_to_transmit = c_to_transmit_amount_q;

    if (c_released) begin
        if (c_transmitted) begin
            c_to_transmit_amount_d = 8'b1;
        end else begin
            c_to_transmit_amount_d = c_to_transmit_amount_q + 8'b1;
        end
    end else begin
        if (c_transmitted) begin
            c_to_transmit_amount_d = '0;
        end else begin
            c_to_transmit_amount_d = c_to_transmit_amount_q;
        end
    end
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        c_to_transmit_amount_q <= '0;
    end else begin
        c_to_transmit_amount_q <= c_to_transmit_amount_d;
    end
end

// Credit release checker
assign c_released = s_ready_ser1b & s_valid_ser1b;

// INSTANCES
// Serializer
serializer #(
    // AXI parameters
    .MAX_AXI_BIT(MAX_AXI_BIT),
    .AR_BYTE(AR_BYTE),
    .R_BYTE(R_BYTE),
    .AW_BYTE(AW_BYTE),
    .W_BYTE(W_BYTE),
    .B_BYTE(B_BYTE),
    .MAX_AXI_BYTE(MAX_AXI_BYTE),

    // Headers
    .AW_HEADER(AW_HEADER),
    .W_HEADER(W_HEADER),
    .AR_HEADER(AR_HEADER),
    .R_HEADER(R_HEADER),
    .B_HEADER(B_HEADER)
) i_serializer (
    // Clock & Reset
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    // Network layer interface signals
    // AXI → Serial
    .a_data_i(a_data_i),
    .a_header_i(a_header_i),
    .a_valid_i(a_valid_i),
    .a_ready_o(a_ready_o),

    // FIFO buffer interface signals
    // AXI → Serial
    .s_data_o(a_data_ser1a),
    .s_valid_o(a_valid_ser1a),
    .s_ready_i(a_ready_ser1a)
); 


// TX FIFO
logic tx_fifo_full, tx_fifo_empty;
assign a_ready_ser1b = !tx_fifo_full;
assign a_valid_ser2 = !tx_fifo_empty;

// Prevent illegal assertions
logic tx_fifo_push, tx_fifo_pop;
assign tx_fifo_push = a_valid_ser1b && !tx_fifo_full;
assign tx_fifo_pop = a_ready_ser2 && !tx_fifo_empty;

fifo_v3 #(
    .FALL_THROUGH(0), // fifo is in fall-through mode
    .DATA_WIDTH(8), // default data width if the fifo is of type logic
    .DEPTH(TX_FIFO_DEPTH) // depth can be arbitrary from 0 to 2**32
) i_tx_fifo (
    .clk_i(clk_i), // Clock
    .rst_ni(rst_ni), // Asynchronous reset active low
    .flush_i('0), // flush the queue
    .testmode_i('0), // test_mode to bypass clock gating
    // status flags
    .full_o(tx_fifo_full), // queue is full
    .empty_o(tx_fifo_empty), // queue is empty
    .usage_o(), // fill pointer
    // as long as the queue is not full we can push new data
    .data_i(a_data_ser1b), // data to push into the queue
    .push_i(tx_fifo_push), // data is valid and can be pushed to the queue
    // as long as the queue is not empty we can pop new elements
    .data_o(a_data_ser2), // output data
    .pop_i(tx_fifo_pop) // pop head from queue
);


// TX CONTROL
tx_controller #(
    // AXI parameters
    .AR_BYTE(AR_BYTE),
    .R_BYTE(R_BYTE),
    .AW_BYTE(AW_BYTE),
    .W_BYTE(W_BYTE),
    .B_BYTE(B_BYTE),
    .MAX_AXI_BYTE(MAX_AXI_BYTE),

    // Data layer
    .CREDIT_TRANSM_INTERVAL(CREDIT_TRANSM_INTERVAL), // Max credit transmission interval in clock cycles
                              // Note: Has to be larger than B_BYTE_WIDTH

    // Headers
    .AW_HEADER(AW_HEADER),
    .W_HEADER(W_HEADER),
    .AR_HEADER(AR_HEADER),
    .R_HEADER(R_HEADER),
    .B_HEADER(B_HEADER),
    .CREDIT_HEADER1(CREDIT_HEADER1), // Credit packet. No interruption
    .CREDIT_HEADER2(CREDIT_HEADER2) // Credit packet. Communicate interruption
) i_tx_controller (
    // Clock & Reset
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    // Network layer interface signals
    // AXI → Serial
    .a_data_i(a_data_ser2),
    .a_valid_i(a_valid_ser2),
    .a_ready_o(a_ready_ser2),

    // Physical layer interface signals
    // AXI → Serial
    .s_data_o(a_data_ser3),
    .s_valid_o(a_valid_ser3),
    .s_ready_i(a_ready_ser3),

    // Credit control signals
    // Return C.C.
    .c_to_transmit_i(c_to_transmit),
    .c_transmitted_o(c_transmitted),
    // Avail C.C.
    .c_avail_i(c_avail),
    .c_consumed_o(c_consumed),

    // --- Configuration ---
    .cfg_credit_transm_interval(cfg_credit_transm_interval),
    .cfg_credit_transm_threshold(cfg_credit_transm_threshold)
);


// TX CDC
cdc_fifo_gray #(
    .WIDTH(8),// The width of the default logic type.
    .LOG_DEPTH(TX_CDC_DEPTH), // The FIFO's depth given as 2**LOG_DEPTH.
    .SYNC_STAGES(2) // The number of synchronization registers to insert on the async pointers.
) i_tx_cdc_fifo (
    .src_rst_ni(rst_ni),
    .src_clk_i(clk_i),
    .src_data_i(a_data_ser3),
    .src_valid_i(a_valid_ser3),
    .src_ready_o(a_ready_ser3),

    .dst_rst_ni(rst_ni),
    .dst_clk_i(clk_tx_i),
    .dst_data_o(s_data_o),
    .dst_valid_o(s_valid_o),
    .dst_ready_i(s_ready_i)
);


// RX CDC
cdc_fifo_gray #(
    .WIDTH(8), // The width of the default logic type.
    .LOG_DEPTH(RX_CDC_DEPTH), // The FIFO's depth given as 2**LOG_DEPTH.
    .SYNC_STAGES(2) // The number of synchronization registers to insert on the async pointers.
) i_rx_cdc_fifo (
    .src_rst_ni(rst_ni),
    .src_clk_i(clk_rx_i),
    .src_data_i(s_data_i),
    .src_valid_i(s_valid_i),
    .src_ready_o(s_ready_o),

    .dst_rst_ni(rst_ni),
    .dst_clk_i(clk_i),
    .dst_data_o(s_data_ser3),
    .dst_valid_o(s_valid_ser3),
    .dst_ready_i(s_ready_ser3)
);


// RX CONTROL
rx_controller #(
    // AXI parameters
    .AR_BYTE(AR_BYTE),
    .R_BYTE(R_BYTE),
    .AW_BYTE(AW_BYTE),
    .W_BYTE(W_BYTE),
    .B_BYTE(B_BYTE),
    .MAX_AXI_BYTE(MAX_AXI_BYTE),

    // Data layer
    .CREDIT_TRANSM_INTERVAL(CREDIT_TRANSM_INTERVAL), // Max credit transmission interval in clock cycles
                              // Note: Has to be larger than B_BYTE_WIDTH

    // Headers
    .AW_HEADER(AW_HEADER),
    .W_HEADER(W_HEADER),
    .AR_HEADER(AR_HEADER),
    .R_HEADER(R_HEADER),
    .B_HEADER(B_HEADER),
    .CREDIT_HEADER1(CREDIT_HEADER1), // Credit packet. No interruption
    .CREDIT_HEADER2(CREDIT_HEADER2) // Credit packet. Communicate interruption
) i_rx_controller (
    // Clock & Reset
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    // Physical layer interface signals
    // Serial → AXI
    .s_data_i(s_data_ser3),
    .s_valid_i(s_valid_ser3),
    .s_ready_o(s_ready_ser3),

    // Network layer interface signals
    // Serial → AXI
    .a_data_o(s_data_ser2),
    .a_valid_o(s_valid_ser2),
    .a_ready_i(s_ready_ser2),

    // Credit control signals
    .c_received_o(c_received),

    // --- Configuration ---
    .cfg_credit_transm_interval(cfg_credit_transm_interval)
);


// RX FIFO
logic rx_fifo_full, rx_fifo_empty;
assign s_ready_ser2 = !rx_fifo_full;
assign s_valid_ser1b = !rx_fifo_empty;

// Prevent illegal assertions
logic rx_fifo_push, rx_fifo_pop;
assign rx_fifo_push = s_valid_ser2 && !rx_fifo_full;
assign rx_fifo_pop = s_ready_ser1b && !rx_fifo_empty;
fifo_v3 #(
    .FALL_THROUGH(0), // fifo is in fall-through mode
    .DATA_WIDTH(8), // default data width if the fifo is of type logic
    .DEPTH(RX_FIFO_DEPTH) // depth can be arbitrary from 0 to 2**32
) i_rx_fifo (
    .clk_i(clk_i), // Clock
    .rst_ni(rst_ni), // Asynchronous reset active low
    .flush_i('0), // flush the queue
    .testmode_i('0), // test_mode to bypass clock gating
    // status flags
    .full_o(rx_fifo_full), // queue is full
    .empty_o(rx_fifo_empty), // queue is empty
    .usage_o(), // fill pointer
    // as long as the queue is not full we can push new data
    .data_i(s_data_ser2), // data to push into the queue
    .push_i(rx_fifo_push), // data is valid and can be pushed to the queue
    // as long as the queue is not empty we can pop new elements
    .data_o(s_data_ser1b), // output data
    .pop_i(rx_fifo_pop) // pop head from queue
);


// Deserializer
deserializer #(
    // AXI parameters
    .MAX_AXI_BIT(MAX_AXI_BIT),
    .AR_BYTE(AR_BYTE),
    .R_BYTE(R_BYTE),
    .AW_BYTE(AW_BYTE),
    .W_BYTE(W_BYTE),
    .B_BYTE(B_BYTE),
    .MAX_AXI_BYTE(MAX_AXI_BYTE),

    // Headers
    .AW_HEADER(AW_HEADER),
    .W_HEADER(W_HEADER),
    .AR_HEADER(AR_HEADER),
    .R_HEADER(R_HEADER),
    .B_HEADER(B_HEADER)
) i_deserializer (
    // Clock & Reset
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    // Network layer interface signals
    // Serial → AXI
    .a_data_o(a_data_o),
    .a_header_o(a_header_o),
    .a_valid_o(a_valid_o),
    .a_ready_i(a_ready_i),

    // FIFO buffer interface signals
    // Serial → AXI
    .s_data_i(s_data_ser1a),
    .s_valid_i(s_valid_ser1a),
    .s_ready_o(s_ready_ser1a)
); 


// RAW mode: TODO: For now it does not work so it is deactivated
always_comb begin
    if (raw_en_i) begin
        // Input
        a_data_ser1b = raw_data_i;
        a_valid_ser1b = raw_valid_i;
        raw_ready_o = a_ready_ser1b; 
        // Output
        raw_data_o = s_data_ser1b;
        raw_valid_o = s_valid_ser1b;
        s_ready_ser1b = raw_ready_i;
        // Unused output
        s_data_ser1a = '0;
        s_valid_ser1a = '0;

    end else begin
        // Input
        a_data_ser1b = a_data_ser1a;
        a_valid_ser1b = a_valid_ser1a;
        a_ready_ser1a = a_ready_ser1b;
        // Output
        s_data_ser1a = s_data_ser1b;
        s_valid_ser1a = s_valid_ser1b;
        s_ready_ser1b = s_ready_ser1a;
        // Unused output
        s_data_ser1a = '0;
        s_valid_ser1a = '0;
    end
end


// DEBUG CODE
// AXI --> Serial
/*
always_ff @(posedge clk_i) begin
  if (a_valid_i && a_ready_o) begin
    $display("[%0t] AXI to Serial: header=0x%0x, data=0x%0h", $time, a_header_i, a_data_i);
  end
end
//Serial --> AXI
always_ff @(posedge clk_i) begin
  if (a_valid_o && a_ready_i) begin
    $display("[%0t] Serial to AXI: header=0x%0x, data=0x%0h", $time, a_header_o, a_data_o);
  end
end
*/

endmodule
