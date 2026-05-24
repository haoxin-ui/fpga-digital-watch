// ------------------------------------------------------------------
// Dependencies Only the following modules are to be directly instantiated.
// • rising_edge_detector
// • snapshot_mux
// • stopwatch_control
// • stopwatch_counter
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
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

  logic button0;
  logic button1;

  rising_edge_detector u_button0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(button0)
  );

  rising_edge_detector u_button1 (
      .clk(clk),
      .sig_in(button[1]),
      .rise(button1)
  );

  logic counter_rst, counter_enable, lap_hold;

  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(button0),
      .rise_lap(button1),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  localparam int MINUTES_CENTISECONDS_WIDTH = 7;
  localparam int SECONDS_WIDTH = 6;

  logic [MINUTES_CENTISECONDS_WIDTH-1:0] mins, centiseconds;
  logic [SECONDS_WIDTH-1:0] secs;
  logic [MINUTES_CENTISECONDS_WIDTH-1:0] show_mins, show_centiseconds;
  logic [SECONDS_WIDTH-1:0] show_secs;

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(mins),
      .seconds(secs),
      .centiseconds(centiseconds)
  );

  snapshot_mux #(
      .WIDTH(MINUTES_CENTISECONDS_WIDTH)
  ) u_centiseconds_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(centiseconds),
      .q(show_centiseconds)
  );

  snapshot_mux #(
      .WIDTH(SECONDS_WIDTH)
  ) u_seconds_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(secs),
      .q(show_secs)
  );

  snapshot_mux #(
      .WIDTH(MINUTES_CENTISECONDS_WIDTH)
  ) u_minutes_snapshot (
      .clk(clk),
      .hold(lap_hold),
      .d(mins),
      .q(show_mins)
  );

  assign led = sw;
  assign seconds_disp = show_centiseconds;
  assign minutes_disp = {1'b0, show_secs};
  assign hours_disp = show_mins;
  assign blank_hours = button[2] & 1'b0;
  assign blank_minutes = button[3] & 1'b0;
  assign blank_seconds = 1'b0;

endmodule
