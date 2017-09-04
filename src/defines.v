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



//********** Instruction MACRO defines *********************************************************************//
`define EXE_ORI				6'b001101		//ORI instruction code
`define EXE_NOP				6'b000000		//NOP instruction code


//AluOp
`define EXE_OR_OP			8'b00100101
`define EXE_NOP_OP			8'b00000000


//AluSel
`define EXE_RES_LOGIC		3'b001
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










