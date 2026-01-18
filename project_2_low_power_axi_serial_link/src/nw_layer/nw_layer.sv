// -----------------------------------------------------------------------
//              NETWORK LAYER
//
// Author: Filippo Christen
// Date: 03.07.2025
//
// Function:
// - Convert AXI into parallel data with appropriate header
//
// -----------------------------------------------------------------------


module nw_layer #(
    // AXI stuff
    parameter type axi_req_t  = logic,
    parameter type axi_rsp_t  = logic,

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
    parameter logic [2:0] B_HEADER
) (
    // Clock & Reset
    input  logic clk_i,
    input  logic rst_ni,

    // AXI interface signals
    // 1 --> 2
    input  axi_req_t  axi_in_req_i,
    output axi_rsp_t  axi_in_rsp_o,
    // 2 --> 1
    output axi_req_t  axi_out_req_o,
    input  axi_rsp_t  axi_out_rsp_i,

    // NW layer interface signals
    // AXI → Serial
    output logic [MAX_AXI_BIT-1:0] a_data_o,
    output logic [2:0] a_header_o,
    output logic a_valid_o,
    input logic a_ready_i,
    // Serial → AXI
    input logic [MAX_AXI_BIT-1:0] s_data_i,
    input logic [2:0] s_header_i,
    input logic s_valid_i,
    output logic s_ready_o
);


// INPUT CONTROL 
// Round-robin arbitration
// Note: granted_q stores which channel was granted in previous transaction
typedef enum {
    AR_granted,
    R_granted,
    AW_granted,
    W_granted,
    B_granted
} state_last_arbitration_e;

state_last_arbitration_e granted_d, granted_q;
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        granted_q <= AR_granted;
    end else begin
        granted_q <= granted_d;
    end
end

// Note: I'm sure there is a more elegant way to implement this, but I understand how this code works.
always_comb begin
    // Default assignments
    granted_d = granted_q;

    if (a_ready_i) begin
        unique case (granted_q)
            AR_granted: begin
                // Prio: R, AW, W, B, AR
                if (axi_out_rsp_i.r_valid) begin
                    granted_d = R_granted;
                end else if (axi_in_req_i.aw_valid) begin
                    granted_d = AW_granted;
                end else if (axi_in_req_i.w_valid) begin
                    granted_d = W_granted;
                end else if (axi_out_rsp_i.b_valid) begin
                    granted_d = B_granted;
                end else if (axi_in_req_i.ar_valid) begin
                    granted_d = AR_granted;
                end 
            end
            R_granted: begin
                // Prio: AW, W, B, AR, R
                if (axi_in_req_i.aw_valid) begin
                    granted_d = AW_granted;
                end else if (axi_in_req_i.w_valid) begin
                    granted_d = W_granted;
                end else if (axi_out_rsp_i.b_valid) begin
                    granted_d = B_granted;
                end else if (axi_in_req_i.ar_valid) begin
                    granted_d = AR_granted;
                end else if (axi_out_rsp_i.r_valid) begin
                    granted_d = R_granted;
                end 
            end
            AW_granted: begin
                // Prio: W, B, AR, R, AW
                if (axi_in_req_i.w_valid) begin
                    granted_d = W_granted;
                end else if (axi_out_rsp_i.b_valid) begin
                    granted_d = B_granted;
                end else if (axi_in_req_i.ar_valid) begin
                    granted_d = AR_granted;
                end else if (axi_out_rsp_i.r_valid) begin
                    granted_d = R_granted;
                end else if (axi_in_req_i.aw_valid) begin
                    granted_d = AW_granted;
                end
            end
            W_granted: begin
                // Prio: B, AR, R, AW, W
                if (axi_out_rsp_i.b_valid) begin
                    granted_d = B_granted;
                end else if (axi_in_req_i.ar_valid) begin
                    granted_d = AR_granted;
                end else if (axi_out_rsp_i.r_valid) begin
                    granted_d = R_granted;
                end else if (axi_in_req_i.aw_valid) begin
                    granted_d = AW_granted;
                end else if (axi_in_req_i.w_valid) begin
                    granted_d = W_granted;
                end
            end
            B_granted: begin
                // Prio: AR, R, AW, W, B
                if (axi_in_req_i.ar_valid) begin
                    granted_d = AR_granted;
                end else if (axi_out_rsp_i.r_valid) begin
                    granted_d = R_granted;
                end else if (axi_in_req_i.aw_valid) begin
                    granted_d = AW_granted;
                end else if (axi_in_req_i.w_valid) begin
                    granted_d = W_granted;
                end else if (axi_out_rsp_i.b_valid) begin
                    granted_d = B_granted;
                end
            end         
        endcase
    end
end

