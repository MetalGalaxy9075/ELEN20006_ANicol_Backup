// Stopwatch control
//  State machine defining behavior of stopwatch system given a start/stop and 
//  lap input.
//
// Ports:
//  clk             : System clock signal
//  rise_start_stop : Start stop signal
//  rise_lap        : Lap signa
//  counter_rst     : Reset (pulled high for counter reset)
//  counter_enable  : Enable (pulled high to enable counting)
//  lap_hold        : Hold (enables freeze multiplexer)
//
`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);
  localparam logic [2:0] RunningEnabled = 3'b010;
  localparam logic [2:0] RunningDisabled = 3'b000;
  localparam logic [2:0] FreezeEnabled = 3'b011;
  localparam logic [2:0] FreezeDisabled = 3'b001;
  localparam logic [2:0] Reset = 3'b100;

  logic [2:0] state;
  logic [2:0] next_state;

  initial state = 3'b0;


  always_comb begin
    next_state = 3'b0;
    case (state)
      RunningEnabled: begin
        if (rise_start_stop & !rise_lap) next_state = RunningDisabled;
        else if (!rise_start_stop & rise_lap) next_state = FreezeEnabled;
        else next_state = RunningEnabled;
      end
      RunningDisabled: begin
        if (rise_start_stop & !rise_lap) next_state = RunningEnabled;
        else if (!rise_start_stop & rise_lap) next_state = Reset;
        else next_state = RunningDisabled;
      end
      FreezeEnabled: begin
        if (rise_start_stop & !rise_lap) next_state = FreezeDisabled;
        else if (!rise_start_stop & rise_lap) next_state = RunningEnabled;
        else next_state = FreezeEnabled;
      end
      FreezeDisabled: begin
        if (rise_start_stop & !rise_lap) next_state = FreezeEnabled;
        else if (!rise_start_stop & rise_lap) next_state = RunningDisabled;
        else next_state = FreezeDisabled;
      end
      Reset: begin
        if (rise_start_stop & !rise_lap) next_state = RunningEnabled;
        else if (!rise_start_stop & rise_lap) next_state = RunningDisabled;
        else next_state = RunningDisabled;
      end
      default: next_state = RunningDisabled;
    endcase
  end

  always_ff @(posedge clk) begin
    state <= next_state;
  end

  assign {counter_rst, counter_enable, lap_hold} = state;

  // Pressing start stop toggles stopwatch b/t running and stopped
  // If running with live display, lap freezes the display
  // If running with a frozen display, lap unfreezes the display
  // If stopped with a frozen display, lap unfreezes the display (no rst)
  // While stopped with a live display, lap resets time to 0
  // If both buttons are pressed, then both are ignored

endmodule
