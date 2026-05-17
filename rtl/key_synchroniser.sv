// Key Synchroniser
//  Pases key state through 2 registers to stabilise the result
//
// Ports:
//  clk            : The system clock for synchronisation
//  key_n [3:0]    : The non-inverted normally on key state signal
//  key_sync [3:0] : The clocked inverted key state register
//
`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,
    output logic [3:0] key_sync
);
  logic [3:0] key = 4'b0;
  logic [3:0] key_sync_next = 4'b0;

  always_ff @(posedge clk) begin
    key <= ~key_n;
    key_sync_next <= key;
  end

  assign key_sync = key_sync_next;

endmodule
