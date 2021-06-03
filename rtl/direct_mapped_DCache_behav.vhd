-------------------------------------------------------
--! @file
--! @brief Direct mapped data cache L1 generic
-------------------------------------------------------


-- FAILED THIS DESIGN INFERS LATCHES
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.memory_utils.all;

entity direct_mapped_DCache_behav is
    generic(
        address_bits : integer := 32; --! width in bits of input address
        index_width : integer := 8; --! number of lines of cache index
        block_size : integer := 32; --! size of cache block
        byte_select : integer := 2 --! number of bits to select byte in each block
    );
    port (
        clk : in std_logic;
        write_enable : in std_logic;
        read_enable : in std_logic;
        address : in word;
        select_type : in operand_type;   --! Allows load/store of byte, halfword and word
        signed_unsigned : in std_logic; --! Allows to select for signed or unsigned byte/half
        data_in : in word;
        data_out : out word
        --hit_miss : out std_logic
    );
end direct_mapped_DCache_behav ;

architecture behavioral of direct_mapped_DCache_behav is

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
    -- index that belongs to the input address
    --shared variable current : integer 
    --        := to_integer(unsigned(address(ih downto il)));

    --===================================
    -- Intermediate signals for outputs
    --===================================
    signal data_line : std_logic_vector(block_size-1 downto 0);
    signal data_word : word;
    signal data_half : halfword;
    signal data_byte : byte;
    signal data_preout : std_logic_vector(block_size-1 downto 0);
    --signal data_source : std_logic_vector(block_size-1 downto 0);

begin

    rams_writing : process (clk)
    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                tags(to_integer(unsigned(address(ih downto il)))) <= address(th downto tl);
                valids(to_integer(unsigned(address(ih downto il)))) <= '1';
                case( select_type ) is
                    when OP_WORD =>
                        data_blocks(to_integer(unsigned(address(ih downto il)))) <= data_in;
                    when OP_HALF =>
                        case( address(bsh downto bsl) ) is
                            when "10" =>
                                data_blocks(to_integer(unsigned(address(ih downto il))))(31 downto 16)
                                    <= data_in(half_width-1 downto 0);
                            when "00" =>
                                data_blocks(to_integer(unsigned(address(ih downto il))))(15 downto 0)
                                    <= data_in(half_width-1 downto 0);
                            when others =>
                                null;
                        end case ;
                    when OP_BYTE =>
                        case( address(bsh downto bsl) ) is
                            when "11" =>
                                data_blocks(to_integer(unsigned(address(ih downto il))))(31 downto 24)
                                    <= data_in(byte_width-1 downto 0);
                            when "10" =>
                                data_blocks(to_integer(unsigned(address(ih downto il))))(23 downto 16)
                                    <= data_in(byte_width-1 downto 0);
                            when "01" =>
                                data_blocks(to_integer(unsigned(address(ih downto il))))(15 downto 8)
                                    <= data_in(byte_width-1 downto 0);
                            when "00" =>
                                data_blocks(to_integer(unsigned(address(ih downto il))))(7 downto 0)
                                    <= data_in(byte_width-1 downto 0);
                            when others =>
                                null;
                        end case ;
                    when others =>
                        null;
                        -- raise exception
                end case ;
            end if;
        end if;
    end process;

    read_accurate_address_datatype : process (read_enable, address, tags, valids,
                                              select_type, signed_unsigned)
        variable data_line : std_logic_vector(block_size-1 downto 0);
        variable data_word : word;
        variable data_half : halfword;
        variable data_byte : byte;
        variable data_preout : std_logic_vector(block_size-1 downto 0);
    begin
        if read_enable = '1' then
            data_line := data_blocks(to_integer(unsigned(address(ih downto il))));
            case( select_type ) is
                when OP_BYTE =>
                    case( address(bsh downto bsl) ) is
                        when "11" =>
                        -- OTRO CASE EN CADA UNO PARA SIGNED/UNISIGNED U OTRO PROCESS??
                            data_byte := data_line(31 downto 24);
                        when "10" => 
                            data_byte := data_line(23 downto 16);
                        when "01" => 
                            data_byte := data_line(15 downto 8);
                        when "00" => 
                            data_byte := data_line(7 downto 0);
                        when others =>
                            data_byte := (others => '0');
                    end case ;
                when OP_HALF =>
                    case( address(bsh downto bsl) ) is
                        when "10" => 
                            data_half := data_line(31 downto 16);
                        when "00" => 
                            data_half := data_line(15 downto 0);
                        when others =>
                            data_half := (others => '0');
                    end case ;
                when OP_WORD =>
                    data_word := data_line;
                when others =>
                    -- to avoid inferred latches
                    data_byte := (others => '0');
                    data_half := (others => '0');
                    data_word := (others => '0');
            end case ;

            case( select_type ) is
                when OP_BYTE =>
                    case( signed_unsigned ) is
                        when '0' =>
                            data_preout := std_logic_vector(resize(signed(data_byte), data_out'length));
                        when '1' =>
                            data_preout := x"000000"&data_byte;
                        when others =>
                            data_preout := (others => '0');
                    end case ;
                when OP_HALF =>
                    case( signed_unsigned ) is
                        when '0' =>
                            data_preout := std_logic_vector(resize(signed(data_half), data_out'length));
                        when '1' =>
                            data_preout := x"0000"&data_half;
                        when others =>
                            data_preout := (others => '0');
                    end case ;
                when OP_WORD =>
                    data_preout := data_word;
                when others =>
                    data_preout := (others => '0');
            end case ;

            if tags(to_integer(unsigned(address(ih downto il)))) = address(th downto tl)
                    and valids(to_integer(unsigned(address(ih downto il)))) = '1' 
            then
                data_out <= data_preout;
            else
                data_out <= (others => '0');
            end if;

        end if;

    end process;

end architecture ;
