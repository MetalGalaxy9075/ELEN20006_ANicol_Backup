// Button hold pulse
//  Produces a pulse signal once the input has been held high for HOLD_CYCLES cycles.
//
// Parameters
//  HOLD_CYCLES : The number of cycles the button signal must be held high to produce
//                a pulse.
//
// Ports
// clk    : The clock input to increment the internal counter
// button : The button input to enable or reset the counter
// pulse  : The pulse signal produced
//
`timescale 1ns / 1ps

module button_hold_pulse #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic held;

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(held),
      .rise(pulse)
  );

endmodule
