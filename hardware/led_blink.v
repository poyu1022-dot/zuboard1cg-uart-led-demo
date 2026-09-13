`timescale 1ns / 1ps

// Alternately blinks User RGB LEDs D4 and D5 (green channel) at ~1 Hz toggle rate.
// clk is the PL fabric clock (pl_clk0, ~100 MHz), resetn is active-low.
module led_blink #(
    parameter integer CLK_FREQ_HZ = 100_000_000
) (
    input  wire clk,
    input  wire resetn,
    output wire led_d4_r,
    output wire led_d4_g,
    output wire led_d4_b,
    output wire led_d5_r,
    output wire led_d5_g,
    output wire led_d5_b
);

    reg [26:0] counter = 27'd0;
    reg        toggle  = 1'b0;

    always @(posedge clk) begin
        if (!resetn) begin
            counter <= 27'd0;
            toggle  <= 1'b0;
        end else if (counter == CLK_FREQ_HZ - 1) begin
            counter <= 27'd0;
            toggle  <= ~toggle;
        end else begin
            counter <= counter + 27'd1;
        end
    end

    // D4 and D5 alternate: when D4 is lit, D5 is off, and vice versa.
    assign led_d4_r = 1'b0;
    assign led_d4_g = toggle;
    assign led_d4_b = 1'b0;

    assign led_d5_r = 1'b0;
    assign led_d5_g = ~toggle;
    assign led_d5_b = 1'b0;

endmodule
