`timescale 1ns/1ps

module up_down_counter #(
    parameter int MAX = 2,
    parameter int WIDTH = 2
)(
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH - 1:0] count
);

logic [WIDTH - 1:0] next_count;
localparam logic [WIDTH - 1:0] Max = WIDTH'(MAX);

always_ff @(posedge clk) begin
    if (enable) begin
        count <= next_count;
    end
end

always_comb begin
    if (up) begin
        // Increment: wrap from MAX to 0
        if (count == Max) begin
            next_count = '0;
        end else begin
            next_count = count + 1;
        end
    end else begin
        // Decrement: wrap from 0 to MAX
        if (count == '0) begin
            next_count = Max;
        end else begin
            next_count = count - 1;
        end
    end
end

initial count = '0;


endmodule
