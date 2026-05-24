// It is assumed that the instantiating module will use rising-edge detectors, so the two in-
// puts are single-cycle pulses, each high for exactly one clock cycle when the corresponding
// button is pressed.
// The module implements the FSM described implicitly in Section 4.1. The following
// additional constraints apply.
// All outputs are initialised to 0.
// The counter_rst output is high for exactly one clock cycle when asserted: as soon as
// rise_lap falls, the FSM exits the Reset state


`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);


endmodule
