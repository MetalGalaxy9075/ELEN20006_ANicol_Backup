// Button auto repeat
//  Produces a quick pulse as the button is pressed, then a continuous pulse 
//  once the button has been pressed for a set period of time
//
// Parameters:
//  HOLD_CYCLES   : The number of cycles to hold before pulsing the 
//                  pulse signal
//  REPEAT CYCLES : The number of cycles between each repeated pulse
//
// Ports
//  clk    : The clock input
//  button : The button input driving the pulse and button hold modules
//  pulse  : The output signal containing the preliminary pulse and the
//           repeated pulse
//
`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;

  assign pulse = rise | (button & pulse_train);

  rising_edge_detector rise_detect (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - 2)
  ) button_hold_detector (
      .clk(clk),
      .button(button),
      .held(held)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) rate_driver (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );

endmodule
