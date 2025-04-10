library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port (
        clk          : in  std_logic;                     -- Clock input
        reset        : in  std_logic;                     -- Reset signal
        speed_factor : in  integer := 1;                  -- Speed multiplier (default = 1)
        seg0         : out std_logic_vector(6 downto 0);  -- 7-segment for seconds (ones place)
        seg1         : out std_logic_vector(6 downto 0);  -- 7-segment for seconds (tens place)
        seg2         : out std_logic_vector(6 downto 0);  -- 7-segment for minutes (ones place)
        seg3         : out std_logic_vector(6 downto 0);  -- 7-segment for minutes (tens place)
        seg4         : out std_logic_vector(6 downto 0);  -- 7-segment for hours (ones place)
        seg5         : out std_logic_vector(6 downto 0)   -- 7-segment for hours (tens place)
    );
end timer;

architecture Behavioral of timer is

    -- Clock divider signals
    constant CLOCK_FREQ : integer := 50000000; -- Input clock frequency in Hz (50 MHz)
    signal tick_counter : integer range 0 to CLOCK_FREQ - 1 := 0;
    signal tick         : std_logic := '0';

    -- Timer signals
    signal sec_counter  : integer range 0 to 59 := 0;
    signal min_counter  : integer range 0 to 59 := 0;
    signal hour_counter : integer range 0 to 23 := 0;

    -- Intermediate signals for 7-segment decoder
    signal sec_ones     : integer range 0 to 9 := 0;
    signal sec_tens     : integer range 0 to 5 := 0;
    signal min_ones     : integer range 0 to 9 := 0;
    signal min_tens     : integer range 0 to 5 := 0;
    signal hour_ones    : integer range 0 to 9 := 0;
    signal hour_tens    : integer range 0 to 2 := 0;

    -- 7-segment decoder function
    function SevenSegDecoder(digit : integer) return std_logic_vector is
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
    -- Clock Divider: Generates 1 Hz tick with configurable speed
    process (clk, reset)
    begin
        if reset = '1' then
            tick_counter <= 0;
            tick <= '0';
        elsif rising_edge(clk) then
            if tick_counter < (CLOCK_FREQ / speed_factor) - 1 then
                tick_counter <= tick_counter + 1;
                tick <= '0';
            else
                tick_counter <= 0;
                tick <= '1'; -- 1 Hz tick
            end if;
        end if;
    end process;

    -- Timer Logic
    process (clk, reset)
    begin
        if reset = '1' then
            sec_counter <= 0;
            min_counter <= 0;
            hour_counter <= 0;
        elsif rising_edge(clk) then
            if tick = '1' then
                -- Increment seconds
                if sec_counter < 59 then
                    sec_counter <= sec_counter + 1;
                else
                    sec_counter <= 0;
                    -- Increment minutes
                    if min_counter < 59 then
                        min_counter <= min_counter + 1;
                    else
                        min_counter <= 0;
                        -- Increment hours
                        if hour_counter < 23 then
                            hour_counter <= hour_counter + 1;
                        else
                            hour_counter <= 0; -- Reset hours after 24 hours
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Extract individual digits for hours, minutes, and seconds
    process (sec_counter, min_counter, hour_counter)
    begin
        sec_ones  <= sec_counter mod 10; -- Ones place of seconds
        sec_tens  <= sec_counter / 10;  -- Tens place of seconds
        min_ones  <= min_counter mod 10; -- Ones place of minutes
        min_tens  <= min_counter / 10;  -- Tens place of minutes
        hour_ones <= hour_counter mod 10; -- Ones place of hours
        hour_tens <= hour_counter / 10;  -- Tens place of hours
    end process;

    -- 7-Segment Display Outputs
    seg0 <= SevenSegDecoder(sec_ones);  -- Seconds (ones place)
    seg1 <= SevenSegDecoder(sec_tens);  -- Seconds (tens place)
    seg2 <= SevenSegDecoder(min_ones);  -- Minutes (ones place)
    seg3 <= SevenSegDecoder(min_tens);  -- Minutes (tens place)
    seg4 <= SevenSegDecoder(hour_ones); -- Hours (ones place)
    seg5 <= SevenSegDecoder(hour_tens); -- Hours (tens place)

end Behavioral;
