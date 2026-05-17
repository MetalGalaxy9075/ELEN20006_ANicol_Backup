
`timescale 1ns / 1ps

module user_top_brightness_timepiece #(
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
  localparam int PWMCycles = CYCLES_PER_SECOND / 1000;
  localparam int MaxWidth = $clog2(PWMCycles + 1);


  //-------------
  // PWM signal
  //-------------
  logic [MaxWidth-1:0] OffCount;
  logic [MaxWidth-1:0] count;
  logic pwm_out;
  logic [1:0] prev_brightness;
  logic [1:0] brightness;

  always_ff @(posedge clk) prev_brightness <= brightness;

  always_comb begin
    case (brightness)
      2'b00:   OffCount = MaxWidth'(PWMCycles / 8);
      2'b01:   OffCount = MaxWidth'(PWMCycles / 4);
      2'b11:   OffCount = MaxWidth'(PWMCycles / 2);
      2'b10:   OffCount = MaxWidth'(PWMCycles + 1);
      default: OffCount = MaxWidth'(PWMCycles + 1);
    endcase
  end

  logic rst;
  mod_n_counter #(
      .N(PWMCycles),
      .WIDTH(MaxWidth)
  ) period_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );


  logic blank_hours_sub;
  logic blank_minutes_sub;
  logic blank_seconds_sub;
  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(blank_hours_sub),
      .blank_minutes(blank_minutes_sub),
      .blank_seconds(blank_seconds_sub)
  );

  assign pwm_out = ($unsigned(count) < $unsigned(OffCount));

  assign blank_hours = blank_hours_sub || !pwm_out;
  assign blank_minutes = blank_minutes_sub || !pwm_out;
  assign blank_seconds = blank_seconds_sub || !pwm_out;

  assign rst = brightness != prev_brightness;
  assign brightness = sw[9:8];


endmodule
