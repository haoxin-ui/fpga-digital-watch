// This module operates bitwise: each input bit is inverted then synchronised through a
// two-stage flip-flop cascade, with both stages initialised to zero

`timescale 1ns/1ps

module key_synchroniser(
    input logic clk,
    input logic [3:0] key_n,
    output logic [3:0] key_sync
);

logic [3:0] stage1 = 4'b0000;
logic [3:0] stage2 = 4'b0000;

always_ff @(posedge clk) begin
    stage1 <= ~key_n;
    stage2 <= stage1;

end

assign key_sync = stage2;

endmodule
