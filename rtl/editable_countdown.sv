// This module behaves like editable_counter from Assignment 1, with one change and two
// additions: count decrements on each tick pulse (wrapping from 0 to MAX); clr sets count
// to 0 on the next rising clock edge, taking priority over all other inputs; and borrow_out is
// a new combinational output mirroring the borrow output of the 74LS193, except that it
// is also low when edit_mode or clr is high. The count output is initialised to 0

`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH -1:0] count,
    output logic borrow_out
);

  logic enable;
  logic up;

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  assign up = edit_mode && inc_event;
  assign enable = edit_mode ? (inc_event ^ dec_event) : tick_event;
  assign borrow_out = tick_event && (count == '0) && !clr;
  // the current count is 0, and tick is enabled so next count is ensured to decrement,
  //and clr is low

endmodule
