//********** ID Module *************************************************************************************//
//instruction decoder for next EXE state
//
//FILENAME   :    id.v
//FUCNTION   :    decode original instruction to seperate code
//
//**********************************************************************************************************//

`include "defines.v"

module id(
	input wire					rst,
//	input wire[`InstAddrBus]	pc_i,		//not used in id.v temperory
	input wire[`InstBus]		inst_i,		//instruction from IF/ID module 32bit

	//input data from GPR (RegFile)
	input wire[`RegBus]			reg1_data_i,		//reg data from GPR read port 1 32bit
	input wire[`RegBus]			reg2_data_i,		//reg data from GPR read port 2 32bit

	//output data to GPR (RegFile)
	output reg					reg1_read_o,		//GPR read port 1 read enable
	output reg					reg2_read_o,		//GPR read port 2 read enable
	output reg[`RegAddrBus]		reg1_addr_o,		//GPR read port 1 address 5bit
	output reg[`RegAddrBus]		reg2_addr_o,		//GPR read port 2 address 5bit

	//output to EXE state
	output reg[`AluOpBus]		aluop_o,			//sub-type of instruction to EX module (ori/or/andi/and etc..)
	output reg[`AluSelBus]		alusel_o,			//type of instruction to EX module (logic/shift etc...)
	output reg[`RegBus]			reg1_o,				//opertion code 1 32bit
	output reg[`RegBus]			reg2_o,				//opertion code 2 32bit
	output reg[`RegAddrBus]		wd_o,				//destination GPR
	output reg					wreg_o,				//flag of writing destination GPR

	//input from EXE state (data backward for correlation)
	input wire[`RegAddrBus]		ex_wd_i,
	input wire					ex_wreg_i,
	input wire[`RegBus]			ex_wdata_i,

	//input from MEM state (data backward for correlation)
	input wire[`RegAddrBus]		mem_wd_i,
	input wire					mem_wreg_i,
	input wire[`RegBus]			mem_wdata_i


	
);

	// 3 types of instruction in MIPS32
	//
	// 1.R type
	//  31  26 25 21 20 16 15 11 10  6 5    0
	// |______|_____|_____|_____|_____|______|
	// |  op  |  rs |  rt |  rd |  sa | func |
	// 
	// 2.I type
	//  31  26 25 21 20 16 15               0
	// |______|_____|_____|__________________|
	// |  op  |  rs |  rt |     immediate    |
	//
	// 3.J type
	//  31  26 25                           0
	// |______|______________________________|
	// |  op  |            address           |

	//decode instruction for instruction code/ function code
	//[31:26] (op) indicate instruction type
	
	wire[5:0] op1 = inst_i[31:26];
//	wire[4:0] op2 = inst_i[10:6];
//	wire[5:0] op3 = inst_i[5:0];
//	wire[4:0] op4 = inst_i[20:16];

	//reg for immediate data, scale out immediate from 16bit to 32bit.

	reg[`RegBus] imm;
	
	//indicate instruction valid or invalid

	reg inst_valid;

	//mux regs for read port 1 and read port 2 (data backward for correlation)
	reg[`RegBus] reg1_mux_i;
	reg[`RegBus] reg2_mux_i;

	//decode instruction

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			aluop_o = `EXE_NOP_OP;
			alusel_o = `EXE_RES_NOP;
			wd_o = `NOPRegAddr;
			wreg_o = `WriteDisable;
			inst_valid = `InstInvalid;
			reg1_read_o = `ReadDisable;
			reg2_read_o = `ReadDisable;
			reg1_addr_o = `NOPRegAddr;
			reg2_addr_o = `NOPRegAddr;
			imm = `ZeroWord;
		end
		else
		begin
			//always read GPR from port 1 and port 2
			reg1_addr_o = inst_i[25:21];
			reg2_addr_o = inst_i[20:16];

			case (op1)
			
				//ORI instruction
				`EXE_ORI:
				begin
					//ORI write destination GPR
					wreg_o = `WriteEnable;
					//sub-type OR operation
					aluop_o = `EXE_OR_OP;
					//type of ORI operation is logic
					alusel_o = `EXE_RES_LOGIC;
					//ORI read data from port 1 of GPR
					reg1_read_o = `ReadEnable;
					//ORI do not read data from port 2 of GPR
					reg2_read_o = `ReadDisable;
					imm = {16'h0, inst_i[15:0]};
					//writing destination GPR address
					wd_o = inst_i[20:16];
					inst_valid = `InstValid;				
				end
				
				//NOP
				default:
				begin
					wreg_o = `WriteDisable;
					aluop_o = `EXE_NOP_OP;
					alusel_o = `EXE_RES_NOP;
					reg1_read_o = `ReadDisable;
					reg2_read_o = `ReadDisable;
					imm = `ZeroWord;
					wd_o = inst_i[15:11];
					inst_valid = `InstInvalid;
				end
			endcase
		end

	
	end

	//mux the input from instruction/EX module/MEM module for data correlation

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			reg1_mux_i = `ZeroWord;
		end
		else if ((ex_wreg_i == `WriteEnable)&&(reg1_addr_o == ex_wd_i))						//if port 1 read the same GPR that EX module will write, output the data directly instead of read from GPR
		begin
			reg1_mux_i = ex_wdata_i;
		end
		else if ((mem_wreg_i == `WriteEnable)&&(reg1_addr_o == mem_wd_i))					//if port 1 read the same GPR that MEM module will write, output the data directly instead of read from GPR
		begin
			reg1_mux_i = mem_wdata_i;
		end
		else
		begin
			reg1_mux_i = reg1_data_i;
		end
	end

	//indicate operation code 1 reg1_o

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			reg1_o = `ZeroWord;
		end
		else if (reg1_read_o == `ReadEnable)
		begin
//			reg1_o = reg1_data_i;
			reg1_o = reg1_mux_i;
		end
		else if (reg1_read_o == `ReadDisable)
		begin
			reg1_o = imm;
		end
		else
		begin
			reg1_o = `ZeroWord;
		end
	end

	//mux the input from instruction/EX module/MEM module for data correlation

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			reg2_mux_i = `ZeroWord;
		end
		else if ((ex_wreg_i == `WriteEnable)&&(reg2_addr_o == ex_wd_i))						//if port 2 read the same GPR that EX module will write, output the data directly instead of read from GPR
		begin
			reg2_mux_i = ex_wdata_i;
		end
		else if ((mem_wreg_i == `WriteEnable)&&(reg2_addr_o == mem_wd_i))					//if port 2 read the same GPR that MEM module will write, output the data directly instead of read from GPR
		begin
			reg2_mux_i = mem_wdata_i;
		end
		else
		begin
			reg2_mux_i = reg2_data_i;
		end
	end

	//indicate operation code 2 reg2_o

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			reg2_o = `ZeroWord;
		end
		else if (reg2_read_o == `ReadEnable)
		begin
//			reg2_o = reg2_data_i;
			reg2_o = reg2_mux_i;
		end
		else if (reg2_read_o == `ReadDisable)
		begin
			reg2_o = imm;
		end
		else
		begin
			reg2_o = `ZeroWord;
		end
	end

endmodule


