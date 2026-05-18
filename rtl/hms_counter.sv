// Hour Minute Second counter
//  Chains three counters with specified bit widths and maximum values
//  to allow the rollover of one counter to trigger the next. Ideally used
//  to create a standard clock counter.
//
// Parameter:
//  N_HOURS   : Number of hours before rollover
//  N_MINUTES : Number of minutes before rollover
//  N_SECONDS : Number of seconds before rollover
//
//  W_HOURS   : Bit width of hours register
//  W_MINUTES : Bit width of minutes register
//  W_SECONDS : Bit width of seconds register
//
// Ports:
//  clk                     : Input for clock signal (1Hz)
//  enable                  : Enables counting at 1, disables otherwise
//  hours   [W_HOURS-1:0]   : register storing current hour
//  minutes [W_MINUTES-1:0] : register storing current minute
//  seconds [W_SECONDS-1:0] : register storing current second
// 
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
  localparam logic [W_SECONDS-1:0] SecondsZero = W_SECONDS'(0);
  localparam logic [W_MINUTES-1:0] MinutesZero = W_MINUTES'(0);

  logic second_rollover, minute_rollover;
  assign second_rollover = (seconds == SecondsZero) & (prev_seconds != SecondsZero);
  assign minute_rollover = (minutes == MinutesZero) & (prev_minutes != MinutesZero);

  logic [W_SECONDS-1:0] prev_seconds;
  logic [W_MINUTES-1:0] prev_minutes;

  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );
  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(second_rollover),
      .enable(enable),
      .up(1'b1),
      .count(minutes)
  );
  up_down_counter #(
      .MAX  (N_HOURS - 1),
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
