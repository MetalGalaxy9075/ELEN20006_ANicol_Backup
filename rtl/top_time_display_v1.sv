// Top time display v1
//  Displays cascading hour minute second hex displays on auto repeat
//
// Parameters:
//  CYCLES_PER_SECOND : Cycles between each pulse to the second module
//
// Ports:
//  CLOCK_50    : System clock input
//  SW [1:0]    : Switch input for mode select
//  HEX 5 [6:0] : Output to hex display
//  HEX 4 [6:0] : Output to hex display
//  HEX 3 [6:0] : Output to hex display
//  HEX 2 [6:0] : Output to hex display
//  HEX 1 [6:0] : Output to hex display
//  HEX 0 [6:0] : Output to hex display
//
`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  logic second_pulse, one_hz_pulse, twenty_five_hz_pulse, thousand_hz_pulse, pulse;
  logic [1:0] state;
  logic [1:0] next_state;
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic [3:0] hours_ones;
  logic [3:0] hours_tens;
  logic [3:0] minutes_ones;
  logic [3:0] minutes_tens;
  logic [3:0] seconds_ones;
  logic [3:0] seconds_tens;

  always_comb begin

    case (SW)
      2'b00: begin
        pulse = one_hz_pulse;
      end
      2'b01: begin
        pulse = twenty_five_hz_pulse;
      end
      2'b10: begin
        pulse = thousand_hz_pulse;
      end
      2'b11: begin
        pulse = CLOCK_50;
      end
      default: begin
        pulse = CLOCK_50;
      end
    endcase
  end

  assign second_pulse = pulse;

  hms_counter #(
      .N_HOURS  (24),
      .N_MINUTES(60),
      .N_SECONDS(60),
      .W_HOURS  (5),
      .W_MINUTES(6),
      .W_SECONDS(6)
  ) full_time (
      .clk(CLOCK_50),
      .enable(second_pulse),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) one_hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(one_hz_pulse)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) twenty_five_hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(twenty_five_hz_pulse)
  );
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) thousand_hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(thousand_hz_pulse)
  );

  binary_to_bcd hours_btb (
      .bin ({2'b0, hours}),
      .tens(hours_tens),
      .ones(hours_ones)
  );
  binary_to_bcd minutes_btb (
      .bin ({1'b0, minutes}),
      .tens(minutes_tens),
      .ones(minutes_ones)
  );
  binary_to_bcd seconds_btb (
      .bin ({1'b0, seconds}),
      .tens(seconds_tens),
      .ones(seconds_ones)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) hours_tens_hex (
      .digit(hours_tens),
      .blank(1'b0),
      .segments(HEX5)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) hours_ones_hex (
      .digit(hours_ones),
      .blank(1'b0),
      .segments(HEX4)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) minutes_tens_hex (
      .digit(minutes_tens),
      .blank(1'b0),
      .segments(HEX3)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) minutes_ones_hex (
      .digit(minutes_ones),
      .blank(1'b0),
      .segments(HEX2)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) seconds_tens_hex (
      .digit(seconds_tens),
      .blank(1'b0),
      .segments(HEX1)
  );
  seven_segment #(
      .ACTIVE_LOW(1)
  ) seconds_ones_hex (
      .digit(seconds_ones),
      .blank(1'b0),
      .segments(HEX0)
  );

endmodule
