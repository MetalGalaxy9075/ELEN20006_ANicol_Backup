// Button hold detect
//  Detects if the button is held down for the specified number of cycles
//
// Parameters:
//  HOLD_CYCLES : the number of cycles to count before activating the held signal
//
// Ports:
//  clk    : The clock input signal
//  button : The button signal (direct from hardware)
//  held   : Signals if the button has been held. 1 for held, 0 for not.
//
`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);
  localparam int CountMax = HOLD_CYCLES + 1;
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  assign count_rst = !(button);
  assign count_enable = !(count > CountWidth'(CountMax - 1) || count == CountWidth'(CountMax));
  assign held = (count > CountWidth'(CountMax - 2)) && button;

endmodule
