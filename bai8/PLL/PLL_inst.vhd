	component PLL is
		port (
			clk_in_1_clk  : in  std_logic := 'X'; -- clk
			reset_reset   : in  std_logic := 'X'; -- reset
			clk_out_1_clk : out std_logic         -- clk
		);
	end component PLL;

	u0 : component PLL
		port map (
			clk_in_1_clk  => CONNECTED_TO_clk_in_1_clk,  --  clk_in_1.clk
			reset_reset   => CONNECTED_TO_reset_reset,   --     reset.reset
			clk_out_1_clk => CONNECTED_TO_clk_out_1_clk  -- clk_out_1.clk
		);

