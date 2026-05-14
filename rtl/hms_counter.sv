
// When enable is low, all outputs retain their values.
// When enable is high, seconds increments on each rising clock edge. On a seconds rollover
// (when seconds is at N_SECONDS-1 and enable is high), seconds wraps to zero and minutes
// increments. Likewise, on a minutes rollover, minutes wraps to zero and hours increments;
// on an hours rollover, hours wraps to zero


`timescale 1ns/1ps

module hms_counter #(
    parameter int N_HOURS = 24, // number of hours
    parameter int N_MINUTES = 60, // number of minutes
    parameter int N_SECONDS = 60, // number of seconds

    // Output port widths
    parameter int W_HOURS = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk ,
    input logic enable ,
    output logic [W_HOURS -1:0] hours ,
    output logic [W_MINUTES -1:0] minutes ,
    output logic [W_SECONDS -1:0] seconds
);

logic second_rollover, minute_rollover;

localparam logic [W_MINUTES -1:0] MaxMinutes = W_MINUTES'(N_MINUTES -1);
localparam logic [W_SECONDS -1:0] MaxSeconds = W_SECONDS'(N_SECONDS -1);

assign second_rollover = enable && (seconds == MaxSeconds);
assign minute_rollover = second_rollover && (minutes == MaxMinutes);

up_down_counter #(
    .MAX(N_SECONDS -1 ), 
    .WIDTH(W_SECONDS)
) u_second (
    .clk(clk), .enable(enable), .up(1'b1), .count(seconds)
);
up_down_counter #(
    .MAX(N_MINUTES-1),
    .WIDTH(W_MINUTES)
) u_minute(
    .clk(clk), .enable(second_rollover), .up(1'b1), .count(minutes)
);
up_down_counter #(
    .MAX(N_HOURS-1),
    .WIDTH(W_HOURS)
) u_hour(
    .clk(clk), .enable(minute_rollover), .up(1'b1), .count(hours)
);

endmodule

