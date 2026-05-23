`timescale 1ns / 1ps

module user_top_watch_v1 #(
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

  logic seconds_tick;
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic seconds_rollover;
  logic minutes_rollover;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_seconds_rate (
      .clk(clk),
      .run(1'b1),
      .tick(seconds_tick)
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

  assign blank_seconds = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_hours = 1'b0;

endmodule
