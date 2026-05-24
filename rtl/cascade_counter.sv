// All outputs are initialised to 0.
// When rst is high, all outputs are set to 0 on the next rising clock edge, regardless of
// enable.
// When rst is low and enable is low, all outputs are unchanged.
// 19 Version 1.0
// When rst is low and enable is high, count0 increments on each rising clock edge, wrapping
// from N0-1 to 0. When count0 wraps, count1 increments, wrapping from N1-1 to 0. When
// count1 wraps, count2 increments, wrapping from N2-1 to 0.

//mod_n_counter not needed as implementation is starightforawrd and easy

`timescale 1ns / 1ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2 -1:0] count2,
    output logic [W1 -1:0] count1,
    output logic [W0 -1:0] count0
);

  initial begin
    count2 = '0;
    count1 = '0;
    count0 = '0;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      count2 <= '0;
      count1 <= '0;
      count0 <= '0;
    end else if (enable) begin
      if (count0 == N0 - 1) begin
        count0 <= '0;

        if (count1 == N1 - 1) begin
          count1 <= '0;

          if (count2 == N2 - 1) begin
            count2 <= '0;
          end else begin
            count2 <= count2 + 1'b1;
          end
        end else begin
          count1 <= count1 + 1'b1;
        end

      end else begin
        count0 <= count0 + 1'b1;

      end
    end

  end





endmodule
