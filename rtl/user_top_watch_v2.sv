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

module user_top_watch_v2 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // ------------------
  // Core Functionality
  // ------------------

  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds_count;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds_count)
  );

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes_count;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes_count)
  );

  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours_count;
  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours_count)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );

  assign minutes_tick = (seconds_count == 6'd59) && seconds_tick;
  assign hours_tick   = (minutes_count == 6'd59) && minutes_tick;

  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND - 1)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  logic flash_rst;
  logic flash_pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2) / 5)
  ) u_pwm_flash (
      .clk(clk),
      .rst(flash_rst),
      .pwm_out(flash_pwm_out)
  );

  //correct assignmets
  assign blank_hours = flash_pwm_out && (mode_enable == 3'b100);
  assign blank_minutes = flash_pwm_out && (mode_enable == 3'b010);
  assign blank_seconds = flash_pwm_out && (mode_enable == 3'b001);

  assign flash_rst = 1'b0;

  //temporary assignments
  assign seconds_edit = 1'b0;
  assign minutes_edit = 1'b0;
  assign hours_edit = 1'b0;

  assign seconds_inc = 1'b0;
  assign seconds_dec = 1'b0;
  assign minutes_inc = 1'b0;
  assign minutes_dec = 1'b0;
  assign hours_inc = 1'b0;
  assign hours_dec = 1'b0;

  assign hours_disp = {2'b0, hours_count};
  assign minutes_disp = {1'b0, minutes_count};
  assign seconds_disp = {1'b0, seconds_count};

  assign led = 10'b0;


endmodule
