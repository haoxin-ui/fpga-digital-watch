// The output pwm_out is periodic with a period of PERIOD_CYCLES clock cycles, high for the
// first DUTY_CYCLES cycles of each period and low for the remainder. When rst is asserted,
// the output restarts from the next rising clock edge

`timescale 1ns/1ps

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,

    parameter int DUTY_CYCLES = 25_000_000
) (
    input logic clk,
    input logic rst,
    output logic pwm_out
);

localparam int CountWidth = $clog2(PERIOD_CYCLES);
localparam int CompareWidth = CountWidth + 1;
logic [CountWidth -1:0] count;
logic [CompareWidth -1:0] compare_count;

mod_n_counter #(
    .N(PERIOD_CYCLES),
    .WIDTH(CountWidth)
) u_count(
    .clk(clk),
    .rst(rst),
    .enable(1'b1),
    .count(count)
);


assign compare_count = {1'b0, count};
assign pwm_out = (compare_count < CompareWidth'(DUTY_CYCLES));

endmodule
