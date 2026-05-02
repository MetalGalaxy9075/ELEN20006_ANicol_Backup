// Seven segment display driver for hex digits
//
// Parameter:
//  Active Low (int) : 1 describes the hardware as active low
//    0 describes active high
//
// Ports:
//  digit    [3:0] : Hexedecimal digit to display
//  blank          : When high, all segments are off, otherwise all segments
//                   are on
//  segments [6:0] : Segment outputs [g,f,e,d,c,b,a]
`timescale 1ns / 1ps

module hms_counter #(
    // Number of seconds in a minute, and minutes in an hour
    parameter int N_HOURS   = 24,
    parameter int N_MINUTES = 60,
    parameter int N_SECONDS = 60,

    // Output port widths
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);
  localparam logic [W_HOURS-1:0] MaxHours = W_HOURS'(N_HOURS - 1);
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);
  localparam logic [W_SECONDS-1:0] SecondsZero = W_SECONDS'(0);
  localparam logic [W_MINUTES-1:0] MinutesZero = W_MINUTES'(0);

  logic second_rollover, minute_rollover;
  assign second_rollover = (seconds == SecondsZero) & (prev_seconds != SecondsZero);
  assign minute_rollover = (minutes == MinutesZero) & (prev_minutes != MinutesZero);

  logic [W_SECONDS-1:0] prev_seconds;
  logic [W_MINUTES-1:0] prev_minutes;

  up_down_counter #(
      .MAX  (MaxSeconds),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );
  up_down_counter #(
      .MAX  (MaxMinutes),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(second_rollover),
      .enable(enable),
      .up(1'b1),
      .count(minutes)
  );
  up_down_counter #(
      .MAX  (MaxHours),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(minute_rollover),
      .enable(enable),
      .up(1'b1),
      .count(hours)
  );

  always_ff @(posedge clk) begin
    prev_seconds <= seconds;
    prev_minutes <= minutes;
  end

endmodule
