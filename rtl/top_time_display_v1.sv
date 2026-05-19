// This top-level module for the DE1-SoC board displays the time on the seven-segment
// displays, initialised to 00:00:00, with the tick rate controlled by SW[1:0]
// SW[1:0] Tick Rate
// 2’b00    1 Hz
// 2’b01    25 Hz
// 2’b10    1 kHz
// 2’b11    50 MHz

`timescale 1ns/1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

logic [4:0] hour;
logic [5:0] min;
logic [5:0] sec;

logic enable;

hms_counter hms_count(
    .clk(CLOCK_50), .enable(enable), .hours(hour), .minutes(min), .seconds(sec)
    );


logic tick_1hz, tick_25hz, tick_1khz;

restartable_rate_generator #(
    .CYCLE_COUNT(CYCLES_PER_SECOND/1_000)
)slow1 (
    .clk(CLOCK_50),
    .run(1'b1),
    .tick(tick_1khz)
);
restartable_rate_generator #(
    .CYCLE_COUNT(CYCLES_PER_SECOND/25)
)slow2 (
    .clk(CLOCK_50),
    .run(1'b1),
    .tick(tick_25hz)
);
restartable_rate_generator #(
    .CYCLE_COUNT(CYCLES_PER_SECOND)
)slow3 (
    .clk(CLOCK_50),
    .run(1'b1),
    .tick(tick_1hz)
);

always_comb begin
    unique case (SW)
        2'b00: enable = tick_1hz;
        2'b01: enable = tick_25hz;
        2'b10: enable = tick_1khz;
        2'b11: enable = 1'b1;
    endcase
end

logic [3:0] tens_hour, ones_hour, tens_min, ones_min, tens_sec, ones_sec;

binary_to_bcd bcd_hour (
    .bin({2'b0, hour}), .tens(tens_hour), .ones(ones_hour)
    );
binary_to_bcd bcd_min (
    .bin({1'b0, min}), .tens(tens_min), .ones(ones_min)
    );
binary_to_bcd bcd_sec (
    .bin({1'b0, sec}), .tens(tens_sec), .ones(ones_sec)
    );

seven_segment d_tens_hour (
    .digit(tens_hour),
    .blank(1'b0),
    .segments(HEX5)
);
seven_segment d_ones_hour (
    .digit(ones_hour),
    .blank(1'b0),
    .segments(HEX4)
);
seven_segment d_tens_min (
    .digit(tens_min),
    .blank(1'b0),
    .segments(HEX3)
);
seven_segment d_ones_min (
    .digit(ones_min),
    .blank(1'b0),
    .segments(HEX2)
);
seven_segment d_tens_sec (
    .digit(tens_sec),
    .blank(1'b0),
    .segments(HEX1)
);
seven_segment d_ones_sec (
    .digit(ones_sec),
    .blank(1'b0),
    .segments(HEX0)
);

endmodule
