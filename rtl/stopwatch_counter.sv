// Stopwatch counter 
//  Instantiates a cascade counter and drives it at the 
//  correct time interval.
//
// Parameters:
//  CYCLES_PER_SECOND : Number of clock cycles within one second in the clk sig
//
// Ports:
//  clk                : System clock signal
//  rst                : Resets counters to 0 when pulled high
//  enable             : Enables counting cycle
//  minutes      [6:0] : Stores minute value
//  seconds      [5:0] : Stores second value
//  centiseconds [6:0] : Stores centisecond value
//
`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);

  logic tick;

  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_casc_counter (
      .clk(clk),
      .rst(rst),
      .enable(tick && enable),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_centisecond_rate_generator (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );
endmodule
