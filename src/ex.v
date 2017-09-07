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

	//execute instruction result
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o,
	output reg[`RegBus]			wdata_o
);

	//register logical operation output
	
	reg[`RegBus]				logicout;
	reg[`RegBus]				shiftres;

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

endmodule



