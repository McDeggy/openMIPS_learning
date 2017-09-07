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
	// |______|_____|_____|__________________|
	// |  op  |  rs |  rt |     immediate    |
	//
	// 3.J type
	//  31  26 25                           0
	// |______|______________________________|
	// |  op  |            address           |

	//decode instruction for instruction code/ function code
	//[31:26] (op) and [5:0] (func) indicate instruction type
	
	//separate instruction into parts
	//R-I-J
	wire[5:0] op_code = inst_i[31:26];			//OP code
	//R-I
	wire[4:0] rs_code = inst_i[25:21];			//RS code for GPR address
	wire[4:0] rt_code = inst_i[20:16];			//RT code for GPR address
	//R
	wire[4:0] rd_code = inst_i[15:11];			//RD code for GPR address
	//wire[4:0] sa_code = inst_i[10:6];			//SA code for shift instruction tempory transmit by imm
	wire[5:0] func_code = inst_i[5:0];			//FUNC code 
	//I
	wire[15:0] imm_code = inst_i[15:0];			//immidiate data (16bit)

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
			reg1_addr_o = rs_code;
			reg2_addr_o = rt_code;
			//imm and wd_o always fix in the same bit of instruction
			imm = {16'h0, imm_code};

			case (op_code)
			
//I type *************************************************************************
				//ORI instruction
				`ID_ORI_OP:
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
					//imm = {16'h0, imm_code};
					//writing destination GPR address
					wd_o = rt_code;
					inst_valid = `InstValid;				
				end

				//ANDI insturction
				`ID_ANDI_OP:
				begin
					wreg_o = `WriteEnable;
					aluop_o = `EXE_AND_OP;
					alusel_o = `EXE_RES_LOGIC;
					reg1_read_o = `ReadEnable;
					reg2_read_o = `ReadDisable;
					//imm = {16'h0, imm_code};
					wd_o = rt_code;
					inst_valid = `InstValid;
				end
				
				//XORI insturcion
				`ID_XORI_OP:
				begin
					wreg_o = `WriteEnable;
					aluop_o = `EXE_XOR_OP;
					alusel_o = `EXE_RES_LOGIC;
					reg1_read_o = `ReadEnable;
					reg2_read_o = `ReadDisable;
					//imm = {16'h0, imm_code};
					wd_o = rt_code;
					inst_valid = `InstValid;
				end

				//LUI insturction
				`ID_LUI_OP:
				begin
					wreg_o = `WriteEnable;
					aluop_o = `EXE_LUI_OP;
					alusel_o = `EXE_RES_LOGIC;
					reg1_read_o = `ReadEnable;					//ReadDisable is ok as well
					reg2_read_o = `ReadDisable;
					//imm = {16'h0, imm_code};
					wd_o = rt_code;
					inst_valid = `InstValid;
				end

				//PREF insturction temporily the same with NOP or NULL, does nothing
				`ID_PREF_OP:
				begin
					wreg_o = `WriteDisable;
					aluop_o = `EXE_NOP_OP;
					alusel_o = `EXE_RES_NOP;
					reg1_read_o = `ReadDisable;
					reg2_read_o = `ReadDisable;
					//imm = {16'h0, imm_code};
					wd_o = rt_code;
					inst_valid = `InstValid;
				end
				
//R type *************************************************************************			
				`ID_SPECIAL_OP:
				begin
					case (func_code)
						//AND instruction
						`ID_AND_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_AND_OP;
							alusel_o = `EXE_RES_LOGIC;
							reg1_read_o = `ReadEnable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//OR instruction
						`ID_OR_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_OR_OP;
							alusel_o = `EXE_RES_LOGIC;
							reg1_read_o = `ReadEnable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//XOR instruction
						`ID_XOR_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_XOR_OP;
							alusel_o = `EXE_RES_LOGIC;
							reg1_read_o = `ReadEnable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//NOR instruction
						`ID_NOR_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_NOR_OP;
							alusel_o = `EXE_RES_LOGIC;
							reg1_read_o = `ReadEnable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//SLLV instruction
						`ID_SLLV_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_SLLV_OP;
							alusel_o = `EXE_RES_SHIFT;
							reg1_read_o = `ReadEnable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//SRLV instruction
						`ID_SRLV_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_SRLV_OP;
							alusel_o = `EXE_RES_SHIFT;
							reg1_read_o = `ReadEnable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//SRAV instruction
						`ID_SRAV_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_SRAV_OP;
							alusel_o = `EXE_RES_SHIFT;
							reg1_read_o = `ReadEnable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//SLL SRL SRA are diferent from AND/SLLV/ORI, sa will transmit to EX module by imm
						//SLL instruction (including NOP and SSNOP)
						//NOP = SLL $0,$0,0
						//SSNOP = SLL $0,$0,1
						`ID_SLL_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_SLL_OP;
							alusel_o = `EXE_RES_SHIFT;
							// difer from AND/SLLV/ORI ...
							reg1_read_o = `ReadDisable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//SRL instruction
						`ID_SRL_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_SRL_OP;
							alusel_o = `EXE_RES_SHIFT;
							// difer from AND/SLLV/ORI ...
							reg1_read_o = `ReadDisable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//SRA instruction
						`ID_SRA_FUNC:
						begin
							wreg_o = `WriteEnable;
							aluop_o = `EXE_SRA_OP;
							alusel_o = `EXE_RES_SHIFT;
							// difer from AND/SLLV/ORI ...
							reg1_read_o = `ReadDisable;
							reg2_read_o = `ReadEnable;
							wd_o = rd_code;
							inst_valid = `InstValid;
						end

						//SYNC instruction
						`ID_SYNC_FUNC:
						begin
							wreg_o = `WriteDisable;
							aluop_o = `EXE_NOP_OP;
							alusel_o = `EXE_RES_NOP;
							reg1_read_o = `ReadDisable;
							reg2_read_o = `ReadEnable;					//ReadDisable is ok as well
							wd_o = rd_code;
							inst_valid = `InstValid;
						end
						
						//NULL
						default:
						begin
							wreg_o = `WriteDisable;
							aluop_o = `EXE_NOR_OP;
							alusel_o = `EXE_RES_NOP;
							reg1_read_o = `ReadDisable;
							reg2_read_o = `ReadDisable;
							wd_o = `NOPRegAddr;
							inst_valid = `InstInvalid;
						end
					endcase //func_code
				end
				
				//NULL
				default:
				begin
					wreg_o = `WriteDisable;
					aluop_o = `EXE_NOP_OP;
					alusel_o = `EXE_RES_NOP;
					reg1_read_o = `ReadDisable;
					reg2_read_o = `ReadDisable;
					//imm = `ZeroWord;
					wd_o = `NOPRegAddr;
					inst_valid = `InstInvalid;
				end
			endcase //op_code
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


