
module reg_file (
rst_n,
clk, 
debug_in,
debug_out,
//ram bus
ram_addr,
ram_we,
ram_datain,
ram_enable,
ram_dataout
);

input rst_n;
input clk; 
input   [255:0]   debug_in;
output  [255:0]   debug_out;

//ram bus
input [15:0]    ram_addr;
input           ram_we;
input [31:0]     ram_datain;
input           ram_enable;
output  [31:0]   ram_dataout;

reg [255:0] debug_out;
reg [31:0] ram_dataout;
reg [31:0] ram_dataout_sel;
reg   [255:0]   debug_in_reg1;
reg   [255:0]   debug_in_reg2;

//dword address 8~f
wire wr_sel0 = ram_we && ram_enable && (ram_addr == (16'h8+16'h0));
wire wr_sel1 = ram_we && ram_enable && (ram_addr == (16'h8+16'h1));
wire wr_sel2 = ram_we && ram_enable && (ram_addr == (16'h8+16'h2));
wire wr_sel3 = ram_we && ram_enable && (ram_addr == (16'h8+16'h3));
wire wr_sel4 = ram_we && ram_enable && (ram_addr == (16'h8+16'h4));
wire wr_sel5 = ram_we && ram_enable && (ram_addr == (16'h8+16'h5));
wire wr_sel6 = ram_we && ram_enable && (ram_addr == (16'h8+16'h6));
wire wr_sel7 = ram_we && ram_enable && (ram_addr == (16'h8+16'h7));


//dword0
always @ (posedge clk)
begin
  if (!rst_n)
    debug_out[32*0+31:32*0] <= 0;
  else if(wr_sel0)
    debug_out[32*0+31:32*0] <= ram_datain;
end



//dword1
always @ (posedge clk)
begin
  if (!rst_n)
    debug_out[32*1+31:32*1] <= 0;
  else if(wr_sel1)
    debug_out[32*1+31:32*1] <= ram_datain;
end



//dword2
always @ (posedge clk)
begin
  if (!rst_n)
    debug_out[32*2+31:32*2] <= 0;
  else if(wr_sel2)
    debug_out[32*2+31:32*2] <= ram_datain;
end



//dword3
always @ (posedge clk)
begin
  if (!rst_n)
    debug_out[32*3+31:32*3] <= 0;
  else if(wr_sel3)
    debug_out[32*3+31:32*3] <= ram_datain;
end



//dword4
always @ (posedge clk)
begin
  if (!rst_n)
    debug_out[32*4+31:32*4] <= 0;
  else if(wr_sel4)
    debug_out[32*4+31:32*4] <= ram_datain;
end



//dword5
always @ (posedge clk)
begin
  if (!rst_n)
    debug_out[32*5+31:32*5] <= 0;
  else if(wr_sel5)
    debug_out[32*5+31:32*5] <= ram_datain;
end



//dword6
always @ (posedge clk)
begin
  if (!rst_n)
    debug_out[32*6+31:32*6] <= 0;
  else if(wr_sel6)
    debug_out[32*6+31:32*6] <= ram_datain;
end



//dword7
always @ (posedge clk)
begin
  if (!rst_n)
    debug_out[32*7+31:32*7] <= 32'h7;
  else if(wr_sel7)
    debug_out[32*7+31:32*7] <= ram_datain;
end



//debug_in_reg
always @ (posedge clk)
begin
  if (!rst_n)
    debug_in_reg1 <= 0;
  else
    debug_in_reg1 <= debug_in;
end

always @ (posedge clk)
begin
  if (!rst_n)
    debug_in_reg2 <= 0;
  else 
    debug_in_reg2 <= debug_in_reg1;
end


always @ (*)
begin
  case (ram_addr)
    16'h0: ram_dataout_sel = debug_in_reg2[32*0+31:32*0];
    16'h1: ram_dataout_sel = debug_in_reg2[32*1+31:32*1];
    16'h2: ram_dataout_sel = debug_in_reg2[32*2+31:32*2];
    16'h3: ram_dataout_sel = debug_in_reg2[32*3+31:32*3];
    16'h4: ram_dataout_sel = debug_in_reg2[32*4+31:32*4];
    16'h5: ram_dataout_sel = debug_in_reg2[32*5+31:32*5];
    16'h6: ram_dataout_sel = debug_in_reg2[32*6+31:32*6];
    16'h7: ram_dataout_sel = debug_in_reg2[32*7+31:32*7];
    16'd8: ram_dataout_sel = debug_out[32*0+31:32*0];
    16'd9: ram_dataout_sel = debug_out[32*1+31:32*1];
    16'd10: ram_dataout_sel = debug_out[32*2+31:32*2];
    16'd11: ram_dataout_sel = debug_out[32*3+31:32*3];
    16'd12: ram_dataout_sel = debug_out[32*4+31:32*4];
    16'd13: ram_dataout_sel = debug_out[32*5+31:32*5];
    16'd14: ram_dataout_sel = debug_out[32*6+31:32*6];
    16'd15: ram_dataout_sel = debug_out[32*7+31:32*7];
	default: ram_dataout_sel = 32'h0;
	endcase	
end

always @ (posedge clk)
begin
  if (!rst_n)
    ram_dataout <= 0;
  else if(ram_enable)
    ram_dataout <= ram_dataout_sel;
end

endmodule

