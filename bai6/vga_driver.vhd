library ieee;
use ieee.std_logic_1164.all;
entity vga_driver is
port(
     clk_50: in std_logic;
	  -- clk_27: in std_logic;
	  rst: in std_logic;
	  vga_r: out std_logic_vector(7 downto 0) :=(others => '1');
	  vga_g: out std_logic_vector(7 downto 0) :=(others => '1');
	  vga_b: out std_logic_vector(7 downto 0) :=(others => '1');
--     vga_rgb: out std_logic_vector(2 downto 0);
	  vga_clk: out std_logic;
	  vga_blank: out std_logic;
	  vga_hs: out std_logic;
	  vga_vs: out std_logic;
	  vga_sync: out std_logic
);
end vga_driver;


architecture test of vga_driver is
constant Hor_Sync_Time : natural:=96; --Pixels
constant Hor_Back_Porch: natural:=48;
constant Hor_Front_Porch: natural :=16;
constant Hor_Addr_Video_Time: natural := 640;

constant V_Sync_Time: natural :=2;
constant V_Back_Porch: natural :=33;
constant V_Front_Porch: natural :=10;
constant V_Addr_Video_Time: natural := 480;

constant HPOS_MAX: natural:=(Hor_Sync_Time + Hor_Back_Porch + Hor_Front_Porch + Hor_Addr_Video_Time);
constant VPOS_MAX: natural:=(V_Sync_Time + V_Back_Porch + V_Front_Porch + V_Addr_Video_Time);

constant H_VIDEO_CENTER: natural:=(Hor_Sync_Time+Hor_Back_Porch+Hor_Front_Porch+Hor_Addr_Video_Time/2);
constant V_VIDEO_CENTER: natural:=(V_Sync_Time + V_Back_Porch + V_Front_Porch + V_Addr_Video_Time/2);


signal video: std_logic:='0';
signal rst1: std_logic:='0';
signal clk_25 : std_logic:='0'; --Pixel clock
signal h_counter: integer range 0 to HPOS_MAX;
signal v_counter: integer range 0 to VPOS_MAX;


signal square_x :integer := 480;

signal square_counter : integer range 0 to 25200000 ;
signal blink				: std_logic ;

constant square_size 	: integer := 100;



signal dir_x    : integer := 1;  -- +1 for right, -1 for left

signal move_counter : integer range 0 to 4_999_999 := 0;
signal move_tick    : std_logic := '0';


component PLL is
        port (
            clk_50_clk  : in  std_logic := 'X'; -- clk
            rst_reset : in  std_logic := 'X'; -- reset
            clk_out_clk : out std_logic         -- clk
        );
   end component PLL;
	

BEGIN
	
vga_clk<=clk_25;
c1 : PLL port map (clk_50, rst, clk_25);

HORIZONTAL_POSITION_COUNTER: process(clk_25,rst)
begin
     if(rst='0') then
	     h_counter<=0;
	  elsif(clk_25'event and clk_25='1') then
		     if(h_counter = HPOS_MAX) then
			     h_counter<= 0;
			  else
			     h_counter<= h_counter+1;
			  end if;
	  end if;
end process;

VERTICAL_POSITION_COUNTER: process(clk_25,rst)
begin
     if(rst='0') then
	     v_counter<=0;
	  elsif(clk_25'event and clk_25='1') then
	       if(h_counter = HPOS_MAX) then
		     if(v_counter = VPOS_MAX) then
			     v_counter <= 0;
			  else
			     v_counter <= v_counter+1;
			  end if;
			 end if;
	  end if;
end process;


HORIZONTAL_SYNCHRONIZATION: process(clk_25,rst,h_counter)
begin
     if(rst='0') then
	     vga_hs<='0';
	  elsif(clk_25'event and clk_25='1') then
		     if((h_counter> Hor_Front_Porch) and (h_counter< (Hor_Front_Porch + Hor_Sync_Time))) then
			     vga_hs <='0';
			  else
			     vga_hs <='1';
			  end if;
	  end if;
end process;


VERTICAL_SYNCHRONIZATION: process(clk_25,rst,v_counter)
begin
     if(rst='0') then
	     vga_vs<='0';
	  elsif(clk_25'event and clk_25='1') then
	       if((v_counter>V_Front_Porch)and(v_counter<(V_Front_Porch+V_Sync_Time))) then
			    vga_vs<='0';
			 else
			    vga_vs<='1';
			 end if;
	  end if;
end process;


VIDEO_ON: process(clk_25,rst,v_counter,h_counter) 
begin
     if(rst='0') then
	     video <='0';
	  elsif (clk_25'event and clk_25='1') then
        if(h_counter > (Hor_Sync_Time + Hor_Back_Porch + Hor_Front_Porch)) and (v_counter > (V_Sync_Time + V_Back_Porch + V_Front_Porch)) then
		     video		<='1';
			  vga_blank	<='1';
			  vga_sync	<='1';
		  else
		     video		<='0';
			  vga_blank	<='0';
			  vga_sync	<='1';
	     end if;
		  
	  end if;     
end process;

DISPLAY: process(clk_25, rst, h_counter, video, v_counter)
begin
  if (rst = '0') then
    vga_r <= (others => '0');
    vga_g <= (others => '0');
    vga_b <= (others => '0');

elsif rising_edge(clk_25) then
    if (video = '1') then
        if ((h_counter - H_VIDEO_CENTER) * (h_counter - H_VIDEO_CENTER) + 
            (v_counter - V_VIDEO_CENTER) * (v_counter - V_VIDEO_CENTER) < 40000) then
            -- Inside the circle
            vga_r <= (others => '1');
            vga_g <= (others => '1');
            vga_b <= (others => '1');

				if (h_counter > square_x - square_size/2 ) and (h_counter < square_x + square_size/2) and 
					  (v_counter > 235) and (v_counter < 335) then
--					if ( blink = '1' ) then 
--					-- Small pink box
--						vga_r <= (others => '1');
--						vga_g <= (others => '0');
--						vga_b <= (others => '1');
--					else 
						vga_r <= (others => '0');
						vga_g <= (others => '0');
						vga_b <= (others => '1');
--					end if;
				end if;

        else
            -- Red background
            vga_r <= (others => '1');
            vga_g <= (others => '0');
            vga_b <= (others => '0');
        end if;

    else
        -- Video off, output black
        vga_r <= (others => '0');
        vga_g <= (others => '0');
        vga_b <= (others => '0');
    end if;
end if;

end process;


BLINKING_SQUARE : process (clk_25) 
begin

	if  rising_edge(clk_25)  then
		if (square_counter < 25200000) then 
			square_counter <= square_counter + 1;
		else 
			blink <= not blink;
			square_counter <= 0;
		end if;
	end if;

end process;
     

process(clk_25, rst)
begin
    if rst = '0' then
        move_counter <= 0;
        move_tick <= '0';
    elsif rising_edge(clk_25) then
        if move_counter = 4_999_999 then
            move_tick <= '1';
            move_counter <= 0;
        else
            move_tick <= '0';
            move_counter <= move_counter + 1;
        end if;
    end if;
end process;



process(clk_25, rst)
begin
    if rst = '0' then
	 
        square_x <= 460;
        dir_x <= 1;
		  
    elsif rising_edge(clk_25) then
        if move_tick = '1' then
            -- Update X
            if square_x <= 0 then
                dir_x <= 1;
            elsif square_x >= 640 - 100 then  -- prevent going out of bounds
                dir_x <= -1;
            end if;
            square_x <= square_x + dir_x;

        end if;
    end if;
end process;

end test;

