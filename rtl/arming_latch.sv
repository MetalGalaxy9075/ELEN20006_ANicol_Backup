// Arming latch
//  Puts the armed signal high on the high arm signal untill the disarm signal
//  goes high.
//
// ports
//  clk    : Clock input signal
//  arm    : arm signal, pull high to arm
//  disarm : disarm signal, pull high to disarm
//  armed  : remains high once the arm signal pulses high
//
`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);
  initial armed = 1'b0;

  always_ff @(posedge clk) begin
    if (disarm) armed <= 1'b0;
    else if (arm) armed <= 1'b1;
  end

endmodule
