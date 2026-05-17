// Up down counter reset:
//  Counts up or down by one unit to a given maximum value using a 
//  specified bit width. Also includes a reset function
//
// Parameter:
//  int MAX : maximum count value
//  int WIDTH : the bit width of the count variable
//
// Ports:
//  clk               : Clock input signal to update flip flops
//  enable            : Enables counting function. Holds current val if 0
//  up                : Counter counts up when up is 1, otherwise counts down
//  logic [WIDTH-1:0] : Binary encoded count output
//  rst               : When pulled high, resets counter to 0
//
`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);
  localparam logic [WIDTH-1:0] Zero = WIDTH'(0);

  logic [WIDTH-1:0] next_count;

  initial count = '0;

  always_ff @(posedge clk) begin
    if (rst) count <= '0;
    else if (enable) count <= next_count;
  end
  always_comb begin
    if (up) next_count = (count < (Max)) ? count + One : Zero;
    else if (!up) next_count = (count > Zero) ? count - One : Max;
    else next_count = count;
  end
endmodule
