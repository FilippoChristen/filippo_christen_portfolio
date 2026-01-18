// -----------------------------------------------------------------------
//              CLOCK SHIFTER
//
// Author: Filippo Christen
// Date: 04.07.2025
//
// Note: Just for simulation purposes.
//
// -----------------------------------------------------------------------
`timescale 1fs/1fs

module clock_shifter (
  input  logic clk_in,
  input  time  delay, // Arbitrary skew
  input  time  enable_delay_after, // Time after which delay is active
  output logic clk_out // Skewed clock
);

initial clk_out = 0;

// On rising edge
always @(posedge clk_in) begin
  if ($time >= enable_delay_after) begin
    fork
      #delay clk_out <= 1;
    join_none
  end else begin
    clk_out <= 1;
  end
end

// On falling edge
always @(negedge clk_in) begin
  if ($time >= enable_delay_after) begin
    fork
      #delay clk_out <= 0;
    join_none
  end else begin
    clk_out <= 0;
  end
end

endmodule


