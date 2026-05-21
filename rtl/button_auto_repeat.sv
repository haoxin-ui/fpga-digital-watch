// The two internal signals, rise and pulse_train, are derived as follows.
// •button → rising_edge_detector → rise
// •button → button_hold_detect → restartable_rate_generator → pulse_train
// A brief press produces an immediate pulse; holding the button produces a pulse train.
// The first pulse of the pulse train occurs after button has been sampled high for HOLD_CYCLES
// consecutive rising edges; subsequent pulses repeat every REPEAT_CYCLES rising edges.

// Rationale 
// When editing the watch, a brief press should advance the time by one step;
// holding the button should produce rapid repeated advances. This module provides both
// behaviourss

`timescale 1ns/1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES = 50_000_000,

    //REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input logic clk,
    input logic button,
    output logic pulse
);

logic rise;
logic held;
logic pulse_train;

assign pulse = rise | (button & pulse_train);

button_hold_detect #(
    .HOLD_CYCLES(HOLD_CYCLES-REPEAT_CYCLES+1)
) u_detect (
    .clk(clk),
    .button(button),
    .held(held)
);

rising_edge_detector u_detector(
    .clk(clk),
    .sig_in(button),
    .rise(rise)
);

restartable_rate_generator #(
    .CYCLE_COUNT(REPEAT_CYCLES)
) u_gen (
    .clk(clk),
    .run(held),
    .tick(pulse_train)
);

endmodule
