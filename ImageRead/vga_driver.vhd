library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vga_driver is
port(
     clk_50: in std_logic;
	  rst: in std_logic;
	  
	  
	  vga_r: out std_logic_vector(7 downto 0) :=(others => '1');
	  vga_g: out std_logic_vector(7 downto 0) :=(others => '1');
	  vga_b: out std_logic_vector(7 downto 0) :=(others => '1');

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

constant H_VIDEO_CENTER: natural:=(Hor_Sync_Time+Hor_Back_Porch+Hor_Front_Porch + Hor_Addr_Video_Time/2);
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

type string is array ( 0 to 15) of std_logic_vector( 7 downto 0);
signal addr    : integer range 0 to 307199 := 0; 

constant ADDR_BUS_SIZE : INTEGER := 20;
constant DATA_BUS_SIZE : INTEGER := 8;

signal read_addr :  	 STD_logic_vector((ADDR_BUS_SIZE-1) downto 0) := "00000000000000000000";
signal write_addr: 	 STD_logic_vector((ADDR_BUS_SIZE-1) downto 0) := "00000000000000000000";
signal write_en	:	 STD_LOGIC := '0';
signal read_en		:	 STD_LOGIC := '0';

signal data_in		:  std_logic_vector((DATA_BUS_SIZE-1) DOWNTO 0);
signal data_out	:  std_logic_vector((DATA_BUS_SIZE-1) DOWNTO 0);

signal delayed_data : std_logic_vector(7 downto 0);
signal blink_state : std_logic := '0'; 


component PLL is
        port (
            clk_50_clk  : in  std_logic := 'X'; -- clk
            rst_reset : in  std_logic := 'X'; -- reset
            clk_out_clk : out std_logic         -- clk
        );
end component PLL;


component image_read is 
  generic (
    ADDR_WIDTH     	: integer := 20;  ---- 2^20 = 1048576
	IMAGE_SIZE     	: integer := 307199;  ---- 640*480-1   
    DATA_WIDTH     	: integer := 8
  );
port (
    clock: 				IN STD_LOGIC;

    rdaddress: 		IN STD_logic_vector((ADDR_WIDTH-1) downto 0);
    wraddress: 		IN STD_logic_vector((ADDR_WIDTH-1) downto 0);
	 
    we: 					IN STD_LOGIC;
    re: 					IN STD_LOGIC;
	data_in: 			IN std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
    data_out: 			OUT std_logic_vector((DATA_WIDTH-1) DOWNTO 0)
);
end component;



begin

vga_clk<= clk_25;

c1 : PLL port map (clk_50, rst, clk_25);

c2 : image_read port map (clk_25,read_addr,write_addr, write_en, read_en, data_in, data_out);

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
		vga_r <= data_out(7 downto 0);
		vga_g <= data_out(7 downto 0);
		vga_b <= data_out(7 downto 0);
    else
        vga_r <= (others => '0');
        vga_g <= (others => '0');
        vga_b <= (others => '0');
    end if;
end if;

	
end process;


READ_MEMORY : process(clk_25, rst, h_counter, v_counter)
begin 
   if (rst = '0') then
	   read_en <= '0';
	   read_addr <= (others => '0');
   elsif rising_edge(clk_25) then
		if (h_counter > (Hor_Sync_Time + Hor_Back_Porch + Hor_Front_Porch)) and (v_counter > (V_Sync_Time + V_Back_Porch + V_Front_Porch)) then
				if (addr < 307199) then
					addr <= addr + 1;
				else
					addr <= 0;
				end if;
		end if;

	   if (video = '1') then
                read_en <= '1';
                read_addr <= std_logic_vector(to_unsigned(addr, ADDR_BUS_SIZE));
        else
			   read_en <= '0';
		end if;
   end if;
end process;

-- ADDRESS_INCREMENT : process (clk_25) 
-- begin

-- 	if  rising_edge(clk_25)  then
-- 		if (square_counter < 25_200_000) then 
-- 			square_counter <= square_counter + 1;
-- 		else 
-- 			if addr < 15 then
-- 				addr <= addr + 1;
-- 			else
-- 				addr <= 0;
-- 			end if;
-- 			square_counter <= 0;
-- 		end if;
-- 	end if;

-- end process;


--MOVING_SQUARE: process(clk_25, rst)
--begin
--    if rst = '0' then
--	 
--        square_x <= 460;
--        dir_x <= 1;
--    elsif rising_edge(clk_25) then
--        if addr  then
--            -- Update X
--            if square_x <= 0 then
--                dir_x <= 1;
--            elsif square_x >= 640 - 100 then  -- prevent going out of bounds
--                dir_x <= -1;
--            end if;
--            square_x <= square_x + dir_x;
--        end if;
--    end if;
--end process;

end test;

