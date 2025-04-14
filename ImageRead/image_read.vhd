library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity image_read is
  generic (
    ADDR_WIDTH     	: integer := 4;        
    DATA_WIDTH     	: integer := 8;
    IMAGE_SIZE  		: integer := 15;
    IMAGE_FILE_NAME 	: string :="new.hex"
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

TYPE mem_type IS ARRAY(0 TO IMAGE_SIZE) OF std_logic_vector((DATA_WIDTH-1) DOWNTO 0);

function init_mem(mif_file_name : in string) return mem_type is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
    variable temp_mem : mem_type;
begin
    for i in mem_type'range loop
        readline(mif_file, mif_line);
        read(mif_line, temp_bv);
        temp_mem(i) := to_stdlogicvector(temp_bv);
    end loop;
    return temp_mem;
end function;


signal ram_block: mem_type := (x"00",x"FF",x"00",x"FF",x"FF",x"FF",x"FF",x"00",x"FF",x"00",x"FF",x"20",x"20",x"20",x"20",x"20");

signal read_address_reg: std_logic_vector((ADDR_WIDTH-1) downto 0) := (others=>'0');

  
 
begin
  process (clock)
  begin
   if (rising_edge(clock)) then
      if (we = '1') then
        ram_block(to_integer(unsigned(wraddress))) <= data_in;
      end if;
      if (re = '1') then
        data_out <= ram_block(to_integer(unsigned(rdaddress)));
      end if;
    end if;
	 
  end process;
end behavioral;