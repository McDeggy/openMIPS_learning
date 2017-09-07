//********** Global MACRO Defines **************************************************************************//
`define RstEnable			1'b1			//reset assert
`define RstDisable			1'b0			//reset deassert
`define ZeroWord			32'h00000000	//32 bits of zero
`define WriteEnable			1'b1			//enable write proccess
`define WriteDisable		1'b0			//diable write proccess
`define ReadEnable			1'b1			//enable read proccess
`define ReadDisable			1'b0			//disable read proccess
`define AluOpBus			7:0				//width of aluop_o output in decoding state
`define AluSelBus			2:0				//width of alusel_o output in decoding state
`define InstValid			1'b0			//instruction is valid
`define InstInvalid			1'b1			//instruction is invalid
`define True_v				1'b1			//logical state of true
`define False_v				1'b0			//logical state of false
`define ChipEnable			1'b1			//chip enable
`define ChipDisable			1'b0			//chip disable

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
//[31:26] (op) and [5:0] (func) indicate instruction type


//********** Instruction MACRO defines *********************************************************************//

//I type instruction OP code (6bit)
`define ID_ORI_OP			6'b001101		//ORI
`define ID_ANDI_OP			6'b001100		//ANDI
`define ID_XORI_OP			6'b001110		//XORI
`define ID_LUI_OP			6'b001111		//LUI

`define ID_PREF_OP 			6'b110011		//PREF
`define ID_SPECIAL_OP		6'b000000		//OP code SPECIAL for R type
//`define EXE_NOP				6'b000000		//NOP

//R type instruction func code (6bit)
`define ID_AND_FUNC			6'b100100		//AND
`define ID_OR_FUNC			6'b100101		//OR
`define ID_XOR_FUNC			6'b100110		//XOR
`define ID_NOR_FUNC			6'b100111		//NOR

`define ID_SLL_FUNC			6'b000000		//SLL
`define ID_SLLV_FUNC		6'b000100		//SLLV
`define ID_SRL_FUNC			6'b000010		//SRL
`define ID_SRLV_FUNC		6'b000110		//SRLV
`define ID_SRA_FUNC			6'b000011		//SRA
`define ID_SRAV_FUNC		6'b000111		//SRAV

`define ID_SYNC_FUNC  		6'b001111		//SYNC


//AluOp for EX module (ALU)
`define EXE_AND_OP			8'b00100100
`define EXE_OR_OP			8'b00100101
`define EXE_XOR_OP			8'b00100110
`define EXE_NOR_OP			8'b00100111
//`define EXE_ANDI_OP			8'b01011001
//`define EXE_ORI_OP			8'b01011010
//`define EXE_XORI_OP			8'b01011011
`define EXE_LUI_OP			8'b01011100   

`define EXE_SLL_OP			8'b01111100
`define EXE_SLLV_OP			8'b00000100
`define EXE_SRL_OP			8'b00000010
`define EXE_SRLV_OP			8'b00000110
`define EXE_SRA_OP			8'b00000011
`define EXE_SRAV_OP			8'b00000111

`define EXE_NOP_OP			8'b00000000


//AluSel for EX module (ALU)
`define EXE_RES_LOGIC		3'b001
`define EXE_RES_SHIFT		3'b010

`define EXE_RES_NOP			3'b000


//********** ROM MACRO Defines ****************************************************************************//
`define InstAddrBus			31:0			//max width of ROM address
`define InstBus				31:0			//width of ROM data (instruction width)
`define InstMemNum			131071			//ROM size (128K*InstBus bit)
`define InstMemNumLog2		17				//width of ROM address for ROM size InstMemNum


//********** General Purpose Reg Defines ******************************************************************//
`define RegAddrBus			4:0				//width of regfile module address
`define RegBus				31:0			//width of regfile module data
`define RegWidth			32				//width of GPR
`define DoubleRegWidth		64				//2*(width of GPR)
`define DoubleRegBus		63:0			//2*(width of GPR data)
`define RegNum				32				//number of GPR
`define RegNumLog2			5				//width of regfile module address for 32 GPR
`define NOPRegAddr			5'b00000		//address of instruction NOP










