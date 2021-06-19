-------------------------------------------------------
--! @file
--! @brief Direct mapped instruction cache L1 generic
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Provides the types "string", "text" and "line"
use STD.TEXTIO.ALL;
--! Allows "std_logic" can be used as a type in the text file
--! It is a not standard package and is deprecated.
use IEEE.STD_LOGIC_TEXTIO.ALL;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.memory_utils.all;

entity direct_mapped_ICache is
    generic(
        address_bits : integer := 32; --! width in bits of input address
        index_width : integer := 8; --! number of lines of cache index
        block_size : integer := 32; --! size of cache block
        byte_select : integer := 2; --! number of bits to select byte in each block
        data_image : string := "./images/icache_img1.dat"; --! path to file with initial content
        tags_image : string := "./images/icache_img1_tags.dat"   --! path to file with tags content
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
    
    --! Function to load ICache instructions content
    impure function load_icache_data(file_name : in string)
        return data_ram is
            file fdata : text open read_mode is file_name;
            variable mline : line;
            variable temp_mem: data_ram;
    begin
        for i in data_ram'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

        return temp_mem;
    end function;

    --! Function to load ICache tags
    impure function load_icache_tags(file_name : in string)
        return tag_ram is
            file fdata : text open read_mode is file_name;
            variable mline : line;
            variable temp_mem: tag_ram;
    begin
        for i in tag_ram'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

        return temp_mem;
    end function;

    --! Function to load ICache validity bits
    impure function load_icache_valids(file_name : in string)
        return validity_ram is
            file fdata : text open read_mode is file_name;
            variable mline : line;
            variable temp_mem: validity_ram;
    begin
        for i in validity_ram'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

        return temp_mem;
    end function;


    --! RAM of data blocks to hold instructions
    signal data_blocks : data_ram := load_icache_data(data_image);
    --! RAM of tags slice of address
    signal tags : tag_ram := load_icache_tags(tags_image); --(others=>(others=>'0'));
    --! RAM of validity bits
    signal valids : validity_ram := (others=>('1'));

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
    --blocks_reading : process (clk)
    --begin
    --    if rising_edge(clk) then
    --        if (tags(to_integer(unsigned(address(ih downto il)))) = address(th downto tl)
    --            and valids(to_integer(unsigned(address(ih downto il)))) = '1') then
    --                data_out <= data_blocks(to_integer(unsigned(address(ih downto il))));
    --        end if;
    --    end if;
    --end process;

    -- Asynchronous:
    data_out <= data_blocks(to_integer(unsigned(address(ih downto il)))) when 
                    tags(to_integer(unsigned(address(ih downto il)))) = address(th downto tl)
                    and valids(to_integer(unsigned(address(ih downto il)))) = '1'
                else (others => '0');

end architecture ; -- rtl