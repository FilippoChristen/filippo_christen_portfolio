// -----------------------------------------------------------------------
//              SYNCHRONIZER
//
// Author: Filippo Christen
// Date: 19.06.2025
//  
// -----------------------------------------------------------------------

module synchronizer #(
    // Parameters
) (
    // Clock and reset
    input logic clk_i,
    input logic rst_ni,

    // Control
    output logic reading_o,
    input logic synch_i,

    // Data
    input logic [7:0] data_i,
    output logic [7:0] data_o
);

// WIRES
logic [7:0] data_d, data_q;
logic [3:0] correction_shift_d, correction_shift_q;

// LOGIC

// Detect bit-shift
// Note: choose value of correction_shift_d
always_comb begin
    if (synch_i) begin
        if (data_d == 8'b00000000) begin
            reading_o = 1'b0;
            correction_shift_d = correction_shift_q;
        end else begin
            reading_o = 1'b1;
            if (data_d == 8'b11111111) begin
                correction_shift_d = 0;
            end else if (data_d == 8'b01111111) begin
                correction_shift_d = 7;
            end else if (data_d == 8'b00111111) begin
                correction_shift_d = 6;
            end else if (data_d == 8'b00011111) begin
                correction_shift_d = 5;
            end else if (data_d == 8'b00001111) begin
                correction_shift_d = 4;
            end else if (data_d == 8'b00000111) begin
                correction_shift_d = 3;
            end else if (data_d == 8'b00000011) begin
                correction_shift_d = 2;
            end else if (data_d == 8'b00000001) begin
                correction_shift_d = 1;
            end
        end 
    end else begin
        // If not synch, don't evaluate shift.
        reading_o = 1'b0;
        correction_shift_d = correction_shift_q;
    end
end

// Apply corrective bit-shift
always_comb begin
    if (correction_shift_q == 0) begin
        data_o = data_d;
    end else if (correction_shift_q == 7) begin
        data_o = {data_q[6:0], data_d[7]};
    end else if (correction_shift_q == 6) begin
        data_o = {data_q[5:0], data_d[7:6]};
    end else if (correction_shift_q == 5) begin
        data_o = {data_q[4:0], data_d[7:5]};
    end else if (correction_shift_q == 4) begin
        data_o = {data_q[3:0], data_d[7:4]};
    end else if (correction_shift_q == 3) begin
        data_o = {data_q[2:0], data_d[7:3]};
    end else if (correction_shift_q == 2) begin
        data_o = {data_q[1:0], data_d[7:2]};
    end else if (correction_shift_q == 1) begin
        data_o = {data_q[0], data_d[7:1]};
    end
end


// REGISTERS
// Correction shift save
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        correction_shift_q <= '0;
    end else begin
        correction_shift_q <= correction_shift_d;
    end
end

// Register 1
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        data_d <= '0;
    end else begin
        data_d <= data_i;
    end
end

// Register 2
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        data_q <= '0;
    end else begin
        data_q <= data_d;
    end
end



endmodule

