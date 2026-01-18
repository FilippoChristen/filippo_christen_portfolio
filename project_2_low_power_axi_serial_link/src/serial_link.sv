// -----------------------------------------------------------------------
//              SERIAL LINK
//
// Author: Filippo Christen
// Date: 03.07.2025
//
// -----------------------------------------------------------------------

module serial_link #(
    // AXI
    parameter type axi_req_t = logic,
    parameter type axi_rsp_t = logic,

    // Bit width of AXI channels
    parameter int unsigned AR_BIT, 
    parameter int unsigned R_BIT,
    parameter int unsigned AW_BIT,
    parameter int unsigned W_BIT,
    parameter int unsigned B_BIT,
    parameter int unsigned MAX_AXI_BIT,

    // Headers
    parameter logic [2:0] AW_HEADER,
    parameter logic [2:0] W_HEADER,
    parameter logic [2:0] AR_HEADER,
    parameter logic [2:0] R_HEADER,
    parameter logic [2:0] B_HEADER,
    parameter logic [2:0] CREDIT_HEADER1, // Credit packet. No interruption
    parameter logic [2:0] CREDIT_HEADER2, // Credit packet. Communicate interruption

    // FIFO & CDC parameters 
    // Note: FIFO depth given as 2**DEPTH.
    parameter int unsigned TX_FIFO_DEPTH,
    parameter int unsigned TX_CDC_DEPTH,
    parameter int unsigned RX_FIFO_DEPTH,
    parameter int unsigned RX_CDC_DEPTH,

    // Credits
    parameter int unsigned CREDIT_TRANSM_INTERVAL, // Max credit transmission interval in clock cycles

    // PHY wrapper
    // Tx
    parameter int unsigned MAX_STABILITY,
    parameter int unsigned MAX_TX_PHY_WARMUP,
    parameter int unsigned MAX_SYNCH1,
    parameter int unsigned MAX_SYNCH3,
    parameter int unsigned MAX_IDLE,
    parameter int unsigned MAX_PRE_CYCLES,
    parameter int unsigned MAX_POST_CYCLES,
    parameter int unsigned MAX_TO_IDLE,

    // Rx
    parameter int unsigned MAX_RX_PAUSE1,
    parameter int unsigned MAX_RX_PHY_WARMUP,
    parameter int unsigned MAX_RX_PAUSE2,

    // RAW MODE
    parameter logic [7:0] TX_LSFR_SEED,
    parameter logic [7:0] RX_LSFR_SEED
) (
    // Clock & Reset
    input logic clk_i,
    input logic rst_ni,

    // AXI interface signals
    // 1 --> 2
    input axi_req_t  axi_in_req_i,
    output axi_rsp_t  axi_in_rsp_o,
    // 2 --> 1
    output axi_req_t  axi_out_req_o,
    input axi_rsp_t  axi_out_rsp_i,

    // Serial transmission
    output logic s_data_o,
    output logic s_clk_o,
    output logic stable_o,
    input logic s_data_i,
    input logic s_clk_i,
    input logic stable_i,

    // RAW MODE
    input logic raw_en_i,
    input logic raw_transmit_i,
    // Evaluation
    output logic [7:0] tx_byte_count_o,
    output logic [7:0] rx_byte_count_o,
    output logic [7:0] errors_o,

    // Configuration
    input logic [7:0] cfg_credit_initial_amount,
    input logic [7:0] cfg_credit_transm_interval,
    input logic [7:0] cfg_credit_transm_threshold,

    // Tx 
    input logic [40:0] cfg_stability,
    input logic [40:0] cfg_tx_phy_warmup,  
    input logic [40:0] cfg_synch1,
    input logic [40:0] cfg_synch3,
    input logic [40:0] cfg_idle,
    input logic [40:0] cfg_pre_cycles,
    input logic [40:0] cfg_post_cycles, // NOTE: actual number of cycles will be one more
    input logic [40:0] cfg_to_idle,

    // Rx
    input logic [40:0] cfg_rx_pause1,
    input logic [40:0] cfg_rx_phy_warmup,
    input logic [40:0] cfg_rx_pause2,

    // RAW mode
    input logic [7:0] cfg_raw_test_length,

    // SIMULATION
    input logic sim_rst_tx_phy_ni,
    input logic sim_rst_rx_phy_ni,

    input logic sim_tx_pll_ready
);


