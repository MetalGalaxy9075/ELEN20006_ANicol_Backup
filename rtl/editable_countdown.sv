// Editable Countdown 
//  Constant countdown that can be altered to a desired
//  starting point or steady state with an edit mode function
//
// Parameters:
//  MAX   : Maximum count the counter can reach
//  WIDTH : Bit width of the count variable
//
// Ports:
//  clk               : System clock
//  clr               : Resets countdown when pulled high
//  tick              : enables decrmenting or incrementing when pulsed
//  edit_mode         : When pulled high, allows for both inc and dec of count
//  inc               : Edit increase signal
//  dec               : Edit decrease signal
//  count [WIDTH-1:0] : Count register
//  borrow_out        : Borrow variable as defined by SN74LS193 datasheet
//
`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);

  logic enable;
  logic up;
  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  assign up = inc_event;
  assign enable = tick_event || inc_event || dec_event;

  assign borrow_out = !edit_mode && !clr && (tick && (count == '0));
endmodule
