`timescale 1ns/1ps
module modulator #(
    parameter WIDTH = 16,       // Integrator bit width
    parameter THRESHOLD = 32  // Comparator threshold
)(
    input  wire              clk,
    input  wire              sd_bs,   // Sigma-delta bitstream (0 or 1)
    output reg               pwm
);
j
    // First integrator
    reg signed [WIDTH-1:0] int1;
    // Second integrator
    reg signed [WIDTH-1:0] int2;
    // Error signal
    reg signed [WIDTH-1:0] error;


    initial begin
        int1 = 0;
        int2 = 0;
        pwm = 0;
    end

    always @(posedge clk) begin

            // Integrate the sigma-delta input
            int1 <= int1 + (sd_bs ?    16'sd1 : - 16'sd1 );

            // Comparator for PWM generation
            // Integrate the PWM output (convert to -1/+1 for symmetry)

            int2 <= int2 + (pwm ? 16'sd1: -16'sd1);

            // Error = int1 - int2
            error <= int1 - int2;

            // Optional: adjust pwm using error feedback
            if (error > THRESHOLD)
                pwm <= 1'b1;
            else if (error < THRESHOLD)
                pwm <= 1'b0;


    end

endmodule