// INTERNAL SIGNALS
// Note: - n2d = Network layer to Data link layer
//       - d2p = Data link layer to PHY wrapper
// AXI --> Serial
logic [MAX_AXI_BIT-1:0] a_n2d_data;
logic [2:0] a_n2d_header;
logic a_n2d_valid, a_n2d_ready;
logic [7:0] a_d2p_data;
logic a_d2p_valid, a_d2p_ready;

// Serial --> AXI
logic [MAX_AXI_BIT-1:0] s_d2n_data;
logic [2:0] s_d2n_header;
logic s_d2n_valid, s_d2n_ready;
logic [7:0] s_p2d_data;
logic s_p2d_valid, s_p2d_ready;

// General
logic tx_clk, rx_clk;
logic [7:0] raw_data_o, raw_data_i;
logic raw_valid_o, raw_ready_i, raw_valid_i, raw_ready_o;

// INSTANCES

nw_layer #(
    // AXI stuff
    .axi_req_t(axi_req_t),
    .axi_rsp_t(axi_rsp_t),

    // Bit width of AXI channels
    .AR_BIT(AR_BIT), 
    .R_BIT(R_BIT),
    .AW_BIT(AW_BIT),
    .W_BIT(W_BIT),
    .B_BIT(B_BIT),
    .MAX_AXI_BIT(MAX_AXI_BIT),

    // Headers
    .AW_HEADER(AW_HEADER),
    .W_HEADER(W_HEADER),
    .AR_HEADER(AR_HEADER),
    .R_HEADER(R_HEADER),
    .B_HEADER(B_HEADER)
) i_nw_layer (
    // Clock & Reset
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    // AXI interface signals
    // 1 --> 2
    .axi_in_req_i(axi_in_req_i),
    .axi_in_rsp_o(axi_in_rsp_o),
    // 2 --> 1
    .axi_out_req_o(axi_out_req_o),
    .axi_out_rsp_i(axi_out_rsp_i),

    // NW layer interface signals
    // AXI → Serial
    .a_data_o(a_n2d_data),
    .a_header_o(a_n2d_header),
    .a_valid_o(a_n2d_valid),
    .a_ready_i(a_n2d_ready),
    // Serial → AXI
    .s_data_i(s_d2n_data),
    .s_header_i(s_d2n_header),
    .s_valid_i(s_d2n_valid),
    .s_ready_o(s_d2n_ready)
);


data_link_layer #(
    // AXI parameters
    // Bit width of AXI channels
    .AR_BIT(AR_BIT), 
    .R_BIT(R_BIT),
    .AW_BIT(AW_BIT),
    .W_BIT(W_BIT),
    .B_BIT(B_BIT),
    .MAX_AXI_BIT(MAX_AXI_BIT),

    // FIFO & CDC parameters 
    // Note: FIFO depth given as 2**DEPTH.
    .TX_FIFO_DEPTH(TX_FIFO_DEPTH),
    .TX_CDC_DEPTH(TX_CDC_DEPTH),
    .RX_FIFO_DEPTH(RX_FIFO_DEPTH),
    .RX_CDC_DEPTH(RX_CDC_DEPTH),

    // Data layer
    .CREDIT_TRANSM_INTERVAL(CREDIT_TRANSM_INTERVAL), // Max credit transmission interval in clock cycles

    // Headers
    .AW_HEADER(AW_HEADER),
    .W_HEADER(W_HEADER),
    .AR_HEADER(AR_HEADER),
    .R_HEADER(R_HEADER),
    .B_HEADER(B_HEADER),
    .CREDIT_HEADER1(CREDIT_HEADER1), // Credit packet. No interruption
    .CREDIT_HEADER2(CREDIT_HEADER2) // Credit packet. Communicate interruption
) i_data_link_layer (
    // Clocks & Reset
    .clk_i(clk_i),
    .clk_tx_i(tx_clk),
    .clk_rx_i(rx_clk),
    .rst_ni(rst_ni),

    // Network layer interface signals
    // AXI → Serial
    .a_data_i(a_n2d_data),
    .a_header_i(a_n2d_header),
    .a_valid_i(a_n2d_valid),
    .a_ready_o(a_n2d_ready),
    // Serial → AXI
    .a_data_o(s_d2n_data),
    .a_header_o(s_d2n_header),
    .a_valid_o(s_d2n_valid),
    .a_ready_i(s_d2n_ready),

    // Physical layer interface signals
    // AXI → Serial
    .s_data_o(a_d2p_data),
    .s_valid_o(a_d2p_valid),
    .s_ready_i(a_d2p_ready),
    // Serial → AXI
    .s_data_i(s_p2d_data),
    .s_valid_i(s_p2d_valid),
    .s_ready_o(s_p2d_ready),

    // RAW MODE
    .raw_en_i(raw_en_i), 
    // RAW input
    .raw_data_i(raw_data_o),
    .raw_valid_i(raw_valid_o),
    .raw_ready_o(raw_ready_i),
    // RAW output
    .raw_data_o(raw_data_i),
    .raw_valid_o(raw_valid_i),
    .raw_ready_i(raw_ready_o),

    // Configuration
    .cfg_credit_initial_amount(cfg_credit_initial_amount),
    .cfg_credit_transm_interval(cfg_credit_transm_interval),
    .cfg_credit_transm_threshold(cfg_credit_transm_threshold)
);


