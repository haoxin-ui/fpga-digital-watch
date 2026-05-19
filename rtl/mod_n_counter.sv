// The output count is initially zero.
// On a rising clock edge, rst takes priority over enable: a high rst clears count regardless
// of enable.
// If only enable is high, count advances. When it reaches N −1, the next enabled edge
// wraps it back to zero; otherwise it increments by one.


`timescale 1ns/1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk ,
    input logic rst ,
    input logic enable ,
    output logic [WIDTH -1:0] count
);

logic [WIDTH - 1:0] next_count;
localparam logic [WIDTH - 1:0] Max = WIDTH'(N-1);


always_ff @(posedge clk) begin
    if (rst) count <= '0;
    else if (enable) count <= next_count;
end


always_comb begin
    // Increment: wrap from N to 0
    if (count == Max) begin
        next_count = '0;
    end else begin
        next_count = count + 1;
    end

end

initial count = '0;



endmodule
