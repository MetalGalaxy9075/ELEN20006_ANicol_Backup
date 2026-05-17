// Cascade counter
//  3 time cascade timer for the stopwatch. No edit function included
//
// Parameters:
//  N2 : Slowest incrementing counter max
//  N1 : Middle incrementing counter max
//  N0 : Fastest incrementing counter max
//  W2 : Slowest incrementing counter bit width
//  W1 : Middle incrementing counter bit width
//  W0 : Fastest incrementing counter bit width
//
//  Ports:
//  clk             : System clock input
//  rst             : Resets all timers to 0 when pulled high
//  enable          : Enables counting action
//  count2 [W2-1:0] : Count value of the slowest counter
//  count1 [W1-1:0] : Count value of the middle counter
//  count0 [W0-1:0] : Count value of the fastest counter
//

`timescale 1ns / 1ps


module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,
    parameter int W2 = 3,
    parameter int W1 = 3,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);

  localparam logic [W0-1:0] Max0 = W0'(N0 - 1);
  localparam logic [W1-1:0] Max1 = W1'(N1 - 1);
  //localparam logic [W2-1:0] Max2 = W2'(N2 - 1);

  logic rollover_0, rollover_1;
  assign rollover_0 = (count0 == Max0) && enable;
  assign rollover_1 = (count1 == Max1) && rollover_0;

  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) u_0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );
  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) u_1 (
      .clk(clk),
      .rst(rst),
      .enable(rollover_0),
      .count(count1)
  );
  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) u_2 (
      .clk(clk),
      .rst(rst),
      .enable(rollover_1),
      .count(count2)
  );

endmodule
