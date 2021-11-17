------------------------------------------------------------------------------
-- Company: Satellogic S.A
--
-- File: axi_spi.vhdl
-- Description: 
--
-- AXI-SPI device for new candidates
--
-- Author: Andres Demski
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity axi_spi  is
    generic (
        C_AXI_DATA_WIDTH : integer :=32;
        C_AXI_ADDR_WIDTH : integer :=4
    );
    port (
        -- AXI4-Lite Slave Port
        AXI_ACLK             : in std_logic;
        AXI_ARESETN          : in std_logic;
        AXI_AWADDR           : in std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
        AXI_AWVALID          : in std_logic;
        AXI_AWREADY          : out std_logic;
        AXI_WDATA            : in std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
        AXI_WSTRB            : in std_logic_vector(C_AXI_DATA_WIDTH/8-1 downto 0);           
        AXI_WVALID           : in std_logic;
        AXI_WREADY           : out std_logic;
        AXI_BRESP            : out std_logic_vector(1 downto 0);
        AXI_BVALID           : out std_logic;
        AXI_BREADY           : in std_logic;
        AXI_ARADDR           : in std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
        AXI_ARVALID          : in std_logic;
        AXI_ARREADY          : out std_logic;
        AXI_RDATA            : out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
        AXI_RRESP            : out std_logic_vector(1 downto 0);
        AXI_RVALID           : out std_logic;
        AXI_RREADY           : in std_logic;

        -- SPI Signals
        MOSI                 : out std_logic;
        MISO                 : in std_logic;
        SCLK                 : out std_logic;
        CSn                  : out std_logic;
        INT                  : out std_logic
    );
end axi_spi;

architecture arch_imp of axi_spi is

    constant SPI_WIDTH  :   integer :=  8;

    signal WDATA  :    std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    signal RDATA  :    std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
    signal RADDR  :    std_logic_vector(C_AXI_ADDR_WIDTH -1 downto 0);
    signal WADDR  :    std_logic_vector(C_AXI_ADDR_WIDTH -1 downto 0);
    signal WENA   :    std_logic;                           
    signal RENA   :    std_logic;

begin

    AXI_REGISTERS: entity work.axi_lite_slave_int
        generic map(
            C_S_AXI_ADDR_WIDTH     => C_AXI_ADDR_WIDTH,
            C_S_AXI_DATA_WIDTH     => C_AXI_DATA_WIDTH)
        port map (
            WDATA_O                => WDATA,
            RDATA_I                => RDATA,
            WENA_O                 => WENA,
            RENA_O                 => RENA,
            RADDR_O                => RADDR,
            WADDR_O                => WADDR,
            S_AXI_ACLK             => AXI_ACLK,
            S_AXI_ARESETN          => AXI_ARESETN,
            S_AXI_AWADDR           => AXI_AWADDR,
            S_AXI_AWVALID          => AXI_AWVALID,
            S_AXI_AWREADY          => AXI_AWREADY,
            S_AXI_WDATA            => AXI_WDATA,
            S_AXI_WSTRB            => AXI_WSTRB,
            S_AXI_WVALID           => AXI_WVALID,
            S_AXI_WREADY           => AXI_WREADY,
            S_AXI_BRESP            => AXI_BRESP,
            S_AXI_BVALID           => AXI_BVALID,
            S_AXI_BREADY           => AXI_BREADY,
            S_AXI_ARADDR           => AXI_ARADDR,
            S_AXI_ARVALID          => AXI_ARVALID,
            S_AXI_ARREADY          => AXI_ARREADY,
            S_AXI_RDATA            => AXI_RDATA,
            S_AXI_RRESP            => AXI_RRESP,
            S_AXI_RVALID           => AXI_RVALID,
            S_AXI_RREADY           => AXI_RREADY
        );    

   
    ---------------------------------------------------------
    -- Intanciar CORE AQUI!
    
    REG_SPI : entity work.spi
        generic map (
            SPI_WIDTH   =>  SPI_WIDTH,
            AXI_WIDTH   =>  C_AXI_DATA_WIDTH,
            ADDR_WIDTH  =>  C_AXI_ADDR_WIDTH,
            CLK_FREQ    =>  100000000,
            SPI_FREQ    =>  1000000    
        )
        port map (
            clk         =>  AXI_ACLK,
            rst         =>  AXI_ARESETN,
            -- Puerto de escritura
            i_wdata     =>  WDATA(SPI_WIDTH-1 downto 0),
            i_waddr     =>  WADDR,
            i_wena      =>  WENA,
            -- Puerto de lectura
            o_rdata     =>  RDATA,
            i_raddr     =>  RADDR,
            i_rena      =>  RENA,         
            -- Trigger del spi
            o_int       =>  INT,
            -- SPI interface
            i_MISO      =>  MISO, 
            o_MOSI      =>  MOSI,  
            o_SCLK      =>  SCLK,
            o_CSn       =>  CSn
        );
        
    ---------------------------------------------------------

end architecture arch_imp;