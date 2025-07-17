module sin_cos_gen(clk, omega, sin, cos, sinx, cosx);

//parameter declarations
parameter SD_IN_BW = 16;                        //sigma delta input bitwidth
parameter INT_SCALE = 20;                       //integrator time scale shift for 2^27 Hz clock frequency
parameter OMEGA_BW = 16;                        //omega input bitwidth
localparam REG_BW = SD_IN_BW + INT_SCALE + 1;   //register bitwidths

//IO declarations
input clk;                          //clock input
input signed [OMEGA_BW-1:0] omega;  //omega coefficient input
output sin;                         //sine bitstream output
output cos;                         //cosine bitstream output
output signed [SD_IN_BW-1:0] sinx;
output signed [SD_IN_BW-1:0] cosx;

//wire declarations
wire signed [SD_IN_BW-1:0] sd_in_sin;
wire signed [SD_IN_BW-1:0] sd_in_cos;
wire signed [REG_BW-1:0] fb_sin;
wire signed [REG_BW-1:0] fb_cos;
wire signed [REG_BW-1:0] sin_reg_in;
wire signed [REG_BW-1:0] cos_reg_in;
wire signed [REG_BW-1:0] omega_gain;

//integrator registers
reg signed [REG_BW-1:0] x1;         //integrator register that feeds into cosine sigma delta
reg signed [REG_BW-1:0] x2;         //integrator register that feeds into sine sigma delta

//Sine and Cosine sigma delta encoder instantiations
sd2 #(.BW(SD_IN_BW)) sd_cos(.clk(clk), .sd_in(sd_in_cos), .bs_out(cos));
sd2 #(.BW(SD_IN_BW)) sd_sin(.clk(clk), .sd_in(sd_in_sin), .bs_out(sin));

//register initialization
initial begin
x1 = (2**(REG_BW-3))-1;
x2 = 0;
end 

//wire assignments
assign sd_in_cos = {x1[REG_BW-1],x1[REG_BW-3:INT_SCALE]};   //input to cosine sigma delta
assign sd_in_sin = {x2[REG_BW-1],x2[REG_BW-3:INT_SCALE]};   //input to sine sigma delta
assign omega_gain = omega <<< (SD_IN_BW);
assign fb_sin = sin ? -omega_gain : omega_gain;             //feedback from sine output to cosine integrator input
assign fb_cos = cos ? omega_gain : -omega_gain;             //feedback from cosine output to sine integrator input
assign cos_reg_in = x1 + fb_sin;                            //input to cosine integrator register
assign sin_reg_in = x2 + fb_cos;                            //input to sine integrator register
assign cosx = sd_in_cos;
assign sinx = sd_in_sin;

//synchronous integrator register update logic
always@(posedge clk) begin

    //saturate cosine integrator
    if (cos_reg_in > ((2**(REG_BW-3))-1)) begin 
        x1 <= ((2**(REG_BW-3))-1);
    end else if (cos_reg_in < -(2**(REG_BW-3))) begin
        x1 <= -(2**(REG_BW-3));
    end else begin
        x1 <= cos_reg_in;
    end

    //saturate sine integrator
    if (sin_reg_in > ((2**(REG_BW-3))-1)) begin 
        x2 <= ((2**(REG_BW-3))-1);
    end else if (sin_reg_in < -(2**(REG_BW-3))) begin
        x2 <= -(2**(REG_BW-3));
    end else begin
        x2 <= sin_reg_in;
    end

end

endmodule