// Connection
always_comb begin
    // Default assignments
    a_data_o = '0;
    a_header_o = '0;
    a_valid_o = (axi_in_req_i.ar_valid || axi_out_rsp_i.r_valid || axi_in_req_i.aw_valid || axi_in_req_i.w_valid || axi_out_rsp_i.b_valid);
    axi_in_rsp_o.ar_ready = '0;
    axi_out_req_o.r_ready = '0;
    axi_in_rsp_o.aw_ready = '0;
    axi_in_rsp_o.w_ready = '0;
    axi_out_req_o.b_ready = '0;

    unique case (granted_d)
        AR_granted: begin
            if (axi_in_req_i.ar_valid) begin
                if (a_ready_i) begin
                    axi_in_rsp_o.ar_ready = 1'b1;
                    a_data_o[MAX_AXI_BIT-1:MAX_AXI_BIT-AR_BIT] = axi_in_req_i.ar;
                    a_header_o = AR_HEADER;
                end
            end
        end
        R_granted: begin
            if (axi_out_rsp_i.r_valid) begin
                if (a_ready_i) begin
                    axi_out_req_o.r_ready = 1'b1;
                    a_data_o[MAX_AXI_BIT-1:MAX_AXI_BIT-R_BIT] = axi_out_rsp_i.r;
                    a_header_o = R_HEADER;
                end
            end
        end
        AW_granted: begin
            if (axi_in_req_i.aw_valid) begin
                if (a_ready_i) begin
                    axi_in_rsp_o.aw_ready = 1'b1;
                    a_data_o[MAX_AXI_BIT-1:MAX_AXI_BIT-AW_BIT] = axi_in_req_i.aw;
                    a_header_o = AW_HEADER;
                end
            end
        end
        W_granted: begin
            if (axi_in_req_i.w_valid) begin
                if (a_ready_i) begin
                    axi_in_rsp_o.w_ready = 1'b1;
                    a_data_o[MAX_AXI_BIT-1:MAX_AXI_BIT-W_BIT] = axi_in_req_i.w;
                    a_header_o = W_HEADER;
                end
            end 
        end
        B_granted: begin
            if (axi_out_rsp_i.b_valid) begin
                if (a_ready_i) begin
                    axi_out_req_o.b_ready = 1'b1;
                    a_data_o[MAX_AXI_BIT-1:MAX_AXI_BIT-B_BIT] = axi_out_rsp_i.b;
                    a_header_o = B_HEADER;
                end
            end
        end   
    endcase
end


// OUTPUT CONTROL
always_comb begin
    // Default assignments
    axi_in_rsp_o.b_valid = '0;
    axi_in_rsp_o.b = '0;
    axi_in_rsp_o.r_valid = '0;
    axi_in_rsp_o.r = '0;
    axi_out_req_o.aw_valid = '0;
    axi_out_req_o.aw = '0;
    axi_out_req_o.w_valid = '0;
    axi_out_req_o.w = '0;
    axi_out_req_o.ar_valid = '0;
    axi_out_req_o.ar = '0;

    s_ready_o = '0;

    if (s_valid_i) begin
        if (s_header_i == AR_HEADER) begin
            if (axi_out_rsp_i.ar_ready) begin
                axi_out_req_o.ar_valid = 1'b1;
                axi_out_req_o.ar = s_data_i[MAX_AXI_BIT-1:MAX_AXI_BIT-AR_BIT];
                s_ready_o = 1'b1;
            end
        end else if (s_header_i == R_HEADER) begin
            if (axi_in_req_i.r_ready) begin
                axi_in_rsp_o.r_valid = 1'b1;
                axi_in_rsp_o.r = s_data_i[MAX_AXI_BIT-1:MAX_AXI_BIT-R_BIT];
                s_ready_o = 1'b1;
            end
        end else if (s_header_i == AW_HEADER) begin
            if (axi_out_rsp_i.aw_ready) begin
                axi_out_req_o.aw_valid = 1'b1;
                axi_out_req_o.aw = s_data_i[MAX_AXI_BIT-1:MAX_AXI_BIT-AW_BIT];
                s_ready_o = 1'b1;
            end
        end else if (s_header_i == W_HEADER) begin
            if (axi_out_rsp_i.w_ready) begin
                axi_out_req_o.w_valid = 1'b1;
                axi_out_req_o.w = s_data_i[MAX_AXI_BIT-1:MAX_AXI_BIT-W_BIT];
                s_ready_o = 1'b1;
            end
        end else if (s_header_i == B_HEADER) begin
            if (axi_in_req_i.b_ready) begin
                axi_in_rsp_o.b_valid = 1'b1;
                axi_in_rsp_o.b = s_data_i[MAX_AXI_BIT-1:MAX_AXI_BIT-B_BIT];
                s_ready_o = 1'b1;
            end
        end
    end
end

endmodule