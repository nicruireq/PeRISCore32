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

entity direct_mapped_ICache_compact is
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
end direct_mapped_ICache_compact ;

architecture behavioral of direct_mapped_ICache_compact is

    --! number of cache tag bits
    constant tag_width : integer := address_bits - index_width - byte_select;
    --! Total number of bits for each cache line
    -- 1 for de valid field
    constant cache_line_width : integer := 1 + tag_width + block_size;

    type ICache_ram is array (0 to (2**index_width)-1)
        of std_logic_vector(cache_line_width-1 downto 0);
    
    signal cache : ICache_ram; -- := load initial content

    --========================================
    -- constants to select fields from address
    --========================================
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
    -- index that belongs to the input address
    shared variable current : integer 
            := to_integer(unsigned(address(ih downto il)));
    
    --===========================================
    -- constants to select fields from cache line
    --===========================================
    --! To select data field LSB bit in cache line
    constant dl : integer := 0; 
    --! To select data field MSB bit in cache line
    constant dh : integer := block_size - 1;
    --! To select tag field LSB bit in cache line
    constant tll : integer := dh + 1;
    --! To select tag field MSB bit in cache line
    constant tlh : integer := tll + (tag_width - 1);
    --! To select valid field LSB bit in cache line
    constant vl  : integer := tlh + 1;
    --! To select data field MSB bit in cache line
    constant vh : integer := vl;

begin

    rams_writing : process (clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                cache(current)(vh downto vl) <= "1";
                cache(current)(tlh downto tll) <= address(th downto tl);
                cache(current)(dh downto dl) <= data_in;
            end if;
        end if;
    end process;

    
    data_out <= cache(current)(dh downto dl) when 
                    cache(current)(tlh downto tll) = address(th downto tl)
                    and cache(current)(vh downto vl) = "1"
                else (others => '0');

end architecture ; -- rtl