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
	

	//execute instruction result
	//GPR
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o,
	output reg[`RegBus]			wdata_o,
	//HILO reg
	output reg					whilo_o,
	output reg[`RegBus]			hi_o,
	output reg[`RegBus]			lo_o
);

	//register logical operation output
	
	reg[`RegBus]				logicout;
	reg[`RegBus]				shiftres;
	reg[`RegBus]				moveres;

	//mux for HILO reg
	reg[`RegBus]				hi_mux_i;
	reg[`RegBus]				lo_mux_i;

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

	//write execute result back to GPR or not according to alusel_i

	always @ (*)
	begin
		wd_o = wd_i;		//destination GPR address
		wreg_o = wreg_i;
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



