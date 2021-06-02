-------------------------------------------------------
--! @file
--! @brief Direct mapped instruction cache L1 generic
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.memory_utils.all;

entity direct_mapped_ICache is
    generic(
        address_bits : integer := 32; --! width in bits of input address
        index_width : integer := 8; --! number of lines of cache index
        block_size : integer := 32; --! size of cache block
        byte_select : integer := 2 --! number of bits to select byte in each block
    );
    port (
        clk : in std_logic;
        --enable : in std_logic;
        write_enable : in std_logic;
        --read_enable : in std_logic;
        address : in word;
        data_in : in word;
        data_out : out word
        --hit_miss : out std_logic
    );
end direct_mapped_ICache ;

architecture behavioral of direct_mapped_ICache is

    --! number of cache tag bits
    constant tag_width : integer := address_bits - index_width - byte_select;
    --! Type of RAM containing the data blocks
    type data_ram is array (0 to (2**index_width)-1)
        of std_logic_vector(block_size-1 downto 0);
    --! Type of RAM containing the tag slice of 
    --! memory address to compare with input address
    type tag_ram is array (0 to (2**index_width)-1)
        of std_logic_vector(tag_width-1 downto 0);
    --! Type of RAM containing valid bit
    type validity_ram is array (0 to (2**index_width)-1)
        of std_logic;
    signal data_blocks : data_ram; -- := load initial content
    signal tags : tag_ram;
    signal valids : validity_ram;
    --! To select byte select LSB bit in address
    constant bsl : integer := 0;
    --! To select byte select MSB bit in address
    constant bsh : integer := bsl + (byte_select - 1);
    --! To select index LSB bit in address
    constant il : integer := bsh + 1;
    --! To select index MSB bit in address
    constant ih : integer := il + (index_width -1);
    --! To select tag LSB bit in address
    constant tl : integer := ih + 1;
    --! To select tag MSB bit in address
    constant th : integer := tl + (tag_width - 1);
            
begin

    rams_writing : process (clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                data_blocks(to_integer(unsigned(address(ih downto il)))) <= data_in;
                tags(to_integer(unsigned(address(ih downto il)))) <= address(th downto tl);
                valids(to_integer(unsigned(address(ih downto il)))) <= '1';
            end if;
        end if;
    end process;

    -- Synchronous reading
    blocks_reading : process (clk)
    begin
        if rising_edge(clk) then
            if (tags(to_integer(unsigned(address(ih downto il)))) = address(th downto tl)
                and valids(to_integer(unsigned(address(ih downto il)))) = '1') then
                    data_out <= data_blocks(to_integer(unsigned(address(ih downto il))));
            end if;
        end if;
    end process;

    -- Asynchronous:
    --data_out <= data_blocks(to_integer(unsigned(address(ih downto il)))) when 
    --                tags(to_integer(unsigned(address(ih downto il)))) = address(th downto tl)
    --                and valids(to_integer(unsigned(address(ih downto il)))) = '1'
    --            else (others => '0');

end architecture ; -- rtl