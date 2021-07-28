---------------------------------------------------------------------------------------------
--! @file   direct_mapped_DCache.vhd
--! @brief Direct mapped data cache L1 generic
--! @author Nicolas Ruiz Requejo
--! @details    By default provide 256 cache lines.
--!             Structure of cache lines:
--!             (valid bit, tag slice of address 22 bits, data block 32 bits).
--!             Due to the logic needed this cache is only synthetizable as 
--!             distributed ram.
--!             + This implementation is ready to accept writings of:
--!                 - Bytes: in addresses multiple of 1
--!                 - Halfwords: in addresses multiple of 2
--!                 - words: in addresses multiple of 4
--!             + This implementation is ready to make readings of:
--!                 - Bytes: signed/unsigned
--!                 - Halfwords: signed/unsigned
--!                 - Words
--!
--! @Copyright  SPDX-FileCopyrightText: 2020 Nicolas Ruiz Requejo nicolas.r.requejo@gmail.com
--!             SPDX-License-Identifier: CERN-OHL-S-2.0+
--!
--!             This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
--!             INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
--!             PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.
--!
--!             Source location: https://github.com/nicruireq/PeRISCore32
--!
--!             As per CERN-OHL-S v2 section 4, should You produce hardware based on this
--!             source, You must where practicable maintain the Source Location visible
--!             on the external case and documentation of the PeRISCore32 or other products 
--!             you make using this source.
--!
---------------------------------------------------------------------------------------------

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

entity direct_mapped_DCache is
    generic(
        address_bits : integer := 32; --! width in bits of input address
        index_width : integer := 8; --! number of lines of cache index
        block_size : integer := 32; --! size of cache block
        byte_select : integer := 2; --! number of bits to select byte in each block
        data_image : string := "./images/e1_data.dat" --! path to file with initial content
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
end direct_mapped_DCache ;

architecture behavioral of direct_mapped_DCache is

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

    --! Function to load DCache initial data content
    impure function load_dcache_data(file_name : in string)
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
    impure function load_dcache_tags(file_name : in string)
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
    impure function load_dcache_valids(file_name : in string)
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

    --! RAM of data blocks to hold mem data
    signal data_blocks : data_ram := load_dcache_data(data_image); --(others=>(others=>'0'));
    --! RAM of tags slice of address
    signal tags : tag_ram := (others=>(others=>'0'));
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

    data_line <= data_blocks(to_integer(unsigned(address(ih downto il))));

    -- Select correct byte to output
    data_byte <= data_line(31 downto 24) when address(bsh downto bsl) = "11"
                    and select_type = OP_BYTE else
                 data_line(23 downto 16) when address(bsh downto bsl) = "10"
                    and select_type = OP_BYTE else
                 data_line(15 downto 8) when address(bsh downto bsl) = "01"
                    and select_type = OP_BYTE else
                 data_line(7 downto 0) when address(bsh downto bsl) = "00"
                    and select_type = OP_BYTE else
                 (others => '0');

    -- Select correct halfword to output
    data_half <= data_line(31 downto 16) when address(bsh downto bsl) = "10"
                    and select_type = OP_HALF else
                 data_line(15 downto 0) when address(bsh downto bsl) = "00"
                    and select_type = OP_HALF else
                 (others => '0');

    data_word <= data_line when select_type = OP_WORD 
                    --and address(bsh downto bsl) = "00"
                 else (others => '0');

    -- Select output data source and sign or zero extend
    data_preout <= data_word 
                        when select_type = OP_WORD else
                   std_logic_vector(resize(signed(data_byte), data_preout'length)) 
                        when select_type = OP_BYTE and signed_unsigned = '0' else
                   x"000000"&data_byte 
                        when select_type = OP_BYTE  and signed_unsigned = '1' else
                   std_logic_vector(resize(signed(data_half), data_preout'length))
                        when select_type = OP_HALF and signed_unsigned = '0' else
                   x"0000"&data_half 
                        when select_type = OP_HALF and signed_unsigned = '1' else
                   (others => '0');

    -- Select final data output according to validity
    data_out <= data_preout when
                    read_enable = '1' and
                    tags(to_integer(unsigned(address(ih downto il)))) = address(th downto tl)
                    and valids(to_integer(unsigned(address(ih downto il)))) = '1'
                else (others => '0');

end architecture ; -- rtl
