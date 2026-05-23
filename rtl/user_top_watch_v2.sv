`timescale 1ns / 1ps

module user_top_watch_v2 #(
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

  localparam int FLASH_PERIOD = CYCLES_PER_SECOND / 2;
  localparam int FLASH_HIGH = CYCLES_PER_SECOND / 10;

  logic seconds_tick;
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;
  logic [2:0] mode_enable;
  logic flash;

  logic seconds_rollover;
  logic minutes_rollover;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_seconds_rate (
      .clk(clk),
      .run(1'b1),
      .tick(seconds_tick)
  );

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  pwm_generator #(
      .PERIOD_CYCLES(FLASH_PERIOD),
      .DUTY_CYCLES(FLASH_HIGH)
  ) u_flash (
      .clk(clk),
      .rst(mode_enable == 3'b000),
      .pwm_out(flash)
  );

  assign seconds_rollover = seconds_tick && (seconds == 6'd59);
  assign minutes_rollover = seconds_rollover && (minutes == 6'd59);

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(1'b0),
      .inc(1'b0),
      .dec(1'b0),
      .count(seconds)
  );

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(seconds_rollover),
      .edit_mode(1'b0),
      .inc(1'b0),
      .dec(1'b0),
      .count(minutes)
  );

  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(minutes_rollover),
      .edit_mode(1'b0),
      .inc(1'b0),
      .dec(1'b0),
      .count(hours)
  );

  assign led = sw;
  assign seconds_disp = {1'b0, seconds};
  assign minutes_disp = {1'b0, minutes};
  assign hours_disp = {2'b00, hours};

  assign blank_seconds = mode_enable[0] && flash;
  assign blank_minutes = mode_enable[1] && flash;
  assign blank_hours = mode_enable[2] && flash;

endmodule
