// Restartable rate generator
//  Produces a clock cylce long pulse after a sepcified number of clock cycles
//
// Parameter:
//  CYCLE_COUNT : The number of cycles between pulses
//
// Ports:
//  clk  : Clock sugnal input
//  run  : Enables the counter. 1 for enable, disabled and reset otherwise.
//  tick : Pulse output (One clock cycle)
//
`timescale 1ns / 1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  logic tick_qualifier;
  logic running = 1'b0;

  always_ff @(posedge clk) running <= run;

  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      localparam int CountWidth = $clog2(CYCLE_COUNT);
      localparam logic [CountWidth-1:0] Max = CountWidth'(CYCLE_COUNT - 1);

      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;

      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      assign rst_count = !run;
      assign enable_count = run;
      assign tick_qualifier = (count == Max);
    end else begin : g_special
      assign tick_qualifier = 1'b1;
    end
  endgenerate
endmodule
