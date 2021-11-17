--------------------------------------------------------------------------------
-- Company: Satellogic S.A
--
-- File: axi_lite_slave_int.vhdl
-- Description: 
--
-- AXI Lite Slave Interface for any ip core. Based in Xilinx automagic core.
--
-- Author: Xilinx, David Caruso
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity axi_lite_slave_int is
    generic (
        -- Width of S_AXI data bus
        C_S_AXI_DATA_WIDTH  : integer   := 32;
        -- Width of S_AXI address bus
        C_S_AXI_ADDR_WIDTH  : integer   := 4
    );
    port (
        -- Users to add ports here
        WDATA_O         : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        RDATA_I         : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        WENA_O          : out std_logic;
        RENA_O          : out std_logic;
        RADDR_O         : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        WADDR_O         : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        -- AXI4-Lite Slave Port
        S_AXI_ACLK      : in std_logic;
        S_AXI_ARESETN   : in std_logic;
        S_AXI_AWADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWVALID   : in std_logic;
        S_AXI_AWREADY   : out std_logic;
        S_AXI_WDATA     : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB     : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID    : in std_logic;
        S_AXI_WREADY    : out std_logic;
        S_AXI_BRESP     : out std_logic_vector(1 downto 0);
        S_AXI_BVALID    : out std_logic;
        S_AXI_BREADY    : in std_logic;
        S_AXI_ARADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARVALID   : in std_logic;
        S_AXI_ARREADY   : out std_logic;
        S_AXI_RDATA     : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP     : out std_logic_vector(1 downto 0);
        S_AXI_RVALID    : out std_logic;
        S_AXI_RREADY    : in std_logic
    );
end axi_lite_slave_int;

architecture arch_imp of axi_lite_slave_int is

    constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
    constant OPT_MEM_ADDR_BITS : integer := integer(ceil(log2(real(C_S_AXI_ADDR_WIDTH))))-1;
    constant EXTRA_ZEROS: std_logic_vector(ADDR_LSB-1 downto 0) := (others=>'0');

    signal slv_reg_rden : std_logic;
    signal slv_reg_wren : std_logic;

    signal axi_awready  : std_logic;
    signal axi_wready   : std_logic;
    signal axi_bvalid   : std_logic;
    signal axi_rvalid   : std_logic;
    signal axi_arready  : std_logic;

begin

    S_AXI_BRESP     <= "00";
    S_AXI_RRESP     <= "00";

    S_AXI_AWREADY <= axi_awready;
    S_AXI_WREADY  <= axi_wready;
    S_AXI_BVALID  <= axi_bvalid;
    S_AXI_RVALID  <= axi_rvalid;
    S_AXI_ARREADY <= axi_arready;

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                axi_awready <= '0';
            else
                if (axi_awready = '0' and S_AXI_AWVALID = '1') then
                    axi_awready <= '1';
                else
                    axi_awready <= '0';
                end if;
            end if;
        end if;
    end process;

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                axi_wready <= '0';
            else
                if (axi_wready = '0' and S_AXI_WVALID = '1') then
                    axi_wready <= '1';
                else
                    axi_wready <= '0';
                end if;
            end if;
        end if;
    end process; 

    slv_reg_wren <= axi_wready and S_AXI_WVALID;

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                axi_bvalid  <= '0';
            else
                if (axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0') then
                    axi_bvalid <= '1';
                elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
                    axi_bvalid <= '0';
                end if;
            end if;
        end if;
    end process; 

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then 
            if S_AXI_ARESETN = '0' then
                axi_arready <= '0';
            else
                if (axi_arready = '0' and S_AXI_ARVALID = '1') then
                    axi_arready <= '1';
                else
                    axi_arready <= '0';
                end if;
            end if;
        end if;
    end process; 

    slv_reg_rden <= axi_arready and S_AXI_ARVALID;

    process (S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_rvalid <= '0';
            else
                if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
                    axi_rvalid <= '1';
                elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
                    axi_rvalid <= '0';
                end if;
            end if;
        end if;
    end process;

    S_AXI_RDATA <= RDATA_I;
    RADDR_O   <= S_AXI_ARADDR(C_S_AXI_ADDR_WIDTH-1 downto ADDR_LSB) & EXTRA_ZEROS;
    WADDR_O   <= S_AXI_AWADDR(C_S_AXI_ADDR_WIDTH-1 downto ADDR_LSB) & EXTRA_ZEROS;
    WDATA_O   <= S_AXI_WDATA;
    RENA_O    <= slv_reg_rden;
    WENA_O    <= slv_reg_wren;

end arch_imp;