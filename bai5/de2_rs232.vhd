library IEEE;
use IEEE.std_logic_1164.all;

entity de2_rs232 is
 -- generic (data_byte: integer:=8);
  port(
       clk_50: in std_logic;
		 rst: in std_logic;
		 --LED
		 led:out std_logic_vector (7 downto 0);
		 
		 --RS232
		 rs232_tx: out std_logic;
		 rs232_rx: in std_logic;
		 
		 lcd_rs: out std_logic;
		 lcd_en: out std_logic;
		 lcd_rw: out std_logic;
		 lcd_on: out std_logic;
		 lcd_blon: out std_logic;
		 lcd_data: inout std_logic_vector(7 downto 0)
		
       );
end de2_rs232;





architecture test of de2_rs232 is
  type lcd_state is (clear_display,return_home,display_on,display_off,function_set,mode_set,
                     display_string,idle_lcd,reset,line2_mode);
							
							
  type character_string is array (0 to 31) of std_logic_vector(7 downto 0);


  
  type state_rs232 is (rs232_start,rs232_data,rs232_stop,rs232_idle);
  
  signal rs232_present_state:state_rs232:= rs232_idle;
  signal rs232_next_state:state_rs232:=rs232_start;
  
  signal rs232_dataRx: std_logic_vector(7 downto 0):=(others =>'0');
  
    signal rs232_string: character_string:=(
 -- Line 1         
          x"48",x"45",x"4C",x"4C",x"4F",x"20",x"57",x"4F",x"52",x"4C",x"44",x"20",x"20",x"20",x"20",x"20",
-- Line 2                       
          x"48",x"45",x"4C",x"4C",x"4F",x"20",x"57",x"4F",x"52",x"4C",x"44",x"20",x"20",x"20",x"20",x"20"
   );
  

  signal rs232_bit_count: integer range 0 to 8:=0;
  constant  BAUD_RATE:integer:= 115200;
  constant  XTAL_FREQ:integer:= 50000000;
  constant  MAX_COUNT_RATE_232: integer:=(50000000/BAUD_RATE)*2;
  constant  ONE_COUNT_RATE_232: integer:=(50000000/BAUD_RATE);
  constant  HALF_COUNT_RATE_232: integer:=(50000000/BAUD_RATE)/2;
  
  signal rs232_count_rate: natural range 0 to MAX_COUNT_RATE_232;
  signal rs232_enable:std_logic:='0';
  signal rs232_dataRx_delay: std_logic:='0';
  
  -- LCD VARIABLES
  signal lcd_string: character_string;

  signal lcd_present_state,lcd_next_state:lcd_state;
  signal lcd_rw_en: std_logic;
  signal data_value,char: std_logic_vector(7 downto 0);
  signal char_cnt: integer:=0;
  signal clk_400Hz_enable: std_logic;
  signal clk_400Hz_cnt: integer:=0;
  
  begin
  -- CLOCK PROCESS
  
  lcd_string<=rs232_string;
  
  lcd_data<=data_value;
  char<=lcd_string(char_cnt);
  lcd_rw<=lcd_rw_en;
  
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
  
  --RS232 RECEIVE PROCESS
 rs232_enable <= rs232_dataRx_delay and (not rs232_rx);
 
  process(clk_50)
  variable counter:		integer range 0 to 16:=0;
  variable data_index: 	integer range 0 to 31:=0;
  begin
  
    if(rst='0') then
	     rs232_present_state		<=rs232_idle;
		  rs232_next_state			<=rs232_start;
		  rs232_count_rate			<= 0 ;
		  rs232_bit_count			<= 0 ;
		  rs232_dataRx_delay		<='0';
		  counter  					:= 0 ;
		   
	elsif rising_edge(clk_50) then
	     led				<=	rs232_dataRx;
	     rs232_dataRx_delay <= 	rs232_rx;
		  
	     case rs232_present_state is
		  
				when rs232_start =>
					if(rs232_enable='1') then
					
						rs232_bit_count 		<= 0;
						rs232_count_rate 		<= (ONE_COUNT_RATE_232 + HALF_COUNT_RATE_232)-1;
						rs232_present_state 	<= rs232_idle;
						rs232_next_state 		<= rs232_data;
						  
					end if;
					  
				when rs232_data =>
				
				    if(rs232_bit_count<7) then
							rs232_bit_count  <= rs232_bit_count+1;
							rs232_next_state <= rs232_data;
							rs232_count_rate <= ONE_COUNT_RATE_232-1;
					else 
							rs232_next_state <= rs232_stop;
							rs232_count_rate <= HALF_COUNT_RATE_232-1;
					end if;
					
					rs232_present_state<=rs232_idle;
					
					if(rs232_rx='1') then
						   rs232_dataRx(rs232_bit_count)<='1';
						else
						   rs232_dataRx(rs232_bit_count)<='0';
					end if;
						
				when rs232_stop =>
				
						rs232_count_rate<=0;
						rs232_present_state <= rs232_idle;
						rs232_next_state <= rs232_start;
						
						if(rs232_count_rate>0) then
						   rs232_count_rate <= rs232_count_rate-1;
						end if;
						
						if(counter<31) then
						   rs232_string(counter) <= rs232_dataRx;
							counter := counter+1;
						else
						
						   counter := 0;
						for data_index in 1 to 31 loop
							rs232_string(data_index) <= x"20";
						end loop;
						
							rs232_string(0) <= (rs232_dataRx);
						end if;
						
				when rs232_idle =>	
					if(rs232_count_rate=0) then
					    rs232_present_state			<=rs232_next_state;
					elsif(rs232_count_rate>0) then
					    rs232_count_rate			<=rs232_count_rate-1;
					end if;
		  end case;
	  end if;
  end process;
  
  
  -- LCD PROCESS
  process(clk_50)
  begin
  
    if(rst='0') then
	    lcd_present_state<=reset;
		 lcd_next_state<=reset;
		 data_value<=x"38";
		 lcd_en<='1';
		 lcd_rs<='0';
		 lcd_rw_en<='0';
		 
	 elsif rising_edge(clk_50) then
	    if(clk_400Hz_enable='1') then
		 --lcd_on<='1';
		 case lcd_present_state is
		     when reset =>
			      lcd_en<='1';
					lcd_rs<='0';
					lcd_rw_en<='0';
					data_value<=x"38";
					lcd_present_state<=idle_lcd;
					lcd_next_state<=function_set;
					char_cnt<=0;
			  when function_set =>
			      lcd_en<='1';
					lcd_rs<='0';
					lcd_rw_en<='0';
					
					data_value<=x"38";
					lcd_present_state<=idle_lcd;
					lcd_next_state<=display_off;
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
				   lcd_en<='1';
					lcd_rs<='0';
					lcd_rw_en<='0';
					
					data_value<=x"06";
					lcd_present_state<=idle_lcd;
					lcd_next_state<=display_string;
				when display_string =>
				   lcd_en<='1';
					lcd_rs<='1';
					lcd_rw_en<='0';
					
					data_value<=char;
					lcd_present_state<=idle_lcd;
					if char_cnt < 31 then
					  char_cnt<=char_cnt+1;
					else
					  char_cnt<=0;
					end if;
					
					if char_cnt=15 then
					   lcd_next_state<= line2_mode;
					elsif char_cnt = 31 then
					   lcd_next_state<=return_home;
					else
					   lcd_next_state<=display_string;
					end if;
				when line2_mode =>
				   lcd_en<='1';
					lcd_rs<='0';
					lcd_rw_en<='0';
					
					data_value<=x"C0";
					lcd_present_state<=idle_lcd;
					lcd_next_state<= display_string;
				when return_home =>
				   lcd_en<='1';
					lcd_rs<='0';
					lcd_rw_en<='0';
					
					data_value<= x"80";
					lcd_present_state<=idle_lcd;
					lcd_next_state<= display_string;
               when idle_lcd =>
					lcd_en<='0';
					lcd_blon<='1';
					lcd_on<='1';
					lcd_present_state<=lcd_next_state;
            end case;
		 end if;
	 end if;
  end process;
  
  
end test;


