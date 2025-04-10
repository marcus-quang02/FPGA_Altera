library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is 

port(
	clk 		: in std_logic;
	reset 	: in std_logic;
	SW			: in std_logic_vector(2 downto 0);
	LEDR		: out std_logic_vector ( 15 downto 0)
);

end top_level;



architecture behavioral of top_level is

signal clk_125, clk_100, clk_50, clk_40, clk_25 : std_logic;

signal test_clk :std_logic;
signal freq : std_logic_vector(15 downto 0);


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
			reset_reset => reset, 	--   reset.reset
			clk_125_clk => clk_125, -- clk_125.clk
			clk_100_clk => clk_100, -- clk_100.clk
			clk_50_clk  => clk_50,  --  clk_50.clk
			clk_40_clk  => clk_40,  --  clk_40.clk
			clk_25_clk  => clk_25   --  clk_25.clk
	);
	
	LEDR <= freq;
	test_clk <= clk_125 when ( sw( 2 downto 0 ) = "000") else
				clk_100 when ( sw( 2 downto 0 ) = "001") else
				clk_50 when ( sw( 2 downto 0 ) = "010") else
				clk_40 when ( sw( 2 downto 0 ) = "011") else
				clk_25 when ( sw( 2 downto 0 ) = "100") ;





end behavioral;










