library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is 

port(
	clk 		: in std_logic;
	reset 		: in std_logic;
	SW			: in std_logic_vector(2 downto 0);
	HEX0		: out std_logic_vector(6 downto 0);
	HEX1		: out std_logic_vector(6 downto 0);
	HEX2		: out std_logic_vector(6 downto 0);
	LEDR		: out std_logic_vector(15 downto 0)
);

end top_level;



architecture behavioral of top_level is

signal clk_125, clk_100, clk_50, clk_40, clk_25 : std_logic;

signal test_clk :std_logic;
signal freq : std_logic_vector(15 downto 0);

signal middle	: integer;


-- Seven-segment decoder for digits 0-9
    function SevenSegDecoder (digit: integer) return std_logic_vector is
    begin
        case digit is
            when 0 => return "1000000";  -- 0
            when 1 => return "1111001";  -- 1
            when 2 => return "0100100";  -- 2
            when 3 => return "0110000";  -- 3
            when 4 => return "0011001";  -- 4
            when 5 => return "0010010";  -- 5
            when 6 => return "0000010";  -- 6
            when 7 => return "1111000";  -- 7
            when 8 => return "0000000";  -- 8
            when 9 => return "0010000";  -- 9
            when others => return "1111111"; -- All segments off
        end case;
    end SevenSegDecoder;


component freq_measure is
port (
  i_clk_ref            : in  std_logic;
  i_clk_test           : in  std_logic;
  i_rstb               : in  std_logic;
  o_clock_freq         : out std_logic_vector(15 downto 0));

 end component freq_measure;

	component pll is
		port (
			clk_in_clk  : in  std_logic := 'X'; -- clk
			reset_reset : in  std_logic := 'X'; -- reset
			clk_125_clk : out std_logic;        -- clk
			clk_100_clk : out std_logic;        -- clk
			clk_50_clk  : out std_logic;        -- clk
			clk_40_clk  : out std_logic;        -- clk
			clk_25_clk  : out std_logic         -- clk
		);
	end component pll;


	
begin
	
	u0 : component freq_measure
		port map (
		i_clk_ref       => clk,
		i_clk_test      => test_clk,
		i_rstb          => reset,
		o_clock_freq    => freq
	);
	
	u1 : component pll
		port map (
			clk_in_clk  => clk,  	--  clk_in.clk
			reset_reset => reset, 	--  reset.reset
			clk_125_clk => clk_125, -- 	clk_125.clk
			clk_100_clk => clk_100, -- 	clk_100.clk
			clk_50_clk  => clk_50,  --  clk_50.clk
			clk_40_clk  => clk_40,  --  clk_40.clk
			clk_25_clk  => clk_25   --  clk_25.clk
	);
	
	
	LEDR <= freq;
	
	middle <= to_integer(( unsigned(freq) / 82	 ) + 1 )  ;
	HEX2 <= SevenSegDecoder(middle / 100);
	HEX1 <= SevenSegDecoder( (middle /10) mod 10  );
	HEX0 <= SevenSegDecoder( middle mod 10  );
	

	
	 
	test_clk <=	clk_25 	when ( sw( 2 downto 0 ) = "000") else
				clk_40 	when ( sw( 2 downto 0 ) = "001") else
				clk_50 	when ( sw( 2 downto 0 ) = "010") else
				clk_100 when ( sw( 2 downto 0 ) = "011") else
				clk_125 ;


end behavioral;










