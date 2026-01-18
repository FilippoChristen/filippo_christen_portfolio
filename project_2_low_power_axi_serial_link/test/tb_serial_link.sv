// -----------------------------------------------------------------------
//              SERIAL LINK TESTBENCH
//
// Author: Filippo Christen
// Date: 04.07.2025
//
// -----------------------------------------------------------------------

`include "axi/assign.svh"
`include "axi/typedef.svh"
`timescale 1fs/1fs

module tb_serial_link;

// ------------------------------------------------------------------------
// SIMULATION PARAMETERS
// ------------------------------------------------------------------------
localparam int unsigned CPU_CLK_FREQ = 5e8; // 500 MHz
time RST_DELAY_1 = 43ns;  // Note: Defines when CPU resets
time RST_DELAY_2 = 132ns;
time CLK_DELAY_1 = 20ns; // Note: Defines how long after reset the clock starts
time CLK_DELAY_2 = 12fs;
time TX_PHY_RST_DELAY1 = 52ns; // Note: Defines when TX, and RX resets
time TX_PHY_RST_DELAY2 = 191ns; //       --> Has to be larger than RST_DELAY
time RX_PHY_RST_DELAY1 = 45ns;
time RX_PHY_RST_DELAY2 = 201ns;
time TX_PHY_PLL_DELAY1 = 123ns; // Note: Defines how long after RST the PLL asserts
time TX_PHY_PLL_DELAY2 = 64ns;
time MASTER_DELAY_1 = 2ms; // Note: How long after reset data is applied.
time MASTER_DELAY_2 = 2ms;

localparam int unsigned TEST_DURATION = 100; // How many transactions of each AXI channel are transmitted
time CLK_TO_DATA_SKEW_1 = 145_231ps; // Note: Forwarded clock has 1000ps period
time CLK_TO_DATA_SKEW_2 = 75_347ps;    
time ENABLE_DELAY_AFTER = 0fs; // This delay is to apply the skew only after a certain moment, for debugging.

// RAW mode TODO: Currently does not work
time RAW_EN_DEL_1 = 1500us; // Note: How long after reset the RAW mode is enabled.
time RAW_EN_DURATION_1 = 100us; // Note: How long RAM mode is enabled.
time RAW_TRANSMIT_DEL_1 = 1520us; // Note: How long after reset the RAW mode starts. Has to be larger than RAW_EN_DEL.
time RAW_TRANSMIT_DURATION_1 = 1590us; // Note: How long RAW mode transmits. Has to be smaller than RAW_EN_DURATION.
time RAW_EN_DEL_2 = 1500us;
time RAW_EN_DURATION_2 = 100us;
time RAW_TRANSMIT_DEL_2 = 1520us;
time RAW_TRANSMIT_DURATION_2 = 1590us;
// ------------------------------------------------------------------------



// ------------------------------------------------------------------------
// SERIAL LINK HARDWARE PARAMETERS 
// ------------------------------------------------------------------------
localparam int unsigned TX_FIFO_DEPTH = 32; // Actual depth
localparam int unsigned TX_CDC_DEPTH = 3; // Given as 2**TX_CDC_DEPTH
localparam int unsigned RX_FIFO_DEPTH = 32; // Actual depth
localparam int unsigned RX_CDC_DEPTH = 3; // Given as 2**RX_CDC_DEPTH

localparam int unsigned CREDIT_TRANSM_INTERVAL = 100; 

// Config stuff
localparam logic [7:0] cfg_credit_initial_amount = 30; // Initial credit amount. Needs to be smaller than RX FIFO depth
localparam logic [7:0] cfg_credit_transm_interval = 10; // Every how many bytes a credit packet is transmitted between the chips.
localparam logic [7:0] cfg_credit_transm_threshold = 1; // Least amount of credits that are transmitted when no other transmission is happening.

// TODO: Choose appropriate bit width (41 bit here is arbitrary)
// Note: these values have to be less than the "MAX" parameters below
localparam logic [40:0] cfg_stability = 100; // How many clock cycles the stable signal has to stay asserted for it to be registered (safety feature)
localparam logic [40:0] cfg_tx_phy_warmup = 500_000; // Tx warmup duration in clock cycles. Has to be larger than Rx warmup duration.
localparam logic [40:0] cfg_synch1 = 100_000; // How long Tx transmits 00...00 in clock cycles. Has to be larger than Rx warmup + Rx pause 1 - Tx warmup durations. 
localparam logic [40:0] cfg_synch3 = 100; // How long Tx transmits 00...00 in clock cycles after synchronization. 
localparam logic [40:0] cfg_idle = 500; // Minimum Tx idle duration. 
localparam logic [40:0] cfg_pre_cycles = 100; // How many clock cycles are forwarded before the data follows.
localparam logic [40:0] cfg_post_cycles = 100; // How many clock cycles are forwarded after data stops. Actual number of cycles will be one more.
localparam logic [40:0] cfg_to_idle = 1_000; // After how many clock cycles without valid data at input the Tx enters idle mode.
localparam logic [40:0] cfg_rx_pause1 = 100_000; // How long incoming data is not registered after warmup at rx in clock cycles. Has to be larger than the difference between Tx warmup and Rx warmup durations.
localparam logic [40:0] cfg_rx_phy_warmup = 450_000; // Rx warmup duration in clock cycles. Has to be smaller than Tx warmup duration.
localparam logic [40:0] cfg_rx_pause2 = 10; // How long Rx ignores input after synchronization to make sure no sync. data is passed along.

localparam logic [7:0] cfg_raw_test_length = 100; // Number of RAW mode bytes

// TODO: Choose appropriate values
localparam int unsigned MAX_STABILITY = 1_000_000;
localparam int unsigned MAX_TX_PHY_WARMUP = 1_000_000;
localparam int unsigned MAX_SYNCH1 = 1_000_000;
localparam int unsigned MAX_SYNCH3 = 1_000_000;
localparam int unsigned MAX_IDLE = 1_000_000;
localparam int unsigned MAX_PRE_CYCLES = 1_000_000;
localparam int unsigned MAX_POST_CYCLES = 1_000_000;
localparam int unsigned MAX_TO_IDLE = 1_000_000;
localparam int unsigned MAX_RX_PAUSE1 = 1_000_000;
localparam int unsigned MAX_RX_PHY_WARMUP = 1_000_000;
localparam int unsigned MAX_RX_PAUSE2 = 1_000_000;

// Note: Header 3'b000 forbidden
localparam logic [2:0] AW_HEADER = 3'b001;
localparam logic [2:0] W_HEADER = 3'b010;
localparam logic [2:0] AR_HEADER = 3'b011;
localparam logic [2:0] R_HEADER = 3'b100;
localparam logic [2:0] B_HEADER = 3'b101;
localparam logic [2:0] CREDIT_HEADER1 = 3'b110; // Credit packet. No interruption
localparam logic [2:0] CREDIT_HEADER2 = 3'b111; // Credit packet. Communicate out of credits

// RAW mode LSFR seeds
localparam logic [7:0] TX_LSFR_SEED = 8'b00111001;
localparam logic [7:0] RX_LSFR_SEED = 8'b10111001;
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// AXI CONFIG
// ------------------------------------------------------------------------
localparam int unsigned AXI_MAX_BURST_LEN = 255;
localparam int unsigned AXI_ID_WIDTH = 8;
localparam int unsigned AXI_ADDR_WIDTH = 48;
localparam int unsigned AXI_DATA_WIDTH = 512;
localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
localparam int unsigned AXI_USER_WIDTH = 1;



// ------------------------------------------------------------------------
// SIMULATION PREPARATION
// ------------------------------------------------------------------------
// AXI types for typedefs
typedef logic [AXI_ID_WIDTH-1:0] axi_id_t;
typedef logic [AXI_ADDR_WIDTH-1:0] axi_addr_t;
typedef logic [AXI_DATA_WIDTH-1:0] axi_data_t;
typedef logic [AXI_STRB_WIDTH-1:0] axi_strb_t;
typedef logic [AXI_USER_WIDTH-1:0] axi_user_t;

`AXI_TYPEDEF_ALL(tb_axi, axi_addr_t, axi_id_t, axi_data_t, axi_strb_t, axi_user_t)

