`timescale 1us / 1ns

module three_phase_shape_tb;

  // Parameters (set to match your module)
parameter INT_SCALE = 20;                       // Integration scaling (for high clock)
parameter SD_IN_BW = 16;                        //sigma delta input bitwidth
parameter OMEGA_BW = 16;      
localparam REG_BW = SD_IN_BW + INT_SCALE + 1;   // Internal register width
  // Testbench signals
  reg clk;
  reg signed [OMEGA_BW-1:0] omega;
  wire phaseA, phaseB, phaseC;
  wire signed [SD_IN_BW-1:0] phaseAx, phaseBx, phaseCx;
 wire pwmA, pwmB, pwmC;
 wire countA, countB, countC;
  // Instantiate your DUT (Device Under Test)
three_phase_shape three_phase_gen(
    .clk(clk),
    .omega(omega),
    .phaseA(phaseA),
    .phaseB(phaseB),
    .phaseC(phaseC),
    .phaseAx(phaseAx),
    .phaseBx(phaseBx),
    .phaseCx(phaseCx),
  .pwmA(pwmA),
  .pwmB(pwmB),
  .pwmC(pwmC),
  .countA(countA),
  .countB(countB),
  .countC(countC)
  );
dither dither_sd(.clk(clk),
    .in_val(phaseA),      // current input
    .out_val(ditherA)  // signed output (-1, 0, or 1)
);
  // Clock generation
  initial begin
    clk = 0;
    forever #1 clk = ~clk;  // 2 us clock period
  end

  integer omega_arg;
  initial begin
    if (!$value$plusargs("omega=%d", omega_arg)) begin
      $display("ERROR: omega not provided via +omega=<val>");
      $finish;
    end

    omega = omega_arg;

    $display("omega set to: %d", omega);
    $monitor("time: %0t, phaseAx: %d , phaseBx: %d, phaseCx: %d, phaseA: %d, phaseB: %b, phaseC: %b, pwmA: %b, pwmB: %b, pwmC: %b, countA: %b, countB: %b, countC: %b", 
         $time, phaseAx, phaseBx, phaseCx, phaseA, phaseB, phaseC, pwmA, pwmB, pwmC, countA, countB, countC);

    $dumpfile("three_phase_shape_gen.vcd");
    $dumpvars(1, three_phase_shape_tb);
  #105000000;
    $finish;
  end


endmodule
