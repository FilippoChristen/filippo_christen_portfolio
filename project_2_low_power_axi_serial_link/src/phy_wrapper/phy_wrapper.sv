// -----------------------------------------------------------------------
//              PHY WRAPPER
//
// Author: Filippo Christen
// Date: 19.06.2025
//
// The PHY was implemented by Sina Arjmandpour, sarjmadpour@iis.ee.ethz.ch
//
// -----------------------------------------------------------------------


module phy_wrapper #(
    // Control
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
    parameter int unsigned MAX_RX_PAUSE2
) (
    // GENERAL
    output logic clk_tx_o,
    output logic clk_rx_o,
    input logic rst_ni, // Note: resets everything across 2 different clock domains except the PHY. 

    // AXI SIDE
    // AXI --> Serial
    input logic [7:0] a_data_i,
    input logic a_valid_i,
    output logic a_ready_o,

    // Serial --> AXI
    output logic [7:0] s_data_o,
    output logic s_valid_o,
    input logic s_ready_i, // Unused at the moment

    // SERIAL SIDE
    // AXI --> Serial
    output logic tx_serial_data_o,
    output logic tx_serial_clk_fwd_o,
    output logic stable_o,

    // Serial --> AXI
    input logic rx_serial_data_i,
    input logic rx_serial_clk_fwd_i,
    input logic stable_i,

    // CONFIGURATION
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

    // SIMULATION
    input logic sim_rst_tx_phy_ni,
    input logic sim_rst_rx_phy_ni,

    input logic sim_tx_pll_ready
);

// LOCAL PARAMETERS
localparam logic [7:0] CLK_PATTERN = 8'b00110011;
localparam logic [7:0] WARMUP_PATTERN = 8'b10101010;

// WIRES
logic [7:0] tx_data, tx_clk_fwd, rx_data, rx_post_synch_data;
logic reading, synch; // Control input for synchronizer
logic clk_rx_direct, clk_tx_direct;


// CONTROL

// Tx PHY control
typedef enum {
    Tx_Start,
    Tx_Warmup,
    Tx_Stable,
    Tx_Synch1,
    Tx_Synch2,
    Tx_Synch3,
    Tx_Idle,
    Tx_ToRun,
    Tx_Run,
    Tx_ToIdle
} state_tx_e;

state_tx_e tx_state_q, tx_state_d;

// Counters
logic [$clog2(MAX_STABILITY):0] stability_count_q, stability_count_d;
logic [$clog2(MAX_TX_PHY_WARMUP):0] tx_warm_count_q, tx_warm_count_d;
logic [$clog2(MAX_SYNCH1):0] tx_synch1_count_q, tx_synch1_count_d;
logic [$clog2(MAX_SYNCH3):0] tx_synch3_count_q, tx_synch3_count_d;
logic [$clog2(MAX_IDLE):0] idle_count_q, idle_count_d;
logic [$clog2(MAX_PRE_CYCLES):0] pre_cycle_count_q, pre_cycle_count_d;
logic [$clog2(MAX_POST_CYCLES):0] post_cycle_count_q, post_cycle_count_d;
logic [$clog2(MAX_TO_IDLE):0] to_idle_count_q, to_idle_count_d;

