// When hold is low, q equals d combinatorially — there is no clock edge involved; any
// change in d propagates to q immediately.
// When hold is high, q is frozen at the value d held on the last rising clock edge before hold
// went high

`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH -1:0] d,
    output logic [WIDTH -1:0] q
);

  logic [WIDTH-1:0] snapshot = '0;

  always_ff @(posedge clk) begin
    if (!hold) begin
      snapshot <= d;
    end
  end

  always_comb begin
    if (hold) begin
      q = snapshot;
    end else begin
      q = d;
    end
  end

endmodule
