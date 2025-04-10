library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Button_Counter is
    Port (
        clk     : in std_logic;        -- Clock input
        button  : in std_logic;        -- Debounced button input
        seg1    : out std_logic_vector(6 downto 0); -- 7-segment display (ones place)
        seg2    : out std_logic_vector(6 downto 0)  -- 7-segment display (tens place)
    );
end Button_Counter;

architecture Behavioral of Button_Counter is
    signal count : integer range 0 to 99 := 0;  -- Counter (0 to 99)
    signal last_button : std_logic := '0';      -- To detect button press edge

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

begin
    process (clk)
    begin
        -- if rising_edge(clk) then
        --     -- Detect button press (rising edge)
        --     if button = '1' and last_button = '0' then
        --         if count < 99 then
        --             count <= count + 1; -- Increment count (up to 99)
        --         else
        --             count <= 0; -- Reset count when it exceeds 99
        --         end if;
        --     end if;

        --     last_button <= button; -- Update last button state
        -- end if;


        if rising_edge(clk) then

            if button = '1' and last_button = '0' then
                if count < 99 then 
                    count <= count + 1;
                else
                    count <= 0;
                end if;
            end if ;
				last_button <= button;
        end if;

    end process;

    -- Split count into tens and ones digits
    seg1 <= SevenSegDecoder(count mod 10); -- Ones place
    seg2 <= SevenSegDecoder(count / 10);  -- Tens place
	 
end Behavioral;
