// The output rise is asserted immediately when sig_in transitions from low to high, and
// deasserted as soon as sig_in returns low or the next rising clock edge captures the high
// value, whichever comes first

`timescale 1ns/1ps

module rising_edge_detector(
    input logic clk,
    input logic sig_in,
    output logic rise
);
logic prev_sig;

always_ff @(posedge clk) begin
    prev_sig <= sig_in;
end

always_comb begin
    rise = sig_in && !prev_sig;
end


endmodule