always_comb begin
    // Default assignments
    tx_data = '0;
    tx_clk_fwd = '0;
    a_ready_o = '0;
    clk_tx_o = '0;
    clk_rx_o = '0;

    stable_o = 1'b1;

    stability_count_d = '0;
    tx_warm_count_d = '0;
    tx_synch1_count_d = '0;
    tx_synch3_count_d = '0;
    idle_count_d = '0;
    pre_cycle_count_d = '0;
    post_cycle_count_d = '0;
    to_idle_count_d = to_idle_count_q;

    tx_state_d = tx_state_q;

    unique case (tx_state_q)
        Tx_Start: begin
            stable_o = '0;
            clk_tx_o = '0;
            clk_rx_o = '0;

            if (sim_tx_pll_ready) begin
                tx_state_d = Tx_Stable;
            end
        end

        Tx_Stable: begin
            clk_tx_o = '0;
            clk_rx_o = '0;
            if (stable_i) begin
                if (stability_count_q == cfg_stability) begin
                    tx_state_d = Tx_Warmup;
                end else begin
                    stability_count_d = stability_count_q + 1;
                end
            end
        end

        Tx_Warmup: begin
            clk_tx_o = '0;
            clk_rx_o = '0;
            tx_clk_fwd = CLK_PATTERN;
            tx_data = WARMUP_PATTERN;
            if (tx_warm_count_q == cfg_tx_phy_warmup) begin
                tx_state_d = Tx_Synch1;
                tx_warm_count_d = '0;
            end else begin 
                tx_state_d = Tx_Warmup;
                tx_warm_count_d = tx_warm_count_q + 1;
            end
        end

        Tx_Synch1: begin
            clk_tx_o = clk_tx_direct;
            clk_rx_o = clk_rx_direct;
            tx_clk_fwd = CLK_PATTERN;

            if (tx_synch1_count_q == cfg_synch1) begin
                tx_state_d = Tx_Synch2;
                tx_synch1_count_d = '0;
            end else begin
                tx_state_d = Tx_Synch1;
                tx_synch1_count_d = tx_synch1_count_q + 1;
            end
        end       

        Tx_Synch2: begin
            clk_tx_o = clk_tx_direct;
            clk_rx_o = clk_rx_direct;
            tx_data = 8'b11111111;
            tx_clk_fwd = CLK_PATTERN;
            tx_state_d = Tx_Synch3;
        end

        Tx_Synch3: begin
            clk_tx_o = clk_tx_direct;
            clk_rx_o = clk_rx_direct;
            tx_clk_fwd = CLK_PATTERN;

            if (tx_synch3_count_q == cfg_synch3) begin
                tx_state_d = Tx_Idle;
                tx_synch3_count_d = '0;
            end else begin
                tx_state_d = Tx_Synch3;
                tx_synch3_count_d = tx_synch3_count_q + 1;
            end
        end

        Tx_Idle: begin
            clk_tx_o = clk_tx_direct;
            clk_rx_o = clk_rx_direct;
            if (idle_count_q == cfg_idle) begin
                if (a_valid_i) begin
                    tx_clk_fwd = CLK_PATTERN; // Start clock early
                    if (cfg_pre_cycles == '0) begin
                        tx_state_d = Tx_Run;
                    end else begin
                        tx_state_d = Tx_ToRun;                     
                    end
                end else begin
                    tx_state_d = Tx_Idle;
                    idle_count_d = idle_count_q;
                end
            end else begin 
                tx_state_d = Tx_Idle;
                idle_count_d = idle_count_q + 1;
            end           
        end
                
        Tx_ToRun: begin
            clk_tx_o = clk_tx_direct;
            clk_rx_o = clk_rx_direct;
            tx_clk_fwd = CLK_PATTERN;

            if (pre_cycle_count_q == cfg_pre_cycles) begin
                tx_state_d = Tx_Run;
                pre_cycle_count_d = '0;
            end else begin 
                tx_state_d = Tx_ToRun;
                pre_cycle_count_d = pre_cycle_count_q + 1;
            end
        end

        Tx_Run: begin
            clk_tx_o = clk_tx_direct;
            clk_rx_o = clk_rx_direct;
            a_ready_o = 1'b1;
            tx_clk_fwd = CLK_PATTERN;

            if (!a_valid_i) begin
                if (to_idle_count_q == cfg_to_idle) begin
                    to_idle_count_d = 0;
                    if (cfg_post_cycles == '0) begin
                        tx_state_d = Tx_Idle;
                    end else begin 
                        tx_state_d = Tx_ToIdle;
                    end
                end else begin
                    to_idle_count_d = to_idle_count_q + 1;
                    tx_data = '0;
                    tx_state_d = Tx_Run;
                end
            end else begin
                to_idle_count_d = 0;
                tx_data = a_data_i;
                tx_state_d = Tx_Run;
            end    
        end

        Tx_ToIdle: begin
            clk_tx_o = clk_tx_direct;
            clk_rx_o = clk_rx_direct;
            tx_clk_fwd = CLK_PATTERN;

            if (post_cycle_count_q == cfg_post_cycles) begin
                tx_state_d = Tx_Idle;
                post_cycle_count_d = '0;
            end else begin 
                tx_state_d = Tx_ToIdle;
                post_cycle_count_d = post_cycle_count_q + 1;
            end
        end
    endcase
end

always_ff @(posedge clk_tx_direct or negedge rst_ni) begin
    if (!rst_ni) begin
        tx_state_q <= Tx_Start;
        stability_count_q <= '0;
        tx_warm_count_q <= '0;
        tx_synch1_count_q <= '0;
        tx_synch3_count_q <= '0;
        pre_cycle_count_q <= '0;
        post_cycle_count_q <= '0;
        idle_count_q <= '0;
        to_idle_count_q <= '0;
    end else begin
        tx_state_q <= tx_state_d;
        stability_count_q <= stability_count_d;
        tx_warm_count_q <= tx_warm_count_d;
        tx_synch1_count_q <= tx_synch1_count_d;
        tx_synch3_count_q <= tx_synch3_count_d;
        pre_cycle_count_q <= pre_cycle_count_d;
        post_cycle_count_q <= post_cycle_count_d;
        idle_count_q <= idle_count_d;
        to_idle_count_q <= to_idle_count_d;
    end
end

// Tx PHY control
typedef enum {
    Rx_Warmup,
    Rx_Pause1,
    Rx_SynchWait,
    Rx_Pause2,
    Rx_Run
} state_rx_e;

state_rx_e rx_state_q, rx_state_d;

// Counters
logic [$clog2(MAX_RX_PAUSE1):0] rx_pause1_count_q, rx_pause1_count_d;
logic [$clog2(MAX_RX_PAUSE2):0] rx_pause2_count_q, rx_pause2_count_d;
logic [$clog2(MAX_RX_PHY_WARMUP):0] rx_warm_count_q, rx_warm_count_d;

always_comb begin
    // Default assignments
    s_valid_o = '0;
    s_data_o = '0;
    synch = '0;
    rx_pause1_count_d = '0;
    rx_pause2_count_d = '0;
    rx_warm_count_d = '0;

    rx_state_d = rx_state_q;

    unique case (rx_state_q)
        Rx_Warmup: begin 
            if (rx_warm_count_q == cfg_rx_phy_warmup) begin
                rx_state_d = Rx_Pause1;
                rx_warm_count_d = '0;
            end else begin
                rx_state_d = Rx_Warmup;
                rx_warm_count_d = rx_warm_count_q + 1;
            end
        end

        Rx_Pause1: begin
            if (rx_pause1_count_q == cfg_rx_pause1) begin
                rx_state_d = Rx_SynchWait;
                rx_pause1_count_d = '0;
            end else begin
                rx_state_d = Rx_Pause1;
                rx_pause1_count_d = rx_pause1_count_q + 1;
            end            
        end

        Rx_SynchWait: begin
            synch = 1'b1;

            if (reading) begin
                rx_state_d = Rx_Pause2;
            end else begin
                rx_state_d = Rx_SynchWait;
            end

            // TODO: add timeout counter as if reading doesn't asserts it stays here forever
        end  

        Rx_Pause2: begin 
            // Purpose: ensures synch data is not registered as valid data.
            if (rx_pause2_count_q == cfg_rx_pause2) begin
                rx_state_d = Rx_Run;
                rx_pause2_count_d = '0;
            end else begin 
                rx_pause2_count_d = rx_pause2_count_q + 1;
            end
        end

        Rx_Run: begin
            s_data_o = rx_post_synch_data;
            s_valid_o = 1;    
            rx_state_d = Rx_Run;      
        end
    endcase
end

always_ff @(posedge clk_rx_direct or negedge rst_ni) begin
    if (!rst_ni) begin
        rx_state_q <= Rx_Warmup;
        rx_pause1_count_q <= '0;
        rx_pause2_count_q <= '0;
        rx_warm_count_q <= '0;
    end else begin
        rx_state_q <= rx_state_d;
        rx_pause1_count_q <= rx_pause1_count_d;
        rx_pause2_count_q <= rx_pause2_count_d;
        rx_warm_count_q <= rx_warm_count_d; 
    end
end

// INSTANTIATIONS

// Tx data PHY
MUX8_1 i_tx (
    .RSTN(sim_rst_tx_phy_ni), // Note: input only for simulation purposes
    .DATA(tx_data),
    .CLKOUT(clk_tx_direct),
    .TXOUT(tx_serial_data_o)
);

// Tx clock forwarding PHY
MUX8_1 i_clk_tx (
    .RSTN(sim_rst_tx_phy_ni), // Note: input only for simulation purposes
    .DATA(tx_clk_fwd),
    .CLKOUT(), // Unused --> Identical to i_tx
    .TXOUT(tx_serial_clk_fwd_o)
);

// Rx PHY
DEMUX1_8 i_rx (
    .RSTN(sim_rst_rx_phy_ni), // Note: input only for simulation purposes
    .RXIN(rx_serial_data_i),
    .CLKIN(rx_serial_clk_fwd_i),
    .DATAOUT(rx_data),
    .CLKOUT(clk_rx_direct)
);

// Synchronizer
synchronizer #(
) i_synchronizer (
    .clk_i(clk_rx_o),
    .rst_ni(rst_ni),
    .reading_o(reading),
    .synch_i(synch),
    .data_i(rx_data),
    .data_o(rx_post_synch_data)
);


endmodule

