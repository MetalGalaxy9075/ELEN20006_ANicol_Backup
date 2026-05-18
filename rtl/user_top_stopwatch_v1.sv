// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    /* verilator lint_on UNUSED */
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  initial blank_hours = 0;
  initial blank_minutes = 0;
  initial blank_seconds = 0;

  logic rise_start_stop;
  logic rise_lap;
  logic counter_rst;
  logic counter_enable;
  logic lap_hold;
  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(rise_start_stop),
      .rise_lap(rise_lap),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  logic [6:0] centiseconds;
  logic [5:0] seconds;
  logic [6:0] minutes;
  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(minutes),
      .seconds(seconds),
      .centiseconds(centiseconds)
  );

  rising_edge_detector u_start_stop_detect (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );
  rising_edge_detector u_lap_detect (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_minutes (
      .clk(clk),
      .hold(lap_hold),
      .d(minutes),
      .q(hours_disp)
  );

  snapshot_mux #(
      .WIDTH(6)
  ) u_snapshot_seconds (
      .clk(clk),
      .hold(lap_hold),
      .d(seconds),
      .q(minutes_disp[5:0])
  );
  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_centiseconds (
      .clk(clk),
      .hold(lap_hold),
      .d(centiseconds),
      .q(seconds_disp)
  );

  assign minutes_disp[6] = 0;
  assign led = 10'b0;

endmodule
