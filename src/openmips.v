//********** top Module ************************************************************************************//
//top module for openMIPS
//
//FILENAME   :    openmips.v
//FUCNTION   :    connect sub-modules to each other
//
//**********************************************************************************************************//

`include "defines.v"

module openmips(
	input wire					clk,
	input wire					rst,

	//to ROM module
	input wire[`RegBus]			rom_data_i,
	output wire[`RegBus]		rom_addr_o,
	output wire					rom_ce_o

);

	//wires for IF/ID module and ID module
	wire[`InstAddrBus]			pc;
	wire[`InstAddrBus]			id_pc_i;
	wire[`InstBus]				id_inst_i;

	//wires for ID moduld and ID/EX module
	wire[`AluOpBus]				id_aluop_o;
	wire[`AluSelBus]			id_alusel_o;
	wire[`RegBus]				id_reg1_o;
	wire[`RegBus]				id_reg2_o;
	wire						id_wreg_o;
	wire[`RegAddrBus]			id_wd_o;

	//wires for ID/EX module and EX module
	wire[`AluOpBus]				ex_aluop_i;
	wire[`AluSelBus]			ex_alusel_i;
	wire[`RegBus]				ex_reg1_i;
	wire[`RegBus]				ex_reg2_i;
	wire						ex_wreg_i;
	wire[`RegAddrBus]			ex_wd_i;

	//wires for EX module and EX/MEM module
	wire 						ex_wreg_o;
	wire[`RegAddrBus]			ex_wd_o;
	wire[`RegBus]				ex_wdata_o;

	//wires for EX/MEM module and MEM module
	wire						mem_wreg_i;
	wire[`RegAddrBus]			mem_wd_i;
	wire[`RegBus]				mem_wdata_i;

	//wires for MEM module and MEM/WB module
	wire						mem_wreg_o;
	wire[`RegAddrBus]			mem_wd_o;
	wire[`RegBus]				mem_wdata_o;

	//wires for MEM/WB module and write back state
	wire						wb_wreg_i;
	wire[`RegAddrBus]			wb_wd_i;
	wire[`RegBus]				wb_wdata_i;

	//wires for ID module and Regfile module
	wire						reg1_read;
	wire						reg2_read;
	wire[`RegBus]				reg1_data;
	wire[`RegBus]				reg2_data;
	wire[`RegAddrBus]			reg1_addr;
	wire[`RegAddrBus]			reg2_addr;

	//module pc_reg
	pc_reg pc_reg0(
		.clk(clk),							//i
		.rst(rst),							//i
		.pc(pc),							//o
		.ce(rom_ce_o)						//o
	);

	//workflow control
	assign rom_addr_o = pc;

	//IF/ID module
	if_id if_id0(
		.clk(clk),							//i
		.rst(rst),							//i
		.if_pc(pc),							//i
		.if_inst(rom_data_i),				//i
		.id_pc(id_pc_i),					//o
		.id_inst(id_inst_i)					//o
	);

	//ID module
	id id0(
		.rst(rst),							//i
//		.pc_i(id_pc_i),						//i
		.inst_i(id_inst_i),					//i

		//input from Regfile module
		.reg1_data_i(reg1_data),			//i
		.reg2_data_i(reg2_data),			//i

		//output to Regfile module
		.reg1_read_o(reg1_read),			//o
		.reg2_read_o(reg2_read),			//o
		.reg1_addr_o(reg1_addr),			//o
		.reg2_addr_o(reg2_addr),			//o

		//output to ID/EX module
		.aluop_o(id_aluop_o),				//o
		.alusel_o(id_alusel_o),				//o
		.reg1_o(id_reg1_o),					//o
		.reg2_o(id_reg2_o),					//o
		.wd_o(id_wd_o),						//o
		.wreg_o(id_wreg_o)					//o
	);

	//Regfile module
	regfile	regfile0(
		.clk(clk),							//i
		.rst(rst),							//i

		//write port
		.we(wb_wreg_i),						//i
		.waddr(wb_wd_i),					//i
		.wdata(wb_wdata_i),					//i

		//read port 1
		.re1(reg1_read),					//i
		.raddr1(reg1_addr),					//i
		.rdata1(reg1_data),					//o

		//read port 2
		.re2(reg2_read),					//i
		.raddr2(reg2_addr),					//i
		.rdata2(reg2_data)					//o
	);

	//ID/EX module
	id_ex id_ex0(
		.clk(clk),							//i
		.rst(rst),							//i

		//from ID module
		.id_aluop(id_aluop_o),				//i
		.id_alusel(id_alusel_o),			//i
		.id_reg1(id_reg1_o),				//i
		.id_reg2(id_reg2_o),				//i
		.id_wd(id_wd_o),					//i
		.id_wreg(id_wreg_o),				//i

		//to EX module
		.ex_aluop(ex_aluop_i),				//o
		.ex_alusel(ex_alusel_i),			//o
		.ex_reg1(ex_reg1_i),				//o
		.ex_reg2(ex_reg2_i),				//o
		.ex_wd(ex_wd_i),					//o
		.ex_wreg(ex_wreg_i)					//o
	);

	//EX module
	ex ex0(
		.rst(rst),							//i

		//from ID/EX module
		.aluop_i(ex_aluop_i),				//i
		.alusel_i(ex_alusel_i),				//i
		.reg1_i(ex_reg1_i),					//i
		.reg2_i(ex_reg2_i),					//i
		.wd_i(ex_wd_i),						//i
		.wreg_i(ex_wreg_i),					//i

		//to EX/MEM module
		.wd_o(ex_wd_o),						//o
		.wreg_o(ex_wreg_o),					//o
		.wdata_o(ex_wdata_o)				//o
	);

	//EX/MEM module
	ex_mem ex_mem0(
		.clk(clk),							//i
		.rst(rst),							//i

		//from EX module
		.ex_wd(ex_wd_o),					//i
		.ex_wreg(ex_wreg_o),				//i
		.ex_wdata(ex_wdata_o),				//i

		//to MEM module
		.mem_wd(mem_wd_i),					//o
		.mem_wreg(mem_wreg_i),				//o
		.mem_wdata(mem_wdata_i)				//o
	);

	//MEM module
	mem mem0(
		.rst(rst),							//i

		//from EX/MEM module
		.wd_i(mem_wd_i),					//i
		.wreg_i(mem_wreg_i),				//i
		.wdata_i(mem_wdata_i),				//i

		//to MEM/WB module
		.wd_o(mem_wd_o),					//o
		.wreg_o(mem_wreg_o),				//o
		.wdata_o(mem_wdata_o)				//o
	);

	//MEM/WB module
	mem_wb mem_wb0(
		.clk(clk),							//i
		.rst(rst),							//i

		//from MEM module
		.mem_wd(mem_wd_o),					//i
		.mem_wreg(mem_wreg_o),				//i
		.mem_wdata(mem_wdata_o),			//i

		//to write back state
		.wb_wd(wb_wd_i),					//o
		.wb_wreg(wb_wreg_i),				//o
		.wb_wdata(wb_wdata_i)				//o
	);


endmodule