phy_wrapper #(
    // Control
    // Tx
    .MAX_STABILITY(MAX_STABILITY),
    .MAX_TX_PHY_WARMUP(MAX_TX_PHY_WARMUP),
    .MAX_SYNCH1(MAX_SYNCH1),
    .MAX_SYNCH3(MAX_SYNCH3),
    .MAX_IDLE(MAX_IDLE),
    .MAX_PRE_CYCLES(MAX_PRE_CYCLES),
    .MAX_POST_CYCLES(MAX_POST_CYCLES),
    .MAX_TO_IDLE(MAX_TO_IDLE),

    // Rx
    .MAX_RX_PAUSE1(MAX_RX_PAUSE1),
    .MAX_RX_PHY_WARMUP(MAX_RX_PHY_WARMUP),
    .MAX_RX_PAUSE2(MAX_RX_PAUSE2)
) i_phy_wrapper (
    // GENERAL
    .clk_tx_o(tx_clk),
    .clk_rx_o(rx_clk),
    .rst_ni(rst_ni),

    // AXI SIDE
    // AXI --> Serial
    .a_data_i(a_d2p_data),
    .a_valid_i(a_d2p_valid),
    .a_ready_o(a_d2p_ready),

    // Serial --> AXI
    .s_data_o(s_p2d_data),
    .s_valid_o(s_p2d_valid),
    .s_ready_i(s_p2d_ready), // Unused at the moment

    // SERIAL SIDE
    // AXI --> Serial
    .tx_serial_data_o(s_data_o),
    .tx_serial_clk_fwd_o(s_clk_o),
    .stable_o(stable_o),

    // Serial --> AXI
    .rx_serial_data_i(s_data_i),
    .rx_serial_clk_fwd_i(s_clk_i),
    .stable_i(stable_i),

    // CONFIGURATION
    // Tx 
    .cfg_stability(cfg_stability),
    .cfg_tx_phy_warmup(cfg_tx_phy_warmup),  
    .cfg_synch1(cfg_synch1),
    .cfg_synch3(cfg_synch3),
    .cfg_idle(cfg_idle),
    .cfg_pre_cycles(cfg_pre_cycles), 
    .cfg_post_cycles(cfg_post_cycles), // NOTE: actual number of cycles will be one more
    .cfg_to_idle(cfg_to_idle),
    // Rx
    .cfg_rx_pause1(cfg_rx_pause1),
    .cfg_rx_phy_warmup(cfg_rx_phy_warmup),
    .cfg_rx_pause2(cfg_rx_pause2),

    // SIMULATION
    .sim_rst_tx_phy_ni(sim_rst_tx_phy_ni),
    .sim_rst_rx_phy_ni(sim_rst_rx_phy_ni),
    .sim_tx_pll_ready(sim_tx_pll_ready)
);

// RAW mode TODO: does not work for now
raw_mode_ctrl #(
    .TX_LSFR_SEED(TX_LSFR_SEED),
    .RX_LSFR_SEED(RX_LSFR_SEED),
    .AR_BIT(AR_BIT), 
    .AR_HEADER(AR_HEADER)
) i_raw_mode_ctrl (
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .raw_en_i(raw_en_i), 
    .raw_transmit_i(raw_transmit_i),

    // RAW input (from serial link)
    .raw_data_i(raw_data_i),
    .raw_valid_i(raw_valid_i),
    .raw_ready_o(raw_ready_o),
    // RAW output (to serial link)
    .raw_data_o(raw_data_o),
    .raw_valid_o(raw_valid_o),
    .raw_ready_i(raw_ready_i),

    // Evaluation
    .tx_byte_count_o(tx_byte_count_o),
    .rx_byte_count_o(rx_byte_count_o),
    .errors_o(errors_o),

    // Configuration
    .cfg_raw_test_length(cfg_raw_test_length)
);

endmodule