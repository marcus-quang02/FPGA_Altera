library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity image_read is
  generic (
    IMAGE_SIZE     	: integer := 307199;  ---- 640*480-1
    ADDR_WIDTH     	: integer := 19;  ---- 2^20 = 1048576  
    DATA_WIDTH     	: integer := 8
  );
  
  port(
    clock: 				IN STD_LOGIC;
    data_in: 			IN std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
    rdaddress: 		IN STD_logic_vector((ADDR_WIDTH-1) downto 0);
    wraddress: 		IN STD_logic_vector((ADDR_WIDTH-1) downto 0);
    we: 					IN STD_LOGIC;
    re: 					IN STD_LOGIC;
	 
    data_out: 			OUT std_logic_vector((DATA_WIDTH-1) DOWNTO 0)
	 
	 );
	 
end image_read;


architecture behavioral of image_read is

-- Type and signal for the memory
type memory_array_t is array (0 to IMAGE_SIZE) of std_logic_vector(7 downto 0);


-- Constants
constant WIDTH      : integer := 640;
constant HEIGHT     : integer := 480;
constant HALF_W     : integer := WIDTH / 2;  -- 320
constant HALF_H     : integer := HEIGHT / 2; -- 240

-- Function to return color value based on quadrant
function get_pixel_value(x, y : integer) return std_logic_vector is
begin
    if x < HALF_W and y < HALF_H then
        return x"40"; -- Top-left: Dark Gray
    elsif x >= HALF_W and y < HALF_H then
        return x"80"; -- Top-right: Medium Gray
    elsif x < HALF_W and y >= HALF_H then
        return x"C0"; -- Bottom-left: Light Gray
    else
        return x"FF"; -- Bottom-right: White
    end if;
end function;


-- Memory initialization function
function init_memory return memory_array_t is
    variable tmp : memory_array_t;
    variable idx : integer := 0;
begin
    for y in 0 to HEIGHT - 1 loop
        for x in 0 to WIDTH - 1 loop
            tmp(idx) := get_pixel_value(x, y);
            idx := idx + 1;
        end loop;
    end loop;
    return tmp;
end function;

-- Initialize memory with pixel values

signal mem : memory_array_t := init_memory;

begin
  
  process (clock)
  begin
   if (rising_edge(clock)) then
      if (we = '1') then
        mem(to_integer(unsigned(wraddress))) <= data_in;
      end if;
      if (re = '1') then
        data_out <= mem(to_integer(unsigned(rdaddress)));
      end if;
    end if;
  end process;

end behavioral;