`timescale 1ns/1ps
module counter_modulator #(
    parameter PERIOD = 60
)(
    input  wire        clk,
    input  wire        sd_bs,   // sigma-delta bitstream (0/1)
    output reg         count
);

    localparam WIDTH = 6;

    reg [WIDTH-1:0] sum;          // accumulates ones within window
    reg [WIDTH-1:0] period_cnt;   // counts 0..PERIOD-1
    reg [WIDTH-1:0] phase;        // PWM phase counter 0..PERIOD-1
    reg [WIDTH-1:0] latched_sum;  // duty for the current window (0..PERIOD)
    initial begin
        sum = 0;
        period_cnt = 0;
        latched_sum = 0;
    end

    always @(posedge clk) begin

        if(period_cnt == PERIOD-1) begin
            latched_sum <= sum + sd_bs;
            sum         <= 0;
            period_cnt  <= 0;
        end else begin
            sum <= sum + sd_bs;
            period_cnt <= period_cnt + 1;

        end
        count <= (period_cnt < latched_sum);

    end

endmodule
