// Edit mode selector
//  enables edit mode on the long press of a button, which then iterates
//  through multiple states on subsequent short presses.
//
// Parameters:
//  HOLD_CYCLES : Number of cycles to wait before enabling the counter for 
//                the first time
//
// Ports:
//  clk           : System clock input
//  button        : Button input to enable edit mode
//   enable [2:0] : State signal for hour minute second modes
//
`timescale 1ns / 1ps

module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable
);



  logic long_press;
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)
  );

  logic press;
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );

  logic armed;
  logic disarmed;
  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarmed),
      .armed(armed)
  );

  logic reset_counter;
  logic enable_counter;
  logic [1:0] count;
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );

  assign enable_counter = armed & press;
  assign reset_counter = !armed;

  assign disarmed = armed & press & (count == 2);

  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
