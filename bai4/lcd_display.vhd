library IEEE;
use IEEE.std_logic_1164.all;

entity lcd_display is
 -- generic (data_byte: integer:=8);
  port(
		clk_50: in std_logic;
		 rst: in std_logic;

		 --LCD
		 lcd_rs: out std_logic;
		 lcd_en: out std_logic;
		 lcd_rw: out std_logic;
		 lcd_on: out std_logic;
		 lcd_blon: out std_logic;
		 lcd_data: inout std_logic_vector(7 downto 0)
		 
       );
end lcd_display;

architecture test of lcd_display is
  type lcd_state is (return_home,display_string,idle_lcd,reset,line2_mode, set_cursor_blinking, mode_set, function_set,
											display_off, display_on, clear_display, idle_lcd_1s );
					 

  type character_string is array (0 to 31) of std_logic_vector(7 downto 0);
  
  
  signal lcd_string: character_string:=(
-- Line 1    H     E     L     L     O           W     O     R    L     D          
          x"48",x"45",x"4C",x"4C",x"4F",x"20",x"57",x"4F",x"52",x"4C",x"44",x"20",x"20",x"20",x"20",x"20",
-- Line 2                       
         x"48",x"45",x"4C",x"4C",x"4F",x"20",x"57",x"4F",x"52",x"4C",x"44",x"20",x"20",x"20",x"20",x"20" 
   );


  signal lcd_present_state,lcd_next_state:lcd_state;
  signal lcd_rw_en: std_logic;
  signal data_value,char: std_logic_vector(7 downto 0);
  signal char_cnt: integer:=0;
  signal clk_400Hz_enable: std_logic;
  signal clk_400Hz_cnt: integer:=0;
  
  signal delay_counter : integer:= 0;
  
  
  begin

  lcd_data 	<= data_value;
  char 		<= lcd_string(char_cnt);
  lcd_rw 	<=	lcd_rw_en;
  
  -- CLOCK PROCESS
  process(clk_50)
  begin
    if rising_edge(clk_50) then
	   if(rst='0') then
		   clk_400Hz_cnt<=0;
			clk_400Hz_enable<='0';
		else
		   if(clk_400Hz_cnt < 62500) then
		      	clk_400Hz_cnt<=clk_400Hz_cnt+1;
				clk_400Hz_enable<='0';
			else
			   	clk_400Hz_cnt<=0;
				clk_400Hz_enable<='1';
			end if;
		end if;
	 end if;
  end process;
  
  -- LCD PROCESS
  process(clk_50)
  begin
    if(rst='0') then
	
		lcd_en<='1';
		lcd_rs<='0';
		lcd_rw_en<='0';
	
		data_value<=x"38";
		
		lcd_present_state<=reset;
		lcd_next_state<=reset;
		 
		 
	 elsif rising_edge(clk_50) then
	    if(clk_400Hz_enable='1') then
			case lcd_present_state is 
				when reset => 
					lcd_en 					<= '1';
					lcd_rs 					<= '0';
					lcd_rw_en 				<= '0';
					
					data_value 				<= x"38";
					
					lcd_present_state 	<= idle_lcd;
					lcd_next_state 		<= function_set ;
					
					char_cnt					<= 0;
					
				when function_set =>
			  
					lcd_en					<=	'1';
					lcd_rs					<=	'0';
					lcd_rw_en				<=	'0';
					
					data_value				<=	x"38";

					lcd_present_state 	<= idle_lcd;
					lcd_next_state 		<= display_off;
					

								
				when display_off =>
				   lcd_en<='1';
					lcd_rs<='0';
					lcd_rw_en<='0';
					
					data_value<=x"08";

					lcd_present_state<=idle_lcd;
					lcd_next_state<=clear_display;
					
				when clear_display =>
				   lcd_en<='1';
					lcd_rs<='0';
					lcd_rw_en<='0';
					
					data_value<=x"01";

					lcd_present_state<=idle_lcd;
					lcd_next_state<=display_on;
					
				when display_on =>
				   lcd_en<='1';
					lcd_rs<='0';
					lcd_rw_en<='0';
					
					data_value<=x"0C";

					lcd_present_state<=idle_lcd;
					lcd_next_state<=mode_set;
					
				when mode_set =>
				   lcd_en					<='1';
					lcd_rs					<='0';
					lcd_rw_en				<='0';
					
					data_value				<=x"06";

					lcd_present_state		<= idle_lcd;
					lcd_next_state			<= display_string;
			
				when set_cursor_blinking =>
					lcd_en 					<= '1';
					lcd_rs 					<= '0';
					lcd_rw_en 				<= '0';
					
					data_value 				<= x"0E";
					
					lcd_present_state 	<= idle_lcd;
					lcd_next_state 		<= display_off;
					
					
				when display_string =>
					lcd_en 					<= '1';
					lcd_rs 					<= '1';
					lcd_rw_en 				<= '0';
				
	
					data_value				<=	char;
					lcd_present_state		<=	idle_lcd_1s;
					
					if(char_cnt < 31) and ( char /= x"FE") then
						char_cnt				<=	char_cnt + 1;
					else
						char_cnt				<= 0;
					end if;
					
					if char_cnt = 15 then
					   lcd_next_state		<= line2_mode;
					elsif (char_cnt = 31) and (char=x"FE") then
					   lcd_next_state		<=	return_home;
					else
					   lcd_next_state		<=	display_string;
					end if;					

				when idle_lcd_1s =>
					lcd_en<='0';
					lcd_blon<='1';
					lcd_on<='1';
					
					if( delay_counter < 40 ) then
						delay_counter <= delay_counter + 1;
						lcd_present_state <= idle_lcd_1s;
						
					else 
						lcd_present_state <= lcd_next_state;
						delay_counter <= 0 ;
					end if;

					
					

					
				when line2_mode =>
					lcd_en					<='1';
					lcd_rs					<='0';
					lcd_rw_en				<='0';
					
					data_value				<=x"C0";
					
					lcd_present_state		<=	idle_lcd;
					lcd_next_state			<= display_string;
				
				when idle_lcd => 
					lcd_en					<=	'0';
					lcd_blon					<=	'1';
					lcd_on					<=	'1';
					
					lcd_present_state 	<= lcd_next_state;
					
				when return_home =>
				   lcd_en					<='1';
					lcd_rs					<='0';
					lcd_rw_en				<='0';
					
					data_value				<= x"80";
					
					lcd_present_state		<= idle_lcd;
					lcd_next_state			<= display_string;
					
			end case;
				


				
				
		 end if;
	 end if;
  end process;
  
  
  end test;
  