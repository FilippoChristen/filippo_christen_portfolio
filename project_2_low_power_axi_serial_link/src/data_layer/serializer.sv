// -----------------------------------------------------------------------
//              SERIALIZER
//
// Author: Filippo Christen
// Date: 29.06.2025
//
// Function:
// - Convert parallel bit flits into 8-bit serial compatible with PHY.
//
// -----------------------------------------------------------------------

module serializer #(
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
    // AXI → Serial
    input logic [MAX_AXI_BIT-1:0] a_data_i,
    input logic [2:0] a_header_i,
    input logic a_valid_i,
    output logic a_ready_o,

    // FIFO buffer interface signals
    // AXI → Serial
    output logic [7:0] s_data_o,
    output logic s_valid_o,
    input  logic s_ready_i
); 

// Input register
logic [2:0] header_d, header_q;
logic [8*MAX_AXI_BYTE-1:0] flit_d, flit_q;
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        header_q <= '0;
        flit_q <= '0;
    end else begin
        header_q <= header_d;
        flit_q <= flit_d;
    end
end

typedef enum {
    Header,
    Data
} ser_state_e;

ser_state_e ser_state_q, ser_state_d;

logic [$clog2(MAX_AXI_BYTE):0] byte_count_d, byte_count_q;
always_comb begin
    // Default assignments
    ser_state_d = ser_state_q;
    header_d = header_q;
    flit_d = flit_q;
    s_data_o = '0;
    s_valid_o = '0;
    a_ready_o = '0;
    byte_count_d = byte_count_q;
    unique case (ser_state_q)
        Header: begin
            if (a_valid_i) begin
                header_d = a_header_i;
                flit_d[8*MAX_AXI_BYTE-1:8*MAX_AXI_BYTE-MAX_AXI_BIT] = a_data_i; // Cast data to MSB
                s_valid_o = 1'b1;
                s_data_o = {a_header_i, 5'b00000};

                if (s_ready_i) begin
                    a_ready_o = 1'b1;
                    ser_state_d = Data;
                end 
            end
        end

        Data: begin
            s_valid_o = 1'b1;
            if (s_ready_i) begin
                if ((header_q == AW_HEADER && byte_count_q == AW_BYTE) || (header_q == W_HEADER && byte_count_q == W_BYTE) || (header_q == AR_HEADER && byte_count_q == AR_BYTE) || (header_q == R_HEADER && byte_count_q == R_BYTE) || (header_q == B_HEADER && byte_count_q == B_BYTE)) begin
                    header_d = 0;
                    flit_d = 0;
                    byte_count_d = 0;
                    ser_state_d = Header;
                end else begin
                    s_data_o = flit_q[8*(MAX_AXI_BYTE - byte_count_q) - 1 -: 8];
                    byte_count_d = byte_count_q + 1;
                end
            end
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        ser_state_q <= Header;
        byte_count_q <= 0;
    end else begin
        ser_state_q <= ser_state_d;
        byte_count_q <= byte_count_d;
    end
end

endmodule