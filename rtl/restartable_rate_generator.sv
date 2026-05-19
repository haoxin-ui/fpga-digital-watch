// When run is low, tick goes low.
// When run is high:
// •After run has been high for exactly CYCLE_COUNT-1 rising edges, tick is high for
// exactly one clock cycle.
// •Thereafter, after each period of run having remained high for CYCLE_COUNT rising
// edges, tick is again high for exactly one clock cycle.
// The edge case CYCLE_COUNT = 1 is supported: tick follows run directly.
// The module is to be implemented as a Moore FSM.
// 22 Version 1.1


`timescale 1ns/1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT=2
)(
    input logic clk,
    input logic run,
    output logic tick
);

logic tick_qulifier;
logic running = 1'b0;
always_ff @(posedge clk) running <= run;

assign tick = running && tick_qulifier;

generate
    if (CYCLE_COUNT > 1) begin : g_general
        localparam int CountWidth = $clog2(CYCLE_COUNT);

        logic rst_count;
        logic enable_count;
        logic [CountWidth - 1:0] count;

        mod_n_counter #(
            .N(CYCLE_COUNT),
            .WIDTH(CountWidth)
        )u_count(
            .clk(clk),
            .rst(rst_count),
            .enable(enable_count),
            .count(count)
        );

        assign rst_count = ~run;
        assign enable_count = run;
        assign tick_qulifier = (count == CountWidth'(CYCLE_COUNT-1));

    end else begin : g_special
        assign tick_qulifier = 1'b1;

    end
endgenerate


endmodule


