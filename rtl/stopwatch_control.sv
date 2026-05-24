`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  typedef enum logic [2:0] {
    REST,
    STOPPED,
    RUNNING,
    LAP_RUNNING,
    LAP_STOPPED
  } state_t;

  state_t state, next_state;

  initial begin
    state = STOPPED;
  end

  always_ff @(posedge clk) begin
    state <= next_state;
  end

  always_comb begin
    next_state = state;

    case (state)

      REST: begin
        if (rise_start_stop && rise_lap) begin
          next_state = STOPPED;
        end else if (rise_start_stop) begin
          next_state = RUNNING;
        end else begin
          next_state = STOPPED;
        end
      end

      STOPPED: begin
        if (rise_start_stop && rise_lap) begin
          next_state = STOPPED;
        end else if (rise_lap) begin
          next_state = REST;
        end else if (rise_start_stop) begin
          next_state = RUNNING;
        end
      end

      RUNNING: begin
        if (rise_start_stop && rise_lap) begin
          next_state = RUNNING;
        end else if (rise_lap) begin
          next_state = LAP_RUNNING;
        end else if (rise_start_stop) begin
          next_state = STOPPED;
        end
      end

      LAP_RUNNING: begin
        if (rise_start_stop && rise_lap) begin
          next_state = LAP_RUNNING;
        end else if (rise_lap) begin
          next_state = RUNNING;
        end else if (rise_start_stop) begin
          next_state = LAP_STOPPED;
        end
      end

      LAP_STOPPED: begin
        if (rise_start_stop && rise_lap) begin
          next_state = LAP_STOPPED;
        end else if (rise_lap) begin
          next_state = STOPPED;
        end else if (rise_start_stop) begin
          next_state = LAP_RUNNING;
        end
      end

      default: begin
        if (rise_start_stop && rise_lap) begin
          next_state = STOPPED;
        end else if (rise_lap) begin
          next_state = REST;
        end else if (rise_start_stop) begin
          next_state = RUNNING;
        end else begin
          next_state = STOPPED;
        end
      end

    endcase
  end

  always_comb begin
    counter_rst    = 1'b0;
    counter_enable = 1'b0;
    lap_hold       = 1'b0;

    case (state)

      REST: begin
        counter_rst    = 1'b1;
        counter_enable = 1'b0;
        lap_hold       = 1'b0;
      end

      STOPPED: begin
        counter_rst    = 1'b0;
        counter_enable = 1'b0;
        lap_hold       = 1'b0;
      end

      RUNNING: begin
        counter_rst    = 1'b0;
        counter_enable = 1'b1;
        lap_hold       = 1'b0;
      end

      LAP_RUNNING: begin
        counter_rst    = 1'b0;
        counter_enable = 1'b1;
        lap_hold       = 1'b1;
      end

      LAP_STOPPED: begin
        counter_rst    = 1'b0;
        counter_enable = 1'b0;
        lap_hold       = 1'b1;
      end

      default: begin
        // Invalid encodings are treated like STOPPED for outputs.
        counter_rst    = 1'b0;
        counter_enable = 1'b0;
        lap_hold       = 1'b0;
      end

    endcase
  end

endmodule
