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
//`define EXE_NOP				6'b000000		//NOP

`define ID_SLTI_OP			6'b001010		//SLTI
`define ID_SLTIU_OP			6'b001011		//SLTU
`define ID_ADDI_OP			6'b001000		//ADDI
`define ID_ADDIU_OP			6'b001001		//ADDIU

`define ID_SPECIAL_OP		6'b000000		//OP code SPECIAL for R type
`define ID_SPECIAL2_OP		6'b011100		//OP code SPECIAL2 for R type

//R type instruction func code (6bit)
//ID_SPECIAL_OP
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

`define ID_MOVZ_FUNC		6'b001010		//MOVZ
`define ID_MOVN_FUNC		6'b001011		//MOVN
`define ID_MFHI_FUNC		6'b010000		//MFHI
`define ID_MTHI_FUNC		6'b010001		//MTHI
`define ID_MFLO_FUNC		6'b010010		//MFLO
`define ID_MTLO_FUNC		6'b010011		//MTLO

`define ID_ADD_FUNC			6'b100000		//ADD
`define ID_ADDU_FUNC		6'b100001		//ADDU
`define ID_SUB_FUNC			6'b100010		//SUB
`define ID_SUBU_FUNC		6'b100011		//SUBU
`define ID_SLT_FUNC			6'b101010		//SLT
`define ID_SLTU_FUNC		6'b101011		//SLTU
`define ID_MULT_FUNC		6'b011000		//MULT
`define ID_MULTU_FUNC		6'b011001		//MULTU

`define ID_DIV_FUNC			6'b011010		//DIV
`define ID_DIVU_FUNC			6'b011011		//DIVU

//ID_SPECIAL2_OP
`define ID_CLZ_FUNC			6'b100000		//CLZ
`define ID_CLO_FUNC			6'b100001		//CLO
`define ID_MUL_FUNC			6'b000010		//MUL

`define ID_MADD_FUNC		6'b000000		//MADD
`define ID_MADDU_FUNC		6'b000001		//MADDU
`define ID_MSUB_FUNC		6'b000100		//MSUB
`define ID_MSUBU_FUNC		6'b000101		//MSUBU

//AluOp for EX module (ALU)
`define EXE_AND_OP			8'b00100100
`define EXE_OR_OP			8'b00100101
`define EXE_XOR_OP			8'b00100110
`define EXE_NOR_OP			8'b00100111
`define EXE_ANDI_OP			8'b01011001
`define EXE_ORI_OP			8'b01011010
`define EXE_XORI_OP			8'b01011011
`define EXE_LUI_OP			8'b01011100   

`define EXE_SLL_OP			8'b01111100
`define EXE_SLLV_OP			8'b00000100
`define EXE_SRL_OP			8'b00000010
`define EXE_SRLV_OP			8'b00000110
`define EXE_SRA_OP			8'b00000011
`define EXE_SRAV_OP			8'b00000111

`define EXE_MOV_OP			8'b00001010		//MOVZ and MOVN fetch the same in EX module
`define EXE_MOVZ_OP			8'b00001010
`define EXE_MOVN_OP			8'b00001011

`define EXE_MFHI_OP			8'b00010000
`define EXE_MTHI_OP			8'b00010001
`define EXE_MFLO_OP			8'b00010010
`define EXE_MTLO_OP			8'b00010011

`define EXE_SLT_OP			8'b00101010
`define EXE_SLTU_OP			8'b00101011
`define EXE_SLTI_OP			8'b01010111
`define EXE_SLTIU_OP		8'b01011000   
`define EXE_ADD_OP			8'b00100000
`define EXE_ADDU_OP			8'b00100001
`define EXE_SUB_OP			8'b00100010
`define EXE_SUBU_OP			8'b00100011
`define EXE_ADDI_OP			8'b01010101
`define EXE_ADDIU_OP		8'b01010110
`define EXE_CLZ_OP			8'b10110000
`define EXE_CLO_OP			8'b10110001

`define EXE_MULT_OP			8'b00011000
`define EXE_MULTU_OP		8'b00011001
`define EXE_MUL_OP			8'b10101001

`define EXE_MADD_OP			8'b10100110
`define EXE_MADDU_OP		8'b10101000
`define EXE_MSUB_OP			8'b10101010
`define EXE_MSUBU_OP		8'b10101011

`define EXE_DIV_OP			8'b00011010
`define EXE_DIVU_OP			8'b00011011

`define EXE_NOP_OP			8'b00000000

//AluSel for EX module (ALU)
`define EXE_RES_LOGIC		3'b001
`define EXE_RES_SHIFT		3'b010
`define EXE_RES_MOVE		3'b011
`define EXE_RES_MATH		3'b100

`define EXE_RES_NOP			3'b000

//********** Global Defines *******************************************************************************//
`define LogiTrue			1'b1
`define LogiFalse			1'b0

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










