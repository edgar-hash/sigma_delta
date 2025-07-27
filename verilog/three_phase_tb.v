`timescale 1ns / 1ps

module three_phase_tb;

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
  wire signed [REG_BW-1:0] dbg_f0, dbg_f1, dbg_f2;

  // Instantiate your DUT (Device Under Test)
three_phase three_phase_gen(
    .clk(clk),
    .omega(omega),
    .phaseA(phaseA),
    .phaseB(phaseB),
    .phaseC(phaseC),
    .phaseAx(phaseAx),
    .phaseBx(phaseBx),
    .phaseCx(phaseCx),
  .dbg_f0(dbg_f0),
  .dbg_f1(dbg_f1),
  .dbg_f2(dbg_f2)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns clock period
  end

  reg signed [OMEGA_BW-1:0] omega_arg;
  initial begin
    if (!$value$plusargs("omega=%d", omega_arg)) begin
      $display("ERROR: omega not provided via +omega=<val>");
      $finish;
    end

    omega = omega_arg;

    $display("omega set to: %d", omega);

    $monitor("time: %0t, phaseAx: %d , phaseBx: %d, phaseCx: %d, phaseA: %b, phaseB: %b, phaseC: %b, f0: %d, f1: %d, f2: %d", 
         $time, phaseAx, phaseBx, phaseCx, phaseA, phaseB, phaseC, dbg_f0, dbg_f1, dbg_f2);

    $dumpfile("three_phase_gen.vcd");
    $dumpvars(1, three_phase_tb);

    #1000000;
    $finish;
  end


endmodule
