// Snapshot Multiplexer
//  Takes a snapshot of the current input value when activated, and 
//  outputs that value untill deactivated, where the output is combinationally 
//  linked to the input.
//
// Parameters:
//  WIDTH : bit width of the multiplexed register
//
// Ports:
//  clk           : System clock signal
//  hold          : Locks multiplexer to internal register when pulled high
//  d`[WIDTH-1:0] : Input register
//  q [WIDTH-1:0] : Output register
//
`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] sample;
  initial sample = WIDTH'(0);

  always_ff @(posedge clk) begin
    if (!hold) sample <= d;
  end

  always_comb begin
    if (!hold) q = d;
    else q = sample;
  end

endmodule
