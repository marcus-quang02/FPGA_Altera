library ieee;
use ieee.STD_LOGIC_1164.ALL;


entity top_level is
    port (
        -- Clock Inputs
        CLOCK_50        : in  std_logic;
        CLOCK2_50       : in  std_logic;
        CLOCK3_50       : in  std_logic;
        -- Push Buttons
        KEY             : in  std_logic_vector(3 downto 0);
        -- Slide Switches
        SW              : in  std_logic_vector(17 downto 0);
        -- LEDs
        LEDR            : out std_logic_vector(17 downto 0);
        LEDG            : out std_logic_vector(8 downto 0);
        -- 7-Segment Displays
        HEX0            : out std_logic_vector(6 downto 0);
        HEX1            : out std_logic_vector(6 downto 0);
        HEX2            : out std_logic_vector(6 downto 0);
        HEX3            : out std_logic_vector(6 downto 0);
        HEX4            : out std_logic_vector(6 downto 0);
        HEX5            : out std_logic_vector(6 downto 0);
        HEX6            : out std_logic_vector(6 downto 0);
        HEX7            : out std_logic_vector(6 downto 0);
        -- SDRAM Interface
        DRAM_ADDR       : out std_logic_vector(12 downto 0);
        DRAM_BA         : out std_logic_vector(1 downto 0);
        DRAM_CAS_N      : out std_logic;
        DRAM_CKE        : out std_logic;
        DRAM_CLK        : out std_logic;
        DRAM_CS_N       : out std_logic;
        DRAM_DQ         : inout std_logic_vector(31 downto 0);
        DRAM_DQM        : out std_logic_vector(3 downto 0);
        DRAM_RAS_N      : out std_logic;
        DRAM_WE_N       : out std_logic;
        -- SRAM Interface
        SRAM_ADDR       : out std_logic_vector(19 downto 0);
        SRAM_CE_N       : out std_logic;
        SRAM_DQ         : inout std_logic_vector(15 downto 0);
        SRAM_LB_N       : out std_logic;
        SRAM_OE_N       : out std_logic;
        SRAM_UB_N       : out std_logic;
        SRAM_WE_N       : out std_logic;
        -- Flash Interface
        FL_ADDR         : out std_logic_vector(22 downto 0);
        FL_CE_N         : out std_logic;
        FL_DQ           : inout std_logic_vector(7 downto 0);
        FL_OE_N         : out std_logic;
        FL_RST_N        : out std_logic;
        FL_WE_N         : out std_logic;
        FL_WP_N         : out std_logic;
        -- SD Card Interface
        SD_CLK          : out std_logic;
        SD_CMD          : inout std_logic;
        SD_DAT          : inout std_logic_vector(3 downto 0);
        -- USB Interface
        OTG_ADDR        : out std_logic_vector(1 downto 0);
        OTG_CS_N        : out std_logic;
        OTG_DACK_N      : out std_logic;
        OTG_DATA        : inout std_logic_vector(15 downto 0);
        OTG_DREQ        : in  std_logic;
        OTG_FSPEED      : out std_logic;
        OTG_INT         : in  std_logic;
        OTG_LSPEED      : out std_logic;
        OTG_RD_N        : out std_logic;
        OTG_RST_N       : out std_logic;
        OTG_WE_N        : out std_logic;
        -- Ethernet Interface
        ENET0_GTX_CLK   : out std_logic;
        ENET0_INT_N     : in  std_logic;
        ENET0_LINK100   : in  std_logic;
        ENET0_MDC       : out std_logic;
        ENET0_MDIO      : inout std_logic;
        ENET0_RST_N     : out std_logic;
        ENET0_RX_CLK    : in  std_logic;
        ENET0_RX_COL    : in  std_logic;
        ENET0_RX_CRS    : in  std_logic;
        ENET0_RX_DATA   : in  std_logic_vector(3 downto 0);
        ENET0_RX_DV     : in  std_logic;
        ENET0_RX_ER     : in  std_logic;
        ENET0_TX_CLK    : in  std_logic;
        ENET0_TX_DATA   : out std_logic_vector(3 downto 0);
        ENET0_TX_EN     : out std_logic;
        ENET0_TX_ER     : out std_logic;
        ENET0_CLKIN     : in  std_logic;
        ENET1_GTX_CLK   : out std_logic;
        ENET1_INT_N     : in  std_logic;
        ENET1_LINK100   : in  std_logic;
        ENET1_MDC       : out std_logic;
        ENET1_MDIO      : inout std_logic;
        ENET1_RST_N     : out std_logic;
        ENET1_RX_CLK    : in  std_logic;
        ENET1_RX_COL    : in  std_logic;
        ENET1_RX_CRS    : in  std_logic;
        ENET1_RX_DATA   : in  std_logic_vector(3 downto 0);
        ENET1_RX_DV     : in  std_logic;
        ENET1_RX_ER     : in  std_logic;
        ENET1_TX_CLK    : in  std_logic;
        ENET1_TX_DATA   : out std_logic_vector(3 downto 0);
        ENET1_TX_EN     : out std_logic;
        ENET1_TX_ER     : out std_logic;
        ENET1_CLKIN     : in  std_logic;
        -- VGA Interface
        VGA_B           : out std_logic_vector(7 downto 0);
        VGA_BLANK_N     : out std_logic;
        VGA_CLK         : out std_logic;
        VGA_G           : out std_logic_vector(7 downto 0);
        VGA_HS          : out std_logic;
        VGA_R           : out std_logic_vector(7 downto 0);
        VGA_SYNC_N      : out std_logic;
        VGA_VS          : out std_logic;
        -- Audio Interface
        AUD_ADCDAT      : in  std_logic;
        AUD_ADCLRCK     : inout std_logic;
        AUD_BCLK        : inout std_logic;
        AUD_DACDAT      : out std_logic;
		  AUD_DACLRCK     : inout std_logic;
        AUD_XCK         : out std_logic;

        -- PS2 Ports
        PS2_CLK         : inout std_logic;
        PS2_DAT         : inout std_logic;
        PS2_CLK2        : inout std_logic;
        PS2_DAT2        : inout std_logic;

        -- I2C Interface
        I2C_SCLK        : out std_logic;
        I2C_SDAT        : inout std_logic;

        -- GPIO
        GPIO            : inout std_logic_vector(35 downto 0);

        -- HSMC (High-Speed Mezzanine Card) Interface
        HSMC_CLKIN0     : in std_logic;
        HSMC_CLKIN_P1   : in std_logic;
        HSMC_CLKIN_P2   : in std_logic;
        HSMC_CLKIN_P3   : in std_logic;
        HSMC_CLKOUT0    : out std_logic;
        HSMC_CLKOUT_P1  : out std_logic;
        HSMC_CLKOUT_P2  : out std_logic;
        HSMC_CLKOUT_P3  : out std_logic;
        HSMC_D          : inout std_logic_vector(3 downto 0);
        HSMC_RX_D_P     : in std_logic_vector(3 downto 0);
        HSMC_TX_D_P     : out std_logic_vector(3 downto 0);

        -- IR Receiver
        IRDA_RXD        : in std_logic;

        -- TD (Video In)
        TD_CLK27        : in std_logic;
        TD_DATA         : in std_logic_vector(7 downto 0);
        TD_HS           : in std_logic;
        TD_VS           : in std_logic;
        TD_RESET_N      : out std_logic;
		  -- LCD Display
        LCD_BLON        : out std_logic;
        LCD_DATA        : inout std_logic_vector(7 downto 0);
        LCD_EN          : out std_logic;
        LCD_ON          : out std_logic;
        LCD_RS          : out std_logic;
        LCD_RW          : out std_logic;

		  UART_RXD             : in  std_logic;                      -- UART receive
        UART_TXD             : out std_logic                    -- UART transmit
		  

    );
end entity top_level;





architecture behavioral of top_level is


begin

end behavioral;