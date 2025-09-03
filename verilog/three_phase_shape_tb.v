`timescale 1us/1ns
module three_phase_shape(
    clk, omega, phaseA, phaseB, phaseC, phaseAx, phaseBx, phaseCx, pwmA, pwmB, pwmC, countA, countB, countC);

// Parameter declarations
parameter SD_IN_BW = 16;                        // Sigma-delta input bitwidth
parameter INT_SCALE = 20;                       // Integration scaling (for high clock)
parameter OMEGA_BW = 16;                        // Omega input bitwidth
localparam REG_BW = SD_IN_BW + INT_SCALE + 1;   // Internal register width

// IO declarations

input clk;
input signed [OMEGA_BW-1:0] omega;   // Frequency input
output phaseA, phaseB, phaseC;       // 1-bit outputs for each phase
output signed [SD_IN_BW-1:0] phaseAx, phaseBx, phaseCx; // Debug high-res outputs
output pwmA, pwmB, pwmC;
output countA, countB, countC;
// Internal signals

wire signed [SD_IN_BW-1:0] sd_in_0, sd_in_1, sd_in_2;
wire signed [REG_BW-1:0] omega_gain;
wire signed [REG_BW-1:0] fbA, fbB, fbC;
wire signed [REG_BW-1:0] next_f0, next_f1, next_f2;

// State registers
reg signed [REG_BW-1:0] f0, f1, f2;

// Sigma-delta modulators
sd2 #(.BW(SD_IN_BW)) sd_A (.clk(clk), .sd_in(sd_in_0), .bs_out(phaseA));
sd2 #(.BW(SD_IN_BW)) sd_B (.clk(clk), .sd_in(sd_in_1), .bs_out(phaseB));
sd2 #(.BW(SD_IN_BW)) sd_C (.clk(clk), .sd_in(sd_in_2), .bs_out(phaseC));

modulator modulator_A (.clk(clk), .sd_bs(phaseA), .pwm(pwmA));
modulator modulator_B (.clk(clk), .sd_bs(phaseB), .pwm(pwmB));
modulator modulator_C (.clk(clk), .sd_bs(phaseC), .pwm(pwmC));


counter_modulator modulator_Ac (.clk(clk), .sd_bs(phaseA), .count(countA));
counter_modulator modulator_Bc (.clk(clk), .sd_bs(phaseB), .count(countB));
counter_modulator modulator_Cc (.clk(clk), .sd_bs(phaseC), .count(countC));

// Initial conditions (scaled)
initial begin
    f0 =  (2**(REG_BW-3)) - 1;                     // Phase A: cos(0) = 1
    f1 = -((2**(REG_BW-3)) - 1) >>> 1;             // Phase B: cos(2π/3) = -1/2
    f2 = -((2**(REG_BW-3)) - 1) >>> 1;             // Phase C: cos(4π/3) = -1/2
end

// Output assignments
assign sd_in_0 = {f0[REG_BW-1], f0[REG_BW-3:INT_SCALE]};
assign sd_in_1 = {f1[REG_BW-1], f1[REG_BW-3:INT_SCALE]};
assign sd_in_2 = {f2[REG_BW-1], f2[REG_BW-3:INT_SCALE]};
assign phaseAx = sd_in_0;
assign phaseBx = sd_in_1;
assign phaseCx = sd_in_2;

// omega_gain: scaled omega
assign omega_gain = omega <<< SD_IN_BW;
// fba divied by f0


// 3 phase matrix and inspiration from sin_cos_gen
// phaseA is blue 
// phaseB is red 
// phaseC is green
assign fbA = (phaseB ? omega_gain : -omega_gain) - (phaseC ? omega_gain : -omega_gain);
assign fbB = (phaseC ? omega_gain : -omega_gain) - (phaseA ? omega_gain : -omega_gain);
assign fbC = (phaseA ? omega_gain : -omega_gain) - (phaseB ? omega_gain : -omega_gain);
assign next_f0 = f0 + fbA;
assign next_f1 = f1 + fbB;
assign next_f2 = f2 + fbC;

// Saturation
always @(posedge clk) begin
    // f0 (Phase A)
    if (next_f0 > ((2**(REG_BW-3)) - 1))
        f0 <= (2**(REG_BW-3)) - 1;
    else if (next_f0 < -(2**(REG_BW-3)))
        f0 <= -(2**(REG_BW-3));
    else
        f0 <= next_f0;

    // f1 (Phase B)
    if (next_f1 > ((2**(REG_BW-3)) - 1))
        f1 <= (2**(REG_BW-3)) - 1;
    else if (next_f1 < -(2**(REG_BW-3)))
        f1 <= -(2**(REG_BW-3));
    else
        f1 <= next_f1;

    // f2 (Phase C)
    if (next_f2 > ((2**(REG_BW-3)) - 1))
        f2 <= (2**(REG_BW-3)) - 1;
    else if (next_f2 < -(2**(REG_BW-3)))
        f2 <= -(2**(REG_BW-3));
    else
        f2 <= next_f2;
end

endmodule
