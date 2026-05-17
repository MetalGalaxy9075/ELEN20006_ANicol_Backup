// Editable counter
//  regular timer with an edit mode that allows for the increase and decrease 
//  of the displayed time.
//
// Parameters:
//  N     : The maximum count of the timer
//  WIDTH : The width of the count signal
//
// Port:
//  clk               : The system clock signal used to sync
//  tick              : The tick function to increment the counter
//  edit_mode         : Enables inc and dec counting
//  inc               : Increments the counter
//  dec               : Decrements the counter
//  count [WIDTH-1:0] : Stores the current count
//
`timescale 1ns / 1ps

module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count
);
  logic enable;
  logic up;
  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = edit_mode && tick;

  assign up = inc_event || !edit_mode;
  assign enable = (tick && !tick_event) || (edit_mode && (inc_event || dec_event));

endmodule
