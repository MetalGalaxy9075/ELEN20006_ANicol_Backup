
`timescale 1ns / 1ps

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
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
  localparam logic [1:0] Stopped = 2'b00;
  localparam logic [1:0] Set = 2'b01;
  localparam logic [1:0] Running = 2'b11;

  // ------------------
  // Core Functionality
  // ------------------

  logic run;
  logic tick;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_second_rate_generator (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  logic [4:0] hours;
  logic hours_edit;
  logic hours_tick;
  /* verilator lint_off UNUSED */
  logic hours_borrow;
  /* verilator lint_on UNUSED */
  logic hours_inc;
  logic hours_dec;
  logic clr;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours_counter (
      .clk(clk),
      .clr(clr),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .borrow_out(hours_borrow)
  );

  logic [5:0] minutes;
  logic minutes_edit;
  logic minutes_tick;
  logic minutes_borrow;
  logic minutes_inc;
  logic minutes_dec;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes_counter (
      .clk(clk),
      .clr(clr),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );


  logic [5:0] seconds;
  logic seconds_edit;
  logic seconds_tick;
  logic seconds_borrow;
  logic seconds_inc;
  logic seconds_dec;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds_counter (
      .clk(clk),
      .clr(clr),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );

  // ------------------
  // Mode Selection
  // ------------------

  logic all_zeros;
  logic [1:0] state = Stopped;
  logic [1:0] next_state;
  always_comb begin
    case (state)
      Stopped: begin
        if (edit_hms != 3'b000) next_state = Set;
        else if (mode_change_pulse) next_state = Running;
        else next_state = Stopped;
      end
      Set: next_state = (edit_hms == 3'b000) ? Stopped : Set;
      Running: begin
        if (mode_change_pulse) next_state = Stopped;
        else if (all_zeros) next_state = Stopped;
        else next_state = Running;
      end
      default: next_state = Stopped;
    endcase
  end

  always_ff @(posedge clk) begin
    if (all_zeros) state <= Stopped;
    else state <= next_state;
  end

  logic [2:0] edit_hms_q;

  always_ff @(posedge clk) edit_hms_q <= edit_hms;

  // Button[0] RED for proper next state logic behaviour
  logic mode_change_pulse;
  rising_edge_detector u_mode_change_detect (
      .clk(clk),
      .sig_in(button[0]),
      .rise(mode_change_pulse)
  );

  logic [2:0] edit_hms;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND - 1)
  ) u_edit_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(edit_hms)
  );

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2) / 1.25)
  ) u_edit_flash (
      .clk(clk),
      .rst(edit_hms_q != edit_hms),
      .pwm_out(pwm_out)
  );

  // ------------------
  // Edit Logic
  // ------------------

  // incrementing auto pulse
  logic inc_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc_pulse_gen (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  // decrementing auto pulse
  logic dec_pulse;
  logic dec_enable;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec_pulse_gen (
      .clk(clk),
      .button(button[0] & dec_enable),
      .pulse(dec_pulse)
  );

  // -------------------
  // Assigning variables
  // -------------------

  assign dec_enable = !mode_change_pulse;  // block conflict

  assign hours_edit = (edit_hms == 3'b100);
  assign minutes_edit = (edit_hms == 3'b010);
  assign seconds_edit = (edit_hms == 3'b001);

  assign seconds_inc = inc_pulse && seconds_edit;
  assign seconds_dec = dec_pulse && seconds_edit;
  assign minutes_inc = inc_pulse && minutes_edit;
  assign minutes_dec = dec_pulse && minutes_edit;
  assign hours_inc = inc_pulse && hours_edit;
  assign hours_dec = dec_pulse && hours_edit;

  assign blank_hours = pwm_out && hours_edit;
  assign blank_minutes = pwm_out && minutes_edit;
  assign blank_seconds = pwm_out && seconds_edit;

  assign seconds_tick = tick && (state == Running) && !all_zeros;
  assign minutes_tick = seconds_borrow && (state == Running) && !all_zeros;
  assign hours_tick = minutes_borrow && (state == Running) && !all_zeros;

  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  assign clr = 1'b0;
  assign run = (state == Running) && (edit_hms == 3'b000);
  assign all_zeros = (seconds == '0 && minutes == '0 && hours == '0);

  assign led = 10'b0;


`ifdef FORMAL
  // Note that the running state variable has a clock cycle delay.
  // Other measures are in place to stop the counter as soon as the time hits 0
  assign probe_running = run;
  assign probe_mode_enable = edit_hms;
`endif
endmodule
