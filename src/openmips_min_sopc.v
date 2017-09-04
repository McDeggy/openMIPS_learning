// combin openmips module and rom module

`include "defines.v"

module openmips_min_sopc(

	input wire					clk,
	input wire					rst

);

	//wires for connection
	wire[`InstAddrBus]			inst_addr;
	wire[`InstBus]				inst;
	wire						rom_ce;

	//openmips module
	openmips openmips0(
		.clk(clk),
		.rst(rst),

		//ROM port
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce)
	);

	//ROM module
	inst_rom inst_rom0(
		.ce(rom_ce),
		.addr(inst_addr),
		.inst(inst)
	);


endmodule