// Standard AXI sizes
localparam int unsigned AXI_LEN_WIDTH = 8;
localparam int unsigned AXI_SIZE_WIDTH = 3;
localparam int unsigned AXI_BURST_WIDTH = 2;
localparam int unsigned AXI_LOCK_WIDTH = 1;
localparam int unsigned AXI_CACHE_WIDTH = 4;
localparam int unsigned AXI_PROT_WIDTH = 3;
localparam int unsigned AXI_QOS_WIDTH = 4;
localparam int unsigned AXI_REGION_WIDTH = 4;
localparam int unsigned AXI_ATOP_WIDTH = 6;
localparam int unsigned AXI_LAST_WIDTH = 1;
localparam int unsigned AXI_RESP_WIDTH = 2;
       
localparam int unsigned AR_BIT = AXI_ID_WIDTH + AXI_ADDR_WIDTH + AXI_LEN_WIDTH + AXI_SIZE_WIDTH + AXI_BURST_WIDTH + AXI_LOCK_WIDTH + AXI_CACHE_WIDTH + AXI_PROT_WIDTH + AXI_QOS_WIDTH + AXI_REGION_WIDTH + AXI_USER_WIDTH;
localparam int unsigned R_BIT = AXI_ID_WIDTH + AXI_DATA_WIDTH + AXI_RESP_WIDTH + AXI_LAST_WIDTH + AXI_USER_WIDTH;  
localparam int unsigned AW_BIT = AXI_ID_WIDTH + AXI_ADDR_WIDTH + AXI_LEN_WIDTH + AXI_SIZE_WIDTH + AXI_BURST_WIDTH + AXI_LOCK_WIDTH + AXI_CACHE_WIDTH + AXI_PROT_WIDTH + AXI_QOS_WIDTH + AXI_REGION_WIDTH + AXI_ATOP_WIDTH + AXI_USER_WIDTH;
localparam int unsigned W_BIT = AXI_DATA_WIDTH + AXI_STRB_WIDTH + AXI_LAST_WIDTH + AXI_USER_WIDTH;
localparam int unsigned B_BIT = AXI_ID_WIDTH + AXI_RESP_WIDTH + AXI_USER_WIDTH;

