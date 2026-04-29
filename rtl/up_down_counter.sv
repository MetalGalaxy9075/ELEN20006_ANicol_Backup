`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  localparam logic [WIDTH-1:0] One = WIDTH'(1);
  localparam logic [WIDTH-1:0] Zero = WIDTH'(0);

  logic [WIDTH-1:0] next_count;

  initial count = '0;

  always_ff @(posedge clk) begin
    if (enable) count <= next_count;
  end
  always_comb begin
    if (up) next_count = (count < Max) ? count + One : Zero;
    else if (!up) next_count = (count > Zero) ? count - One : Max;
    else next_count = count;
  end
endmodule
