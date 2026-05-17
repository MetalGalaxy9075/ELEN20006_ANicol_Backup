// Seven segment display driver for hex digits
//  Converts a binary input into a 7 element output to drive a 
//  standard hexidecimal display.
//
// Parameter:
//  N     : A value one great than the maximum count of the counter
//  WIDTH : The bit width of the count variable
//
// Ports:
//  clk               : The clock input 
//  rst               : The reset pin. 1 resets the clock to 0 at the
//                      next rising edge.
//  enable            : The enable pin. A signal of 1 allows the counter
//                      to continue, while 0 holds the counter at the value
//                      seen at the previous rising edge.
//  count [WIDTH-1:0] : Stores the current count of the system
//
`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH-1:0] Zero = WIDTH'(0);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);
  localparam logic [WIDTH-1:0] Max = WIDTH'(N);

  logic [WIDTH-1:0] next_count;

  initial count = Zero;

  always_ff @(posedge clk) begin
    if (rst) count <= Zero;
    else if (enable) count <= next_count;
  end

  always_comb begin
    if (enable) begin
      next_count = (count < (Max - One)) ? count + One : Zero;
    end else next_count = count;

  end
endmodule
