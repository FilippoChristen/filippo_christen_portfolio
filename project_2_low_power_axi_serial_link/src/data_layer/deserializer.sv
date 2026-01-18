// -----------------------------------------------------------------------
//              DESERIALIZER
//
// Author: Filippo Christen
// Date: 29.06.2025
//
// Function:
// - Convert 8-bit serial PHY output into parallel bit flit.
//
// -----------------------------------------------------------------------

module deserializer #(
    // AXI parameters
    parameter int unsigned MAX_AXI_BIT,
    parameter int unsigned AR_BYTE,
    parameter int unsigned R_BYTE,
    parameter int unsigned AW_BYTE,
    parameter int unsigned W_BYTE,
    parameter int unsigned B_BYTE,
    parameter int unsigned MAX_AXI_BYTE,

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

    // Network layer interface signals
    // Serial → AXI
    output logic [MAX_AXI_BIT-1:0] a_data_o,
    output logic [2:0] a_header_o,
    output logic a_valid_o,
    input logic a_ready_i,

    // FIFO buffer interface signals
    // Serial → AXI
    input  logic [7:0] s_data_i,
    input  logic s_valid_i,
    output logic s_ready_o
); 

// Output register
logic flit_complete_d, flit_complete_q;
logic [2:0] header_d, header_q;
logic [8*MAX_AXI_BYTE-1:0] flit_d, flit_q;
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        flit_complete_q <= '0;
        header_q <= '0;
        flit_q <= '0;
    end else begin
        flit_complete_q <= flit_complete_d;
        header_q <= header_d;
        flit_q <= flit_d;
    end
end

typedef enum {
    Header,
    Data
} des_state_e;

des_state_e des_state_q, des_state_d;

logic [$clog2(MAX_AXI_BYTE):0] byte_count_d, byte_count_q;

// Inputs: a_ready_i, s_valid_i, s_data_i
// Outputs: s_ready_o, a_valid_o, a_header_o, a_data_o
always_comb begin
    // Default assignments
    des_state_d = des_state_q;
    flit_complete_d = flit_complete_q;
    header_d = header_q;
    flit_d = flit_q;
    a_data_o = flit_q[8*MAX_AXI_BYTE-1:8*MAX_AXI_BYTE-MAX_AXI_BIT];
    a_valid_o = '0;
    s_ready_o = 1'b1;
    byte_count_d = byte_count_q;

    a_header_o = header_q;

    unique case (des_state_q)
        Header: begin
            flit_complete_d = '0;
            if (s_valid_i) begin
                header_d = s_data_i[7:5];
                des_state_d = Data;
            end 
        end

        Data: begin
            if (s_valid_i) begin
                if (!flit_complete_q) begin
                    flit_d[8*(MAX_AXI_BYTE - byte_count_q) - 1 -: 8] = s_data_i;
                    if ((header_q == AW_HEADER && byte_count_q == AW_BYTE) || (header_q == W_HEADER && byte_count_q == W_BYTE) || (header_q == AR_HEADER && byte_count_q == AR_BYTE) || (header_q == R_HEADER && byte_count_q == R_BYTE) || (header_q == B_HEADER && byte_count_q == B_BYTE)) begin
                        //s_ready_o = '0;
                        a_valid_o = 1'b1;

                        byte_count_d = '0;
                        if (a_ready_i) begin
                            des_state_d = Header;
                            header_d = '0;
                            flit_complete_d = '0;
                        end else begin
                            flit_complete_d = 1'b1;
                        end
                    end else begin
                        byte_count_d = byte_count_q + 1;
                    end
                end else begin
                    a_valid_o = 1'b1;
                    s_ready_o = '0;
                    
                    if (a_ready_i) begin
                        des_state_d = Header;
                        header_d = '0;
                        flit_complete_d = '0;
                    end
                end
            end else begin
                if (flit_complete_q) begin
                    a_valid_o = 1'b1;
                    s_ready_o = '0;

                    if (a_ready_i) begin
                        des_state_d = Header;
                        header_d = '0;
                        flit_complete_d = '0;
                    end
                end
            end
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        des_state_q <= Header;
        byte_count_q <= 0;
    end else begin
        des_state_q <= des_state_d;
        byte_count_q <= byte_count_d;
    end
end

endmodule