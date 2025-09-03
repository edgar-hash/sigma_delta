`timescale  1us/1ns

module sd_tb();

parameter BW = 16;

reg clk;
wire signed [BW-1:0] sd;
wire bs_out;


initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
end

sd2 sd_dut(.clk(clk),.sd_in(sd_in), .bs_out(bs_out));

initial begin
    $monitor("time=%3d, bs_out=%b, sd_in=%d\n", 
              $time, bs_out sd_in);
    sd_in = 10000;

end

initial begin 
    $dumpfile
    $dumpvars(1, sd_tb);

end
endmodule

