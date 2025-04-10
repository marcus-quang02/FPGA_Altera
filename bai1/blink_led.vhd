library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity blink_led is
    port (
        clk : in std_logic;
        led : out std_logic_vector ( 3 downto 0) := "0000";
        led1 : out std_logic_vector ( 3 downto 0) := "0000"
    );

end blink_led;

	

architecture arch1 of blink_led is

signal cnt: integer range 0 to 25000000;
signal cnt1 : integer range 0 to 50000000;

signal pulse: std_logic_vector (3 downto 0) := "0000";
signal pulse1: std_logic_vector (3 downto 0) := "0000";



begin

	process (clk) begin 
        if rising_edge(clk) then 
            cnt <= cnt + 1;
            cnt1 <= cnt1 + 1;

            if(cnt = 25000000) then 
                pulse <=  not  pulse;
                cnt <= 0;
            end if;
				
			if (cnt1 = 50000000) then
                pulse1 <=  not pulse1 ;
                cnt1 <= 0;
            end if;
                

					
        end if;
	
	end process;
	
	led <= pulse;
    led1 <= pulse1;
	
end arch1;