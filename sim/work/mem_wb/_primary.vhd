library verilog;
use verilog.vl_types.all;
entity mem_wb is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        mem_wd          : in     vl_logic_vector(4 downto 0);
        mem_wreg        : in     vl_logic;
        mem_wdata       : in     vl_logic_vector(31 downto 0);
        mem_whilo       : in     vl_logic;
        mem_hi          : in     vl_logic_vector(31 downto 0);
        mem_lo          : in     vl_logic_vector(31 downto 0);
        wb_wd           : out    vl_logic_vector(4 downto 0);
        wb_wreg         : out    vl_logic;
        wb_wdata        : out    vl_logic_vector(31 downto 0);
        wb_whilo        : out    vl_logic;
        wb_hi           : out    vl_logic_vector(31 downto 0);
        wb_lo           : out    vl_logic_vector(31 downto 0);
        stall           : in     vl_logic_vector(5 downto 0)
    );
end mem_wb;
