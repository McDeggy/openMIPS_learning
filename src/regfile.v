//********** REG Module ************************************************************************************//
//32*32bit REG define ($0 to $31)
//
//FILENAME   :    regfile.v
//FUCNTION   :    define 32 general purpose registers, read 2 reg at the same time while write 1 reg.
//
//**********************************************************************************************************//

`include "defines.v"

module regfile(
	input wire					clk,
	input wire					rst,

	//write port
	input wire					we,
	input wire[`RegAddrBus]		waddr,		//5bit address for 32 reg
	input wire[`RegBus]			wdata,		//32bit data

	//read port 1
	input wire					re1,
	input wire[`RegAddrBus]		raddr1,
	output reg[`RegBus]			rdata1,

	//read port 2
	input wire					re2,
	input wire[`RegAddrBus]		raddr2,
	output reg[`RegBus]			rdata2
);

	//define 32 REG

	reg[`RegBus]				regs[`RegNum-1 : 0];

	//define write port function

	always @ (posedge clk)
	begin
		if (rst == `RstDisable)
		begin
			if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0))		//`RegNumLog2'h0 means RegNumLog2 bit of 0, GPR $0 contains 32'h0, not allowed to change in MIPS32
			begin
				regs[waddr] <= wdata;
			end
		end
	end

	//define read port 1 function

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			rdata1 = `ZeroWord;
		end
		else if (raddr1 == `RegNumLog2'h0)		//read $0, return 32'h0 directly
		begin
			rdata1 = `ZeroWord;
		end
		else if ((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable))		//when write & read the same reg, return write data directly
		begin
			rdata1 = wdata;
		end
		else
		begin
			rdata1 = regs[raddr1];
		end
	end

	//define read port 2 function

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			rdata2 = `ZeroWord;
		end
		else if (raddr2 == `RegNumLog2'h0)
		begin
			rdata2 = `ZeroWord;
		end
		else if ((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable))
		begin
			rdata2 = wdata;
		end
		else
		begin
			rdata2 = regs[raddr2];
		end
	end


endmodule



