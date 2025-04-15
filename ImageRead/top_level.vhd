library ieee;
use ieee.std_logic_1164.all;


entity top_level is 

port (
	CLOCK2_50 		: in std_logic;
	KEY				: in std_logic_vector(3 downto 0);

	VGA_B           : out std_logic_vector(7 downto 0);
	VGA_BLANK_N     : out std_logic;
	VGA_CLK         : out std_logic;
	VGA_G           : out std_logic_vector(7 downto 0);
	VGA_HS          : out std_logic;
	VGA_R           : out std_logic_vector(7 downto 0);
	VGA_SYNC_N      : out std_logic;
	VGA_VS          : out std_logic

);

end entity top_level;




architecture behavioral of top_level is

component vga_driver is
port(
     clk_50: in std_logic;

	  rst: in std_logic;
	  vga_r: out std_logic_vector(7 downto 0) := (others => '1');
	  vga_g: out std_logic_vector(7 downto 0) := (others => '1');
	  vga_b: out std_logic_vector(7 downto 0) := (others => '1');

	  vga_clk: out std_logic;
	  vga_blank: out std_logic;
	  vga_hs: out std_logic;
	  vga_vs: out std_logic;
	  vga_sync: out std_logic
);
end component;

begin   

u0: vga_driver port map(
	clk_50 	=> CLOCK2_50,
	rst 		=> KEY(1),

	vga_r 		=> VGA_R,
	vga_g 		=> VGA_G,
	vga_b 		=> VGA_B,
	vga_clk 		=> VGA_CLK,
	vga_blank 	=> VGA_BLANK_N,
	vga_hs 		=> VGA_HS,
	vga_vs		=> VGA_VS,
	vga_sync		=> VGA_SYNC_N

);


end behavioral;