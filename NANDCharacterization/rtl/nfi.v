`define NAND_DQ_WIDTH 8
module nfi (
	rst_n,
	core_clk,
	dp_clk,
	//APB bus slave
	apb_paddr,
	apb_penable,
	apb_pwrite,
	apb_pwdata,
	apb_pready,
	apb_prdata,
	apb_pstrb,
        apb_pslverr,
	//bram bus master
        bram_addr,
        bram_dout,
        bram_din,
        bram_en,
        bram_we,
	//nand flash interface
        ceb,
        web,
        reb,
        cle,
        ale,
        wpb,
        rbb,
        dqs,
        dqs_c,
        [(`NAND_DQ_WIDTH-1):0] io
	);
input rst_n;
input core_clk;
input dp_clk;
//APB bus slave
input  [31:0] apb_paddr;
input         apb_penable;
input         apb_pwrite;
input  [31:0] apb_pwdata;
input  [3:0]  apb_pstrb;
output        apb_pready;
output [31:0] apb_prdata;
output        apb_pslverr;
//bram bus master
output [31:0] bram_addr;
output [31:0] bram_dout;
input  [31:0] bram_din;
output bram_en;
output [3:0]  bram_we;
//nand flash interface
input       ceb,
input       web,
input       reb,
input       cle,
input       ale,
input       wpb,
output reg  rbb,
inout       dqs,
inout       dqs_c,
inout  [(NAND_DQ_WIDTH-1):0] io;

endmodule
