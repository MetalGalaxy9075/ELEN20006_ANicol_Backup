// Rising edge detector
//  Produces a clock cycle long pulse when sig_in goes high
//
// Ports:
//  clk    : Clock input signal
//  sig_in : Signal being monitored
//   rise  : Pulse output
//
`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);
  reg  sig_prev = 0;
  wire sig_next_prev;

  always @(posedge clk) sig_prev <= sig_next_prev;

  assign sig_next_prev = sig_in;

  assign rise = (!sig_prev && sig_in);
endmodule
