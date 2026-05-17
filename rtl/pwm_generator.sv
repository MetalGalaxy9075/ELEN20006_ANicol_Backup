// PWM signal generator
//  Creates a signal that stays high for a specified duty cycle and
//  repeats at a specified period
//
// Parameter:
//  PERIOD_CYCLES : Number of clock cycles per period
//  DUTY_CYCLES   : Number of clock cycles the signal shoudl remain on
//
//  W_HOURS   : Bit width of hours register
//  W_MINUTES : Bit width of minutes register
//  W_SECONDS : Bit width of seconds register
//
// Ports:
//  clk     : Input for clock signal 
//  rst     : Resets the counter to zero when pulled high
//  pwm_out : The output PWM signal
// 
`timescale 1ns / 1ps

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);
  localparam int MaxWidth = $clog2(PERIOD_CYCLES + 1);
  localparam logic [MaxWidth-1:0] OffCount = MaxWidth'(DUTY_CYCLES);

  logic [MaxWidth-1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(MaxWidth)
  ) period_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );



  assign pwm_out = ($unsigned(count) < $unsigned(OffCount));

endmodule
