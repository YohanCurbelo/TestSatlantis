library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

entity spi is
    generic (
        SPI_WIDTH   :   positive    :=  8;
        AXI_WIDTH   :   positive    :=  32;
        ADDR_WIDTH  :   positive    :=  4;
        CLK_FREQ    :   positive    :=  100000000;
        SPI_FREQ    :   positive    :=  1000000    
    );
    port (
        clk         :   in std_logic;
        rst         :   in std_logic;
        -- Puerto de escritura
        i_wdata     :   in  std_logic_vector(SPI_WIDTH-1 downto 0);
        i_waddr     :   in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        i_wena      :   in  std_logic;
        -- Puerto de lectura
        o_rdata     :   out std_logic_vector(AXI_WIDTH-1 downto 0);
        i_raddr     :   in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        i_rena      :   in  std_logic;          
        -- Trigger del spi
        o_int       :   out std_logic;
        -- SPI interface
        i_MISO      :   in  std_logic;
        o_MOSI      :   out std_logic;   
        o_SCLK      :   out std_logic;
        o_CSn       :   out std_logic
    );
end spi;

architecture behavioral of spi is

    -- Registros de configuracion (0x00 - Dato que se va a trasmitir; 0x04 - Ultimo dato recibido)
    type configuration_register is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(SPI_WIDTH-1 downto 0);
    signal registers_spi:   configuration_register;
    constant    REG_TX  :   integer :=  0;  -- Registro de RX 0x00
    constant    REG_RX  :   integer :=  4;  -- Registro de RX 0x04

    -- Señales intermedias de los registros de configuracion
    -- Primer puerto de escritura
    signal wena1        :   std_logic;                                          -- Write enable
    signal waddr1       :   std_logic_vector(ADDR_WIDTH-1 downto 0);            -- Write address
    signal wdata1       :   std_logic_vector(SPI_WIDTH-1 downto 0);             -- Write data
    -- Primer puerto de lectura
    signal rena1        :   std_logic;                                          -- Read enable
    signal raddr1       :   std_logic_vector(ADDR_WIDTH-1 downto 0);            -- Read address
    signal rdata1       :   std_logic_vector(SPI_WIDTH-1 downto 0);             -- Read data
    signal pad_zeros    :   std_logic_vector(AXI_WIDTH-SPI_WIDTH-1 downto 0);   -- Paddding to fit AXI and SPI buses
    -- Segundo puerto de escritura
    signal wena2        :   std_logic;                                          -- Write enable
    signal waddr2       :   std_logic_vector(ADDR_WIDTH-1 downto 0);            -- Write address
    signal wdata2       :   std_logic_vector(SPI_WIDTH-1 downto 0);             -- Write data
    -- Segundo puerto de lectura
    signal rena2        :   std_logic;                                          -- Read enable
    signal raddr2       :   std_logic_vector(ADDR_WIDTH-1 downto 0);            -- Read address
    signal rdata2       :   std_logic_vector(SPI_WIDTH-1 downto 0);             -- Read data
    -- Trigger para iniciar la transmision por spi
    signal spi_en       :   std_logic;


    -- Subtype para el divisor de frecuencia y aprovechar el uso del atributo HIGH
    subtype integer_subtype is integer range 0 to integer(ceil(real((CLK_FREQ/SPI_FREQ)/2)))-1;
    signal div_freq     :   integer_subtype;

    -- Señales intermedias del spi
    signal sclk         :   std_logic;
    signal sclk_en      :   std_logic;
    signal data_tx      :   std_logic_vector(SPI_WIDTH-1 downto 0);
    signal data_rx      :   std_logic_vector(SPI_WIDTH-1 downto 0);
    signal bit_ctr      :   integer range 0 to SPI_WIDTH+1;             -- Contador para la escritura/lectura bit a bit del dato

    -- Estados de la maquina de estado
    type states is (idle, ask_REG_TX, get_REG_TX, transaction);
    signal state        :   states;