// Note: Above code is necessary as that the following does not work:
//localparam int unsigned AR_BIT = $bit(tb_axi_ar_chan_t);
//localparam int unsigned R_BIT = $bit(tb_axi_r_chan_t);
//localparam int unsigned AW_BIT = $bit(tb_axi_aw_chan_t);
//localparam int unsigned W_BIT = $bit(tb_axi_w_chan_t);
//localparam int unsigned B_BIT = $bit(tb_axi_b_chan_t);

localparam int unsigned AxiChannels[5] = {AR_BIT, R_BIT, AW_BIT, W_BIT, B_BIT};
localparam int unsigned MAX_AXI_BIT = find_max_channel(AxiChannels);

tb_axi_req_t SA_AXI_1_REQ, AS_AXI_1_REQ, SA_AXI_2_REQ, AS_AXI_2_REQ;
tb_axi_resp_t SA_AXI_1_RSP, AS_AXI_1_RSP, SA_AXI_2_RSP, AS_AXI_2_RSP;
logic SER_1_DATA, SER_1_CLK, SER_1_CLK_SKEW, SER_2_DATA, SER_2_CLK, SER_2_CLK_SKEW;
logic CLK_1, CLK_2, RSTN_1, RSTN_2;
logic SER_1_STABLE, SER_2_STABLE;
logic SIM_RST_TX_PHY_1, SIM_RST_RX_PHY_1, SIM_TX_PLL_READY_1;
logic SIM_RST_TX_PHY_2, SIM_RST_RX_PHY_2, SIM_TX_PLL_READY_2;
logic RAW_EN_1, RAW_EN_2, RAW_TRANSMIT_1, RAW_TRANSMIT_2;
logic [7:0] TX_BYTE_COUNT_1, TX_BYTE_COUNT_2, RX_BYTE_COUNT_1, RX_BYTE_COUNT_2, ERRORS_1, ERRORS_2;

real TCLKCPU;

// ------------------------------------------------------------------------
// SIMULATION STIMULI
// ------------------------------------------------------------------------

// Generate resets
initial begin
    RSTN_1 = 1'b0;
    #RST_DELAY_1;
    RSTN_1 = 1'b1;
end  

initial begin
    RSTN_2 = 1'b0;
    #RST_DELAY_2;
    RSTN_2 = 1'b1;
end  

// Compute period and skew
initial begin
    TCLKCPU = 1.0/CPU_CLK_FREQ; // in seconds
end

