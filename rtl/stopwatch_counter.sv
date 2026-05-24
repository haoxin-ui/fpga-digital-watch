// All outputs are initialised to 0.
// When rst is high, all outputs are set to 0 on the next rising clock edge, regardless of
// enable.
// When rst is low and enable is low, all outputs are unchanged.
// When rst is low and enable is high, centiseconds increments once per centisecond, wrap-
// ping from 99 to 0. When centiseconds wraps, seconds increments, wrapping from 59 to
// 0. When seconds wraps, minutes increments, wrapping from 99 to 0. The first increment
// must occur one centisecond after enable goes high, not sooner

`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // Takes priority over enable
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);

  localparam int CSWidth = 7;
  localparam int SWidth = 6;
  localparam int MWidth = 7;

  logic counter_enable;

  assign counter_enable = enable && tick && !rst;

  cascade_counter #(
      .N0(100),
      .N1(60),
      .N2(100),

      .W0(CSWidth),
      .W1(SWidth),
      .W2(MWidth)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(counter_enable),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

  logic tick;
  localparam int CYCLE = CYCLES_PER_SECOND / 100;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLE)
  ) arm_generator (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );


endmodule
