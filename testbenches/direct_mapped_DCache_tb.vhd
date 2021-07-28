---------------------------------------------------------------------------------------------
--! @file   direct_mapped_DCache_tb.vhd
--! @author Nicolas Ruiz Requejo
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

-- VHDL Testbench Template 
-- Autogenerated from nicruireq::hdltools app 
-- Written by Nicolas Ruiz Requejo
-- 
-- Notice:
-- Fill this template with your test code
-- Please if you discover a bug submit an Issue in
-- https://github.com/nicruireq/XilinxTclStore
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.testbench_helpers.all;

ENTITY direct_mapped_DCache_tb IS
END direct_mapped_DCache_tb;

ARCHITECTURE behavior OF direct_mapped_DCache_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
    component direct_mapped_DCache is
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
        );
    end component ;

	-- Inputs and Outputs
	signal clk : std_logic;
	signal write_enable : std_logic;
    signal read_enable : std_logic;
	signal address : word;
    signal select_type : operand_type;
    signal signed_unsigned : std_logic;
	signal data_in : word;
	signal data_out : word;

    constant clock_period: time := 10 ns;
    signal stop_the_clock: boolean;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	-- UUT:
	my_direct_mapped_dcache : direct_mapped_DCache
	port map(
		clk => clk ,
		write_enable => write_enable ,
		read_enable => read_enable ,
		address => address ,
        select_type => select_type,
        signed_unsigned => signed_unsigned,
		data_in => data_in ,
		data_out => data_out );

    clocking: process
    begin
        while not stop_the_clock loop
            clk <= '0', '1' after clock_period / 2;
            wait for clock_period;
        end loop;
        wait;
    end process;

   -- Stimulus process
   stim_proc: process
        variable addr_mod1 :
            unsigned(address'length-1 downto 0) := x"00000000";
        variable addr_mod2 :
            unsigned(address'length-1 downto 0) := x"00000008";
        variable addr_mod4 : 
            unsigned(address'length-1 downto 0) := x"00000010";
   begin

        -- Put initialisation code here
        wait for 20 ns;
	    -- Put test bench stimulus code here

        --=================
        -- TEST WRITING
        --=================

        -- write 2 blocks with bytes
        write_enable <= '1';
        read_enable <= '0';
        select_type <= OP_BYTE;

        data_in <= x"000000" & rand_slv(byte_width);
        address <= std_logic_vector(addr_mod1);
        while addr_mod1 <= 7 loop
            wait for 10 ns;
            addr_mod1 := addr_mod1 + 1;
            address <= std_logic_vector(addr_mod1);
            data_in <= x"000000" & rand_slv(byte_width);
        end loop ;
        
        -- write 2 blocks with halfs
        write_enable <= '1';
        read_enable <= '0';
        select_type <= OP_HALF;

        data_in <= x"0000" & rand_slv(half_width);
        address <= std_logic_vector(addr_mod2);
        while addr_mod2 <= 15 loop
            wait for 10 ns;
            addr_mod2 := addr_mod2 + 2;
            address <= std_logic_vector(addr_mod2);
            if addr_mod2 = 12 then
                data_in <= x"0000" & "1000101101001101";    -- -29875
            else
                data_in <= x"0000" & rand_slv(half_width);
            end if;
        end loop ;
        
        -- write 2 blocks with words
        write_enable <= '1';
        read_enable <= '0';
        select_type <= OP_WORD;

        data_in <= rand_slv(word_width);
        address <= std_logic_vector(addr_mod4);
        while addr_mod4 <= 23 loop
            wait for 10 ns;
            addr_mod4 := addr_mod4 + 4;
            address <= std_logic_vector(addr_mod4);
            data_in <= rand_slv(word_width);
        end loop ;
        
        write_enable <= '0';
        wait for 10 ns;

        --=================
        -- TEST READING
        --=================
        
        addr_mod1 := x"00000000";
        addr_mod2 := x"00000008";
        addr_mod4 := x"00000010";

        -- read block 1 as unigned bytes
        read_enable <= '1';
        select_type <= OP_BYTE;

        signed_unsigned <= '1';
        address <= std_logic_vector(addr_mod1);
        while addr_mod1 <= 3 loop
            wait for 10 ns;
            addr_mod1 := addr_mod1 + 1;
            address <= std_logic_vector(addr_mod1);
        end loop ;

        -- read block 2 as signed bytes
        signed_unsigned <= '0';
        address <= std_logic_vector(addr_mod1);
        while addr_mod1 <= 7 loop
            wait for 10 ns;
            addr_mod1 := addr_mod1 + 1;
            address <= std_logic_vector(addr_mod1);
        end loop ;

        -- read block 3 as unsigned halfs
        select_type <= OP_HALF;
        signed_unsigned <= '1';
        address <= std_logic_vector(addr_mod2);
        while addr_mod2 <= 11 loop
            wait for 10 ns;
            addr_mod2 := addr_mod2 + 2;
            address <= std_logic_vector(addr_mod2);
        end loop ;

        -- read block 4 as signed halfs
        signed_unsigned <= '0';
        address <= std_logic_vector(addr_mod2);
        while addr_mod2 <= 15 loop
            wait for 10 ns;
            addr_mod2 := addr_mod2 + 2;
            address <= std_logic_vector(addr_mod2);
        end loop ;

        -- read blocks 5,6 as word
        select_type <= OP_WORD;
        address <= std_logic_vector(addr_mod4);
        while addr_mod4 <= 23 loop
            wait for 10 ns;
            addr_mod4 := addr_mod4 + 4;
            address <= std_logic_vector(addr_mod4);
        end loop ;
        
        wait for 10 ns;
        read_enable <= '0';

        wait;
   end process;

END;