// Master clock: 500 MHz
initial begin
    CLK_1 = 0;
    wait (RSTN_1 == 1'b1);
    #CLK_DELAY_1;
    forever #(TCLKCPU*1e15 / 2) CLK_1 = ~CLK_1;
end

// Slave clock: same freq, phase-shifted
initial begin
    CLK_2 = 0;
    wait (RSTN_2 == 1'b1);
    #CLK_DELAY_2;
    forever #(TCLKCPU*1e15 / 2) CLK_2 = ~CLK_2;
end


initial begin
    SIM_RST_TX_PHY_1 = '0;
    #TX_PHY_RST_DELAY1;
    SIM_RST_TX_PHY_1 = 1'b1;
end

initial begin
    SIM_RST_RX_PHY_1 = '0;
    #RX_PHY_RST_DELAY1;
    SIM_RST_RX_PHY_1 = 1'b1;
end

initial begin
    SIM_TX_PLL_READY_1 = '0;
    wait (SIM_RST_TX_PHY_1 == 1'b1);
    #TX_PHY_PLL_DELAY1;
    SIM_TX_PLL_READY_1 = 1'b1;
end

initial begin
    SIM_RST_TX_PHY_2 = '0;
    #TX_PHY_RST_DELAY2;
    SIM_RST_TX_PHY_2 = 1'b1;
end

initial begin
    SIM_RST_RX_PHY_2 = '0;
    #RX_PHY_RST_DELAY2;
    SIM_RST_RX_PHY_2 = 1'b1;
end

initial begin
    SIM_TX_PLL_READY_2 = '0;
    wait (SIM_RST_TX_PHY_2 == 1'b1);
    #TX_PHY_PLL_DELAY2;
    SIM_TX_PLL_READY_2 = 1'b1;
end

// RAW mode
initial begin
    RAW_EN_1 = '0;
    wait (RSTN_1 == 1'b1);
    #RAW_EN_DEL_1;
    RAW_EN_1 = '0; // TODO: Deactivated for now as it does not work
    #RAW_EN_DURATION_1;
    RAW_EN_1 = '0;
end

initial begin
    RAW_TRANSMIT_1 = '0;
    wait (RSTN_1 == 1'b1);
    #RAW_TRANSMIT_DEL_1;
    RAW_TRANSMIT_1 = '0; // TODO: Deactivated for now as it does not work
    #RAW_TRANSMIT_DURATION_1;
    RAW_TRANSMIT_1 = '0;
end

initial begin
    RAW_EN_2 = '0;
    wait (RSTN_2 == 1'b1);
    #RAW_EN_DEL_2;
    RAW_EN_2 = '0; // TODO: Deactivated for now as it does not work
    #RAW_EN_DURATION_2;
    RAW_EN_2 = '0;
end

initial begin
    RAW_TRANSMIT_2 = '0;
    wait (RSTN_2 == 1'b1);
    #RAW_TRANSMIT_DEL_2;
    RAW_TRANSMIT_2 = '0; // TODO: Deactivated for now as it does not work
    #RAW_TRANSMIT_DURATION_2;
    RAW_TRANSMIT_2 = '0;
end


// ------------------------------------------------------------------------
// INSTANCES
// ------------------------------------------------------------------------

serial_link #(
    // AXI stuff
    .axi_req_t(tb_axi_req_t),
    .axi_rsp_t(tb_axi_resp_t),

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
    .B_HEADER(B_HEADER),
    .CREDIT_HEADER1(CREDIT_HEADER1), // Credit packet. No interruption
    .CREDIT_HEADER2(CREDIT_HEADER2), // Credit packet. Communicate interruption

    // FIFO & CDC parameters 
    // Note: FIFO depth given as 2**DEPTH.
    .TX_FIFO_DEPTH(TX_FIFO_DEPTH),
    .TX_CDC_DEPTH(TX_CDC_DEPTH),
    .RX_FIFO_DEPTH(RX_FIFO_DEPTH),
    .RX_CDC_DEPTH(RX_CDC_DEPTH),

    // Credits
    .CREDIT_TRANSM_INTERVAL(CREDIT_TRANSM_INTERVAL), // Max credit transmission interval in clock cycles

    // PHY wrapper
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
    .MAX_RX_PAUSE2(MAX_RX_PAUSE2),

    // RAW mode seeds
    .TX_LSFR_SEED(TX_LSFR_SEED),
    .RX_LSFR_SEED(RX_LSFR_SEED)
) i_serial_link_1 (
    // Clock & Reset
    .clk_i(CLK_1),
    .rst_ni(RSTN_1),

    // AXI interface signals
    // 1 --> 2
    .axi_in_req_i(AS_AXI_1_REQ),
    .axi_in_rsp_o(AS_AXI_1_RSP),
    // 2 --> 1
    .axi_out_req_o(SA_AXI_1_REQ),
    .axi_out_rsp_i(SA_AXI_1_RSP),

    // Serial transmission
    .s_data_o(SER_1_DATA),
    .s_clk_o(SER_1_CLK),
    .stable_o(SER_1_STABLE),
    .s_data_i(SER_2_DATA),
    .s_clk_i(SER_2_CLK_SKEW),
    .stable_i(SER_2_STABLE),

    // RAW mode
    .raw_en_i(RAW_EN_1),
    .raw_transmit_i(RAW_TRANSMIT_1),
    .tx_byte_count_o(TX_BYTE_COUNT_1),
    .rx_byte_count_o(RX_BYTE_COUNT_1),
    .errors_o(ERRORS_1),

    // Configuration
    .cfg_credit_initial_amount(cfg_credit_initial_amount),
    .cfg_credit_transm_interval(cfg_credit_transm_interval),
    .cfg_credit_transm_threshold(cfg_credit_transm_threshold),

    // Tx
    .cfg_stability(cfg_stability),
    .cfg_tx_phy_warmup(cfg_tx_phy_warmup),  
    .cfg_synch1(cfg_synch1),
    .cfg_synch3(cfg_synch3),
    .cfg_idle(cfg_idle),
    .cfg_pre_cycles(cfg_pre_cycles),
    .cfg_post_cycles(cfg_post_cycles), // Note: actual number of cycles will be one more
    .cfg_to_idle(cfg_to_idle),
    // Rx
    .cfg_rx_pause1(cfg_rx_pause1),
    .cfg_rx_phy_warmup(cfg_rx_phy_warmup),
    .cfg_rx_pause2(cfg_rx_pause2),

    .cfg_raw_test_length(cfg_raw_test_length),

    // Simulation
    .sim_rst_tx_phy_ni(SIM_RST_TX_PHY_1),
    .sim_rst_rx_phy_ni(SIM_RST_RX_PHY_1),
    .sim_tx_pll_ready(SIM_TX_PLL_READY_1)
);


// Delay
clock_shifter #(
) i_clock_shifter_12 (
    .clk_in(SER_1_CLK),
    .delay(CLK_TO_DATA_SKEW_1),
    .enable_delay_after(ENABLE_DELAY_AFTER),
    .clk_out(SER_1_CLK_SKEW)
);

// Delay
clock_shifter #(
) i_clock_shifter_21 (
    .clk_in(SER_2_CLK),
    .delay(CLK_TO_DATA_SKEW_2),
    .enable_delay_after(ENABLE_DELAY_AFTER),
    .clk_out(SER_2_CLK_SKEW)
);


serial_link #(
    // AXI stuff
    .axi_req_t(tb_axi_req_t),
    .axi_rsp_t(tb_axi_resp_t),

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
    .B_HEADER(B_HEADER),
    .CREDIT_HEADER1(CREDIT_HEADER1), // Credit packet. No interruption
    .CREDIT_HEADER2(CREDIT_HEADER2), // Credit packet. Communicate interruption

    // FIFO & CDC parameters 
    // Note: FIFO depth given as 2**DEPTH.
    .TX_FIFO_DEPTH(TX_FIFO_DEPTH),
    .TX_CDC_DEPTH(TX_CDC_DEPTH),
    .RX_FIFO_DEPTH(RX_FIFO_DEPTH),
    .RX_CDC_DEPTH(RX_CDC_DEPTH),

    // Credits
    .CREDIT_TRANSM_INTERVAL(CREDIT_TRANSM_INTERVAL), // Max credit transmission interval in clock cycles

    // PHY wrapper
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
    .MAX_RX_PAUSE2(MAX_RX_PAUSE2),

    // RAW mode seeds
    .TX_LSFR_SEED(TX_LSFR_SEED),
    .RX_LSFR_SEED(RX_LSFR_SEED)
) i_serial_link_2 (
    // Clock & Reset
    .clk_i(CLK_2),
    .rst_ni(RSTN_2),

    // AXI interface signals
    // 2 --> 1
    .axi_in_req_i(AS_AXI_2_REQ),
    .axi_in_rsp_o(AS_AXI_2_RSP),
    // 1 --> 2
    .axi_out_req_o(SA_AXI_2_REQ),
    .axi_out_rsp_i(SA_AXI_2_RSP),

    // Serial transmission
    .s_data_o(SER_2_DATA),
    .s_clk_o(SER_2_CLK),
    .stable_o(SER_2_STABLE),
    .s_data_i(SER_1_DATA),
    .s_clk_i(SER_1_CLK_SKEW),
    .stable_i(SER_1_STABLE),

    // RAW mode
    .raw_en_i(RAW_EN_2),
    .raw_transmit_i(RAW_TRANSMIT_2),
    .tx_byte_count_o(TX_BYTE_COUNT_2),
    .rx_byte_count_o(RX_BYTE_COUNT_2),
    .errors_o(ERRORS_2),

    // Configuration
    .cfg_credit_initial_amount(cfg_credit_initial_amount),
    .cfg_credit_transm_interval(cfg_credit_transm_interval),
    .cfg_credit_transm_threshold(cfg_credit_transm_threshold),

    // Tx
    .cfg_stability(cfg_stability),
    .cfg_tx_phy_warmup(cfg_tx_phy_warmup),  
    .cfg_synch1(cfg_synch1),
    .cfg_synch3(cfg_synch3),
    .cfg_idle(cfg_idle),
    .cfg_pre_cycles(cfg_pre_cycles),
    .cfg_post_cycles(cfg_post_cycles), // Note: actual number of cycles will be one more
    .cfg_to_idle(cfg_to_idle),
    // Rx
    .cfg_rx_pause1(cfg_rx_pause1),
    .cfg_rx_phy_warmup(cfg_rx_phy_warmup),
    .cfg_rx_pause2(cfg_rx_pause2),

    // RAW mode
    .cfg_raw_test_length(cfg_raw_test_length),

    // Simulation
    .sim_rst_tx_phy_ni(SIM_RST_TX_PHY_2),
    .sim_rst_rx_phy_ni(SIM_RST_RX_PHY_2),
    .sim_tx_pll_ready(SIM_TX_PLL_READY_2)
);


// SIMULATION


AXI_BUS_DV #(
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXI_USER_WIDTH(AXI_USER_WIDTH)
) axi_in_1(CLK_1), axi_out_2(CLK_2);

AXI_BUS_DV #(
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXI_USER_WIDTH(AXI_USER_WIDTH)
) axi_in_2(CLK_2), axi_out_1(CLK_1);

`AXI_ASSIGN_TO_REQ(AS_AXI_1_REQ, axi_in_1)
`AXI_ASSIGN_FROM_RESP(axi_in_1, AS_AXI_1_RSP)

`AXI_ASSIGN_TO_REQ(AS_AXI_2_REQ, axi_in_2)
`AXI_ASSIGN_FROM_RESP(axi_in_2, AS_AXI_2_RSP)

`AXI_ASSIGN_FROM_REQ(axi_out_1, SA_AXI_1_REQ)
`AXI_ASSIGN_TO_RESP(SA_AXI_1_RSP, axi_out_1)

`AXI_ASSIGN_FROM_REQ(axi_out_2, SA_AXI_2_REQ)
`AXI_ASSIGN_TO_RESP(SA_AXI_2_RSP, axi_out_2)

// Master
typedef axi_test::axi_rand_master #(
    .AW(AXI_ADDR_WIDTH),
    .DW(AXI_DATA_WIDTH),
    .IW(AXI_ID_WIDTH),
    .UW(AXI_USER_WIDTH),
    .TA(100ps), // NOTE: this results in delay between signal and clock edge.
    .TT(500ps),
    .MAX_READ_TXNS(2),
    .MAX_WRITE_TXNS(2),
    .AX_MIN_WAIT_CYCLES(0),
    .AX_MAX_WAIT_CYCLES(100),
    .W_MIN_WAIT_CYCLES(0),
    .W_MAX_WAIT_CYCLES(100),
    .RESP_MIN_WAIT_CYCLES(0),
    .RESP_MAX_WAIT_CYCLES(100),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN),
    .TRAFFIC_SHAPING(0),
    .AXI_EXCLS(1'b1),
    .AXI_ATOPS(1'b0),
    .AXI_BURST_FIXED(1'b1),
    .AXI_BURST_INCR(1'b1),
    .AXI_BURST_WRAP(1'b0)
) axi_rand_master_t;

// Slave
typedef axi_test::axi_rand_slave #(
    .AW(AXI_ADDR_WIDTH),
    .DW(AXI_DATA_WIDTH),
    .IW(AXI_ID_WIDTH),
    .UW(AXI_USER_WIDTH),
    .TA(100ps),
    .TT(500ps),
    .RAND_RESP(0),
    .AX_MIN_WAIT_CYCLES(0),
    .AX_MAX_WAIT_CYCLES(100),
    .R_MIN_WAIT_CYCLES(0),
    .R_MAX_WAIT_CYCLES(100),
    .RESP_MIN_WAIT_CYCLES(0),
    .RESP_MAX_WAIT_CYCLES(100)
) axi_rand_slave_t;

static axi_rand_master_t axi_rand_master_1 = new(axi_in_1);
static axi_rand_master_t axi_rand_master_2 = new(axi_in_2);

static axi_rand_slave_t axi_rand_slave_1 = new(axi_out_1);
static axi_rand_slave_t axi_rand_slave_2 = new(axi_out_2);

// Perform TEST_DURATION Reads & Writes
int NumWrites_1 = TEST_DURATION;
int NumReads_1 = TEST_DURATION;
int NumWrites_2 = TEST_DURATION;
int NumReads_2 = TEST_DURATION;

initial begin
    axi_rand_slave_1.reset();
    wait_for_reset_1();
    axi_rand_slave_1.run();
end

initial begin
    axi_rand_slave_2.reset();
    wait_for_reset_2();
    axi_rand_slave_2.run();
end

initial begin
    axi_rand_master_1.reset();
    #MASTER_DELAY_1;
    axi_rand_master_1.run(NumWrites_1, NumReads_1);
end

initial begin
    axi_rand_master_2.reset();
    #MASTER_DELAY_2;
    axi_rand_master_2.run(NumWrites_2, NumReads_2);
end

task automatic wait_for_reset_1();
    @(posedge RSTN_1);
endtask

task automatic wait_for_reset_2();
    @(posedge RSTN_2);
endtask

task automatic stop_sim();
    repeat(50) begin
        @(posedge CLK_1);
    end
    $stop();
endtask



// ------------------------------------------------------------------------
// EVALUATION
// ------------------------------------------------------------------------

axi_chan_compare #(
    .aw_chan_t(tb_axi_aw_chan_t),
    .w_chan_t(tb_axi_w_chan_t),
    .b_chan_t(tb_axi_b_chan_t),
    .ar_chan_t(tb_axi_ar_chan_t),
    .r_chan_t(tb_axi_r_chan_t),
    .req_t(tb_axi_req_t),
    .resp_t(tb_axi_resp_t)
) i_axi_channel_compare_1_to_2 (
    .clk_a_i(CLK_1),
    .clk_b_i(CLK_2),
    .axi_a_req(AS_AXI_1_REQ),
    .axi_a_res(AS_AXI_1_RSP),
    .axi_b_req(SA_AXI_2_REQ),
    .axi_b_res(SA_AXI_2_RSP)
);

axi_chan_compare #(
    .aw_chan_t(tb_axi_aw_chan_t),
    .w_chan_t(tb_axi_w_chan_t),
    .b_chan_t(tb_axi_b_chan_t),
    .ar_chan_t(tb_axi_ar_chan_t),
    .r_chan_t(tb_axi_r_chan_t),
    .req_t(tb_axi_req_t),
    .resp_t(tb_axi_resp_t)
) i_axi_channel_compare_2_to_1 (
    .clk_a_i(CLK_2),
    .clk_b_i(CLK_1),
    .axi_a_req(AS_AXI_2_REQ),
    .axi_a_res(AS_AXI_2_RSP),
    .axi_b_req(SA_AXI_1_REQ),
    .axi_b_res(SA_AXI_1_RSP)
);


// ------------------------------------------------------------------------
// UTILS
// ------------------------------------------------------------------------
function automatic int find_max_channel(input int unsigned channel[5]);
    int unsigned max_value = 0;
        for (int i = 0; i < 5; i++) begin
            if (max_value < channel[i]) max_value = channel[i];
        end
    return max_value;
endfunction

endmodule