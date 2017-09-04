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

	//execute operation according to aluop_i
	
	always @ (*)
	begin
		if (rst == `RstEnable)
		begin
			logicout <= `ZeroWord;
		end
		else
		begin
			case (aluop_i)
				//ORI
				`EXE_OR_OP:
				begin
					logicout = reg1_i | reg2_i;
				end
				default:
				begin
					logicout = `ZeroWord;
				end
			endcase
		end
	end

	//write execute result back to GPR or not according to alusel_i

	always @ (*)
	begin
		wd_o = wd_i;		//destination GPR address
		wreg_o = wreg_i;
		case (alusel_i)
			//ORI
			`EXE_RES_LOGIC:
			begin
				wdata_o = logicout;
			end
			default:
			begin
				wdata_o = `ZeroWord;
			end
		endcase
	end

endmodule