begin

    -- Acceso a los registros de configuracion
    wena1   <=  i_wena;
    waddr1  <=  i_waddr;
    wdata1  <=  i_wdata;   

    acceso_reg  :   process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                spi_en          <=  '0';
                rdata1          <=  (others => '0');
                rdata2          <=  (others => '0');
                pad_zeros       <=  (others => '0');
                registers_spi   <=  (others => (others => '0'));                               
            else
                spi_en          <=  wena1;
                -- Puerto d escritura 1
                if wena1 ='1' then                    
                    registers_spi(to_integer(unsigned(waddr1))) <=  wdata1;                      
                end if;

                -- Puerto de escritura 2
                if wena2 ='1' then
                    registers_spi(to_integer(unsigned(waddr2))) <=  wdata2;  
                end if;

                -- Puerto de lectura 1
                if rena1 ='1' then
                    rdata1      <=  registers_spi(to_integer(unsigned(raddr1)));
                end if;
                
                -- Puerto de lectura 2
                if rena2 ='1' then
                    rdata2      <=  registers_spi(to_integer(unsigned(raddr2)));
                end if;                
            end if;
        end if;
    end process;

    rena1   <=  i_rena;
    raddr1  <=  i_raddr;
    o_rdata <=  pad_zeros & rdata1;

    -- Divisor de frecuencia para obtener SCLK (1 MHz) a partir del AXI_CLK (100 MHz)
    spi_sclk    :   process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                div_freq    <=  0;
                sclk        <=  '0';
            elsif sclk_en = '1' then
                if div_freq = integer_subtype'HIGH then                    
                    div_freq    <=  0;
                    sclk        <=  not sclk;
                else
                    div_freq    <=  div_freq + 1;
                end if;
            else
                div_freq    <=  0;
                sclk        <=  '0';
            end if;
        end if;
    end process;
    
    o_SCLK  <=  sclk;    

    -- Maquina de estados
    fsm_p   :   process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                state           <=  idle;
                bit_ctr         <=  0;
                sclk_en         <=  '0';  
                o_CSn           <=  '1';
                o_MOSI          <=  'Z'; 
                o_int           <=  '0';     
                wena2           <=  '0';              
                wdata2          <=  (others => '0');
                waddr2          <=  (others => '0');     
                rena2           <=  '0';              
                raddr2          <=  (others => '0');                                       
                data_tx         <=  (others => '0');
                data_rx         <=  (others => '0');
            else
                case state is
                    when idle           =>  o_int           <=  '0';  
                                            wena2           <=  '0';              
                                            wdata2          <=  (others => '0');
                                            waddr2          <=  (others => '0');    
                                            if spi_en = '1' then
                                                state       <=  ask_REG_TX;                                                
                                                raddr2      <=  std_logic_vector(to_unsigned(REG_TX, ADDR_WIDTH));
                                                rena2       <=  '1';                                               
                                            end if;
                                            
                    when ask_REG_TX     =>  state           <=  get_REG_TX;
                                            raddr2         <=  (others => '0');  
                                            rena2          <=  '0';                                              
                                            
                    when get_REG_TX     =>  state           <=  transaction;
                                            data_tx         <=  rdata2;                                     
                                            sclk_en         <=  '1'; 
                                            o_CSn           <=  '0';                         
                    
                    when transaction    =>  if bit_ctr <= SPI_WIDTH then                                                
                                                -- Escritura en MOSI
                                                if div_freq = 0 and sclk = '0' then
                                                    bit_ctr <=  bit_ctr + 1;
                                                    o_MOSI  <=  data_tx(SPI_WIDTH-1);
                                                    data_tx <=  data_tx(SPI_WIDTH-2 downto 0) & '0';
                                                end if ;  
                                                -- Lectura de MISO
                                                if div_freq = 0 and sclk = '1' then
                                                    data_rx <=  data_rx(SPI_WIDTH-2 downto 0) & i_MISO; 
                                                end if;
                                            else
                                                state       <=  idle;
                                                bit_ctr     <=  0;
                                                sclk_en     <=  '0';
                                                o_CSn       <=  '1';
                                                o_MOSI      <=  'Z';
                                                o_int       <=  '1';
                                                wena2       <=  '1';              
                                                wdata2      <=  data_rx;
                                                waddr2      <=  std_logic_vector(to_unsigned(REG_RX, ADDR_WIDTH));                                               
                                            end if;
                    end case;
            end if;
        end if;
    end process;   

end behavioral;