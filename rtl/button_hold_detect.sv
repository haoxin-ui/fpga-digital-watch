// The output held is asserted on the clock edge at which button has been sampled high for
// HOLD_CYCLES consecutive rising edges, and deasserts on the clock edge after button goes
// low

`timescale 1ns/1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic held
);

localparam int CountMax = HOLD_CYCLES;
localparam int CountWidth = $clog2(CountMax + 1);

logic count_rst;
logic count_enable;
logic [CountWidth -1:0] count;

mod_n_counter #(
    .N(CountMax +1),
    .WIDTH(CountWidth)
) u_counter (
    .clk(clk),
    .rst(count_rst),
    .enable(count_enable),
    .count(count)
);

assign held = (count == CountWidth'(CountMax));

always_comb begin
    count_rst = ~button;

    if (button && !held) begin
        count_enable = 1'b1;
    end else begin
        count_enable = 1'b0;
    end
end


endmodule
