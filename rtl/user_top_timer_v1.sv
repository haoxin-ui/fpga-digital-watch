// Dependencies Only the following modules are to be directly instantiated.
// • button_auto_repeat
// • edit_mode_selector
// • editable_countdown
// • pwm_generator
// • restartable_rate_generator
// • rising_edge_detector

`timescale 1ns / 1ps

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
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
  localparam int FLASHPERIOD = CYCLES_PER_SECOND / 2;
  localparam int FLASHHIGH = CYCLES_PER_SECOND / 10;
  localparam int EDITHOLD = CYCLES_PER_SECOND / 2;
  localparam int EDITREPEAT = CYCLES_PER_SECOND / 10;

  logic seconds_rate_tick;
  logic seconds_tick;
  logic clock_divider_run;
  logic start_stop_pulse;
  logic run_latched = 1'b0;
  logic running;
  logic inc_pulse;
  logic dec_pulse;
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;
  logic [2:0] edit_mode_enable;
  logic flash;
  logic in_edit_mode;
  logic at_zero;

  assign in_edit_mode = edit_mode_enable != 3'b000;
  assign at_zero = (hours == 5'd0) && (minutes == 6'd0) && (seconds == 6'd0);

  rising_edge_detector u_start_stop_button (
      .clk(clk),
      .sig_in(button[0]),
      .rise(start_stop_pulse)
  );

  always_ff @(posedge clk) begin
    if (in_edit_mode || at_zero) begin
      run_latched <= 1'b0;
    end else if (start_stop_pulse) begin
      run_latched <= !run_latched;
    end
  end

  assign running = run_latched && !in_edit_mode && !at_zero;
  assign clock_divider_run = running;
  assign seconds_tick = seconds_rate_tick && running;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_seconds_rate (
      .clk (clk),
      .run (clock_divider_run),
      .tick(seconds_rate_tick)
  );

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode (
      .clk(clk),
      .button(button[3]),
      .mode_enable(edit_mode_enable)
  );

  pwm_generator #(
      .PERIOD_CYCLES(FLASHPERIOD),
      .DUTY_CYCLES  (FLASHHIGH)
  ) u_flash (
      .clk(clk),
      .rst(edit_mode_enable == 3'b000),
      .pwm_out(flash)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (EDITHOLD),
      .REPEAT_CYCLES(EDITREPEAT)
  ) u_inc_button (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (EDITHOLD),
      .REPEAT_CYCLES(EDITREPEAT)
  ) u_dec_button (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );


  logic seconds_rollover, minute_rollover, hours_borrow_unused;
  logic clr = 1'b0;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(clr),
      .tick(seconds_tick),
      .edit_mode(edit_mode_enable[0]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(seconds),
      .borrow_out(seconds_rollover)
  );

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(clr),
      .tick(seconds_rollover),
      .edit_mode(edit_mode_enable[1]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(minutes),
      .borrow_out(minute_rollover)
  );

  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .clr(clr),
      .tick(minute_rollover),
      .edit_mode(edit_mode_enable[2]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(hours),
      .borrow_out(hours_borrow_unused)
  );

  assign led = sw;
  assign seconds_disp = {1'b0, seconds};
  assign minutes_disp = {1'b0, minutes};
  assign hours_disp = {2'b00, hours};

  assign blank_seconds = (edit_mode_enable[0] && flash) || (button[2] && 1'b0);
  assign blank_minutes = edit_mode_enable[1] && flash;
  assign blank_hours = (edit_mode_enable[2] && flash) || (hours_borrow_unused && 1'b0);



`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = edit_mode_enable;
`endif
endmodule
