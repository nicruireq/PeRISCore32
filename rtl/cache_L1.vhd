-------------------------------------------------------
--! @file
--! @brief L1 cache generic
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.memory_utils.all;

entity cache_L1 is
    generic(
        address_bits : integer := 32; --! width in bits of input address
        depth_bits : integer := 8; --! number of memory rows = 2^depth_bits
        width : integer := 32 --! memory word width in bits
    );
    port (
        clk : in std_logic;
        enable : in std_logic;
        write_enable : in std_logic;
        --read_enable : in std_logic;
        address : in word;
        data_in : in word;
        data_out : out word
    );
end cache_L1 ;

architecture behavioral of cache_L1 is

    type cache_ram is array (0 to (2**depth_bits)-1) 
        of std_logic_vector(width-1 downto 0);
    signal ram : cache_ram; -- := load initial content
    signal internal_address : std_logic_vector(depth_bits-1 downto 0);
begin

    internal_address <= address(depth_bits-1 downto 0);

    single_port_read_first_enable_ram : process (clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if write_enable = '1' then
                    ram(to_integer(unsigned(internal_address))) <= data_in; 
                end if;
                data_out <= ram(to_integer(unsigned(internal_address)));
            end if;
        end if;
    end process;

    
    --data_out <= ram(to_integer(unsigned(internal_address))) when 
    --                read_enable = '1' and write_enable = '0'
    --            else (others => '0');

end architecture ; -- rtl