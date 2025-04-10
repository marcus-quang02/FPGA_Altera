	component pll is
		port (
			clk_50_clk  : in  std_logic := 'X'; -- clk
			clk_out_clk : out std_logic;        -- clk
			rst_reset   : in  std_logic := 'X'  -- reset
		);
	end component pll;

	u0 : component pll
		port map (
			clk_50_clk  => CONNECTED_TO_clk_50_clk,  --  clk_50.clk
			clk_out_clk => CONNECTED_TO_clk_out_clk, -- clk_out.clk
			rst_reset   => CONNECTED_TO_rst_reset    --     rst.reset
		);

