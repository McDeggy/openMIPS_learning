//********** EX Module *************************************************************************************//
//execute module
//
//FILENAME   :    ex.v
//FUCNTION   :    execute instruction (ALU)
//
//**********************************************************************************************************//

`include "defines.v"

module ex(
	input wire					rst,

	//signals from instruction fetch to execute
	input wire[`AluOpBus]		aluop_i,
	input wire[`AluSelBus]		alusel_i,
	input wire[`RegBus]			reg1_i,
	input wire[`RegBus]			reg2_i,
	input wire[`RegAddrBus]		wd_i,
	input wire					wreg_i,
	//HILO reg
	//from HILO reg module
	input wire[`RegBus]			hi_i,
	input wire[`RegBus]			lo_i,
	//from MEM module
	input wire					mem_whilo_i,
	input wire[`RegBus]			mem_hi_i,
	input wire[`RegBus]			mem_lo_i,
	//from MEM/WB module
	input wire					wb_whilo_i,
	input wire[`RegBus]			wb_hi_i,
	input wire[`RegBus]			wb_lo_i,

	//wires for MADD MADDU MSUB MSUBU from ex_mem module
	input wire[1:0]				madd_msub_cnt_i,
	input wire[`DoubleRegBus]	madd_msub_mul_i,

	//execute instruction result
	//GPR
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o,
	output reg[`RegBus]			wdata_o,
	//HILO reg
	output reg					whilo_o,
	output reg[`RegBus]			hi_o,
	output reg[`RegBus]			lo_o,

	//output signal to pause pipeline
	output reg					stallreq_from_ex,

	//regs for MADD MADDU MSUB MSUBU
	output reg[1:0]				madd_msub_cnt_o,
	output reg[`DoubleRegBus]	madd_msub_mul_o
);

	//register logical/shift/move operation output
	reg[`RegBus]				logicout;
	reg[`RegBus]				shiftres;
	reg[`RegBus]				moveres;

	//mux for HILO reg
	reg[`RegBus]				hi_mux_i;
	reg[`RegBus]				lo_mux_i;

	//regs and wires for math
	reg[`RegBus]				mathres;
	
	wire[`RegBus]				reg2_mux_i;					//complement for reg2_i
	wire[`RegBus]				reg1_add_reg2;
	wire						overflow_add;				//overflow flag for ADD/SUB instruction
	wire						reg1_lt_reg2;				//compare flag for SLT/SLTU/SLTI/SLTIU
	wire[`RegBus]				reg1_mux_i;					//for zero count
	wire[5:0]					zero_counter;				//CLZ CLO
	wire[`RegBus]				reg1_mul_i;					//MUL MULT MULTU
	wire[`RegBus]				reg2_mul_i;					//MUL MULT MULTU
	wire[`DoubleRegBus]			reg1_mul_reg2;				//MUL MULT MULTU
	wire[`DoubleRegBus]			mulres;						//MUL MULT MULTU

	//regs for MADD MADDU MSUB MSUBU
	reg						madd_msub_stallreq;			//pause pipeline request
	reg[`DoubleRegBus]		madd_msub_res;				//contain result of madd_msub_mul_i add hilo reg

	//execute operation according to aluop_i

	//logic operation
	
	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			logicout <= `ZeroWord;
		end
		else
		begin
			case (aluop_i)
				//ORI OR
				`EXE_OR_OP:
				begin
					logicout = reg1_i | reg2_i;
				end

				//ANDI AND
				`EXE_AND_OP:
				begin
					logicout = reg1_i & reg2_i;
				end

				//XORI XOR
				`EXE_XOR_OP:
				begin
					logicout = reg1_i ^ reg2_i;
				end

				//NOR
				`EXE_NOR_OP:
				begin
					logicout = ~(reg1_i | reg2_i);
				end

				//LUI
				`EXE_LUI_OP:
				begin
					logicout = {reg2_i, 16'b0};
				end

				//PREF SYNC NULL NOP SSNOP
				default:
				begin
					logicout = `ZeroWord;
				end
			endcase //aluop_i
		end
	end

	//shift operation
	
	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			shiftres = `ZeroWord;
		end
		else
		begin
			case (aluop_i)
				//SLLV
				`EXE_SLLV_OP:
				begin
					shiftres = reg2_i << reg1_i[4:0];
				end

				//SRLV
				`EXE_SRLV_OP:
				begin
					shiftres = reg2_i >> reg1_i[4:0];
				end

				//SRAV
				`EXE_SRAV_OP:
				begin
					shiftres = (reg2_i >> reg1_i[4:0]) | ({{31{reg2_i[31]}}, 1'b0} << ~reg1_i[4:0]);
				end

				//SLL
				`EXE_SLL_OP:
				begin
					shiftres = reg2_i << reg1_i[10:6];													//imm[10:6] = sa
				end

				//SRL
				`EXE_SRL_OP:
				begin
					shiftres = reg2_i >> reg1_i[10:6];													//imm[10:6] = sa
				end

				//SRA
				`EXE_SRA_OP:
				begin
					shiftres = (reg2_i >> reg1_i[10:6]) | ({{31{reg2_i[31]}}, 1'b0} << ~reg1_i[10:6]);	//imm[10:6] = sa
				end

				//PREF SYNC NULL NOP SSNOP
				default:
				begin
					shiftres = `ZeroWord;
				end
			endcase //aluop_i
		end
	end

	//mux HILO reg for data correlation
	
	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			hi_mux_i = `ZeroWord;
			lo_mux_i = `ZeroWord;
		end
		else
		begin
			if (mem_whilo_i == `WriteEnable)
			begin
				hi_mux_i = mem_hi_i;
				lo_mux_i = mem_lo_i;
			end
			else if (wb_whilo_i == `WriteEnable)
			begin
				hi_mux_i = wb_hi_i;
				lo_mux_i = wb_lo_i;
			end
			else
			begin
				hi_mux_i = hi_i;
				lo_mux_i = lo_i;
			end
		end
	end

	//move operation

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			moveres = `ZeroWord;
		end
		else
		begin
			case (aluop_i)
				//MOVN MONZ
				`EXE_MOV_OP:
				begin
					moveres = reg1_i;
				end

				//MFHI
				`EXE_MFHI_OP:
				begin
					moveres = hi_mux_i;
				end

				//MFLO
				`EXE_MFLO_OP:
				begin
					moveres = lo_mux_i;
				end

				//NULL
				default:
				begin
					moveres = `ZeroWord;
				end
			endcase //aluop_i
		end
	end

	//ADD ADDI ADDU ADDIU SUB SUBU SLT SLTI
	//pretreatment for math a-b = a+(-b) = a+(~b+1)
	assign reg2_mux_i = ((aluop_i == `EXE_SUB_OP) ||
						(aluop_i == `EXE_SUBU_OP) ||
						(aluop_i == `EXE_SLT_OP)) ?
						(~reg2_i)+1 : reg2_i;
	assign reg1_add_reg2 = reg1_i + reg2_mux_i;
	//if reg1/reg2 are postive, and result is negative, there is overflow
	//if reg1/reg2 are negative, and result is postive, there is overflow
	assign overflow_add = ((!reg1_i[31] && !reg2_mux_i[31]) && reg1_add_reg2[31]) ||
							((reg1_i[31] && reg2_mux_i[31]) && (!reg1_add_reg2[31]));

	//SLT SLTI SLTU SLTIU
	//signed compare between reg1 and reg2
	//if reg1 is negative and reg2 is positive, reg1<reg2
	//if reg1 is positive and reg2 is positive, reg1-reg2<0 then reg1<reg2
	//if reg1 is negative and reg2 is negative, reg1-reg2<0 then reg1<reg2
	assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP) ?
							(reg1_i[31] && !reg2_i[31]) ||
							(reg1_i[31] && reg2_i[31] && reg1_add_reg2[31]) ||
							(!reg1_i[31] && !reg2_i[31] && reg1_add_reg2[31]) :
							(reg1_i < reg2_i);

	//CLZ CLO
	assign reg1_mux_i = (aluop_i == `EXE_CLO_OP) ? ~reg1_i : reg1_i;
	assign zero_counter = reg1_mux_i[31] ? 0 :
							reg1_mux_i[30] ? 1 :
							reg1_mux_i[29] ? 2 :
							reg1_mux_i[28] ? 3 :
							reg1_mux_i[27] ? 4 :
							reg1_mux_i[26] ? 5 :
							reg1_mux_i[25] ? 6 :
							reg1_mux_i[24] ? 7 :
							reg1_mux_i[23] ? 8 :
							reg1_mux_i[22] ? 9 :
							reg1_mux_i[21] ? 10 :
							reg1_mux_i[20] ? 11 :
							reg1_mux_i[19] ? 12 :
							reg1_mux_i[18] ? 13 :
							reg1_mux_i[17] ? 14 :
							reg1_mux_i[16] ? 15 :
							reg1_mux_i[15] ? 16 :
							reg1_mux_i[14] ? 17 :
							reg1_mux_i[13] ? 18 :
							reg1_mux_i[12] ? 19 :
							reg1_mux_i[11] ? 20 :
							reg1_mux_i[10] ? 21 :
							reg1_mux_i[9] ? 22 :
							reg1_mux_i[8] ? 23 :
							reg1_mux_i[7] ? 24 :
							reg1_mux_i[6] ? 25 :
							reg1_mux_i[5] ? 26 :
							reg1_mux_i[4] ? 27 :
							reg1_mux_i[3] ? 28 :
							reg1_mux_i[2] ? 29 :
							reg1_mux_i[1] ? 30 :
							reg1_mux_i[0] ? 31 : 32;

	//MUL MULT MADD MSUB
	//1.MUL/MULT/MADD/MSUB is signed operation, convert reg1/reg2 to complement if reg1/reg2 is negative
	assign reg1_mul_i = (((aluop_i == `EXE_MUL_OP) ||
							(aluop_i == `EXE_MULT_OP) ||
							(aluop_i == `EXE_MADD_OP) ||
							(aluop_i == `EXE_MSUB_OP)) &&
							(reg1_i[31] == 1'b1)) ?
							(~reg1_i + 1) : reg1_i;
	assign reg2_mul_i = (((aluop_i == `EXE_MUL_OP) ||
							(aluop_i == `EXE_MULT_OP) ||
							(aluop_i == `EXE_MADD_OP) ||
							(aluop_i == `EXE_MSUB_OP)) &&
							(reg2_i[31] == 1'b1)) ?
							(~reg2_i + 1) : reg2_i;
	//2.temporary store reg1*reg2 (output of hardcore multiplying unit)
	assign reg1_mul_reg2 = reg1_mul_i * reg2_mul_i;
	//3.if one of reg1/reg2 is negative and the other one is positive, then convert reg1_mul_reg2 to complement
	assign mulres = (((aluop_i == `EXE_MUL_OP) ||
					(aluop_i == `EXE_MULT_OP) ||
					(aluop_i == `EXE_MADD_OP) ||
					(aluop_i == `EXE_MSUB_OP)) &&
					(reg1_i[31]^reg2_i[31] == `LogiTrue) ) ?
					(~reg1_mul_reg2 + 1) : reg1_mul_reg2;

	//math operation
	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			mathres = `ZeroWord;
		end
		else
		begin
			case (aluop_i)
				//ADD ADDI ADDU ADDIU SUB SUBU
				`EXE_ADD_OP, `EXE_ADDI_OP, `EXE_ADDU_OP, `EXE_ADDIU_OP, `EXE_SUB_OP, `EXE_SUBU_OP:
				begin
					mathres = reg1_add_reg2;
				end

				//SLT SLTU SLTI SLTIU
				`EXE_SLT_OP, `EXE_SLTU_OP:
				begin
					mathres = {31'b0, reg1_lt_reg2};
				end

				//CLZ CLO
				`EXE_CLZ_OP, `EXE_CLO_OP:
				begin
					mathres = {26'b0, zero_counter};
				end

				//MUL
				`EXE_MUL_OP:
				begin
					mathres = mulres[`RegBus];
				end

				//NULL
				default:
				begin
					mathres = `ZeroWord;
				end
			endcase //aluop_i
		end
	end

	//MADD MADDU MSUB MSUBU
	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			madd_msub_cnt_o = 2'b00;
			madd_msub_stallreq = `LogiFalse;
			madd_msub_mul_o = {`ZeroWord, `ZeroWord};
			madd_msub_res = {`ZeroWord, `ZeroWord};
		end
		else
		begin
			case (aluop_i)
				//MADD MADDU
				`EXE_MADD_OP, `EXE_MADDU_OP:
				begin
					//first stage, GPR rs*rt and output to EX/MEM module for next stage
					if (madd_msub_cnt_i == 2'b00)
					begin
						madd_msub_cnt_o = 2'b01;
						//pause the pipeline for add operation of the next stage
						madd_msub_stallreq = `LogiTrue;
						madd_msub_mul_o = mulres;
						madd_msub_res = {`ZeroWord, `ZeroWord};
					end
					//second stage, 
					else if (madd_msub_cnt_i == 2'b01)
					begin
						madd_msub_cnt_o = 2'b00;
						//continue the pipeline
						madd_msub_stallreq = `LogiFalse;
						madd_msub_mul_o = {`ZeroWord, `ZeroWord};
						madd_msub_res = madd_msub_mul_i + {hi_mux_i, lo_mux_i};
					end
					//this else will never execute because cnt can be only 2'b00 and 2'b01
					else
					begin
						madd_msub_cnt_o = 2'b00;
						madd_msub_stallreq = `LogiFalse;
						madd_msub_mul_o = {`ZeroWord, `ZeroWord};
						madd_msub_res = {`ZeroWord, `ZeroWord};
					end
				end

				//MSUB MSUBU
				`EXE_MSUB_OP, `EXE_MSUBU_OP:
				begin
					//first stage, GPR rs*rt and output to EX/MEM module for next stage
					if (madd_msub_cnt_i == 2'b00)
					begin
						madd_msub_cnt_o = 2'b01;
						//pause the pipeline for sub operation of the next stage
						madd_msub_stallreq = `LogiTrue;
						//a-b = a + (-b), -b=~b+1
						madd_msub_mul_o = ~mulres + 1;
						madd_msub_res = {`ZeroWord, `ZeroWord};
					end
					//second stage, 
					else if (madd_msub_cnt_i == 2'b01)
					begin
						madd_msub_cnt_o = 2'b00;
						//continue the pipeline
						madd_msub_stallreq = `LogiFalse;
						madd_msub_mul_o = {`ZeroWord, `ZeroWord};
						madd_msub_res = madd_msub_mul_i + {hi_mux_i, lo_mux_i};
					end
					//this else will never execute because cnt can be only 2'b00 and 2'b01
					else
					begin
						madd_msub_cnt_o = 2'b00;
						madd_msub_stallreq = `LogiFalse;
						madd_msub_mul_o = {`ZeroWord, `ZeroWord};
						madd_msub_res = {`ZeroWord, `ZeroWord};
					end
				end

				//NULL
				default:
				begin
					madd_msub_cnt_o = 2'b00;
					madd_msub_stallreq = `LogiFalse;
					madd_msub_mul_o = {`ZeroWord, `ZeroWord};
					madd_msub_res = {`ZeroWord, `ZeroWord};
				end
			endcase //aluop_i
		end
	end

	//pipeline control
	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			stallreq_from_ex = `LogiFalse;
		end
		else
		begin
			stallreq_from_ex = madd_msub_stallreq;
		end
	end

	//if there is instruction ADD ADDI SUB with overflow, do not write GPR
	
	always @ (*)
	begin
		wd_o = wd_i;		//destiantion GPR address
		if (((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (overflow_add == `LogiTrue))
		begin
			wreg_o = `WriteDisable;
		end
		else
		begin
			wreg_o = `WriteEnable;
		end
	end

	//write execute result back to GPR or not according to alusel_i

	always @ (*)
	begin
		//wd_o = wd_i;		//destination GPR address
		//wreg_o = wreg_i;
		case (alusel_i)

			//ORI OR ANDI AND XORI XOR NOR LUI
			`EXE_RES_LOGIC:
			begin
				wdata_o = logicout;
			end

			//SLLV SLL SRLV SRL SRAV SRA
			`EXE_RES_SHIFT:
			begin
				wdata_o = shiftres;
			end

			//MOVN MOVZ
			`EXE_RES_MOVE:
			begin
				wdata_o = moveres;
			end

			//ADD ADDI ADDU ADDIU SUB SUBU
			`EXE_RES_MATH:
			begin
				wdata_o = mathres;
			end

			// the same as default
			`EXE_RES_NOP:
			begin
			  wdata_o = `ZeroWord;
			end

			//PREF SYNC NULL NOP SSNOP not write back to GPR
			default:
			begin
				wdata_o = `ZeroWord;
			end
		endcase //alusel_i
	end

	//HILO reg operation

	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			whilo_o = `WriteDisable;
			hi_o = `ZeroWord;
			lo_o = `ZeroWord;
		end
		else
		begin
			case (aluop_i)
				//MTHI
				`EXE_MTHI_OP:
				begin
					whilo_o = `WriteEnable;
					hi_o = reg1_i;
					lo_o = lo_mux_i;
				end

				//MTLO
				`EXE_MTLO_OP:
				begin
					whilo_o = `WriteEnable;
					hi_o = hi_mux_i;
					lo_o = reg1_i;
				end

				//MULT MULTU
				`EXE_MULT_OP, `EXE_MULTU_OP:
				begin
					whilo_o = `WriteEnable;
					{hi_o, lo_o} = mulres;
				end

				//MADD MADDU MSUB MSUBU
				`EXE_MADD_OP, `EXE_MADDU_OP, `EXE_MSUB_OP, `EXE_MSUBU_OP:
				begin
					whilo_o = `WriteEnable;
					{hi_o, lo_o} = madd_msub_res;
				end

				//NULL
				default:
				begin
					whilo_o = `WriteDisable;
					hi_o = `ZeroWord;
					lo_o = `ZeroWord;
				end
			endcase //aluop_i
		end
	end


endmodule



