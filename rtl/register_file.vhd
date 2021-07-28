---------------------------------------------------------------------------------------------
--! @file register_file.vhd
--! @brief register file of cpu
--! @author Nicolas Ruiz Requejo
--! @details This register file implementation 
--!          is able to perform two readings 
--!          and one writting at the same cycle.
--!          - Address zero is fixed to constant 0x00000000.
--!          - Therefore writtings to register zero are ignored.
--!          - A forwarding scheme is included to forward the 
--!            value being writting when is reading the same
--!            address at once.
--!          - Synthesizable as distributed ram only
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

library periscore32;
use periscore32.cpu_types.all;

entity register_file is
    generic (
        registers : integer := registers_amount;
        register_width : integer := word_width;
        address_width : integer := regfile_address_width
    );
    port (
        clk : in std_logic;
        reg_write : in std_logic;   --! control signal to perform writings
        address_A : in std_logic_vector(address_width-1 downto 0);  --! selects first operand to read
        address_B : in std_logic_vector(address_width-1 downto 0);  --! selects second operand to read
        address_write : in std_logic_vector(address_width-1 downto 0);  --! selects register to be written
        data_in   : in word;    --! data to be written
        operand_A : out word;   --! first reading operand
        operand_B : out word    --! second reading operand
    );
end register_file;

architecture behavioral of register_file is

    type ram_file is array(0 to registers-1) 
        of std_logic_vector(register_width-1 downto 0);
    --shared variable RAM : ram_file;
    signal RAM : ram_file := (others=>(others=>'0'));
begin

    writing : process( clk )
    begin
        if rising_edge(clk) then
            -- register $0 always yields 0
            if reg_write = '1' and unsigned(address_write) /= 0 then
                RAM(to_integer(unsigned(address_write))) <= data_in;
            --else
              --  operand_A <= RAM(to_integer(unsigned(address_A)));
                --operand_B <= RAM(to_integer(unsigned(address_B)));
            end if;
        end if;
    end process ;

    --reading : process( clk )
    --begin
    --    if falling_edge(clk) then
    --        operand_A <= RAM(to_integer(unsigned(address_A)));
    --        operand_B <= RAM(to_integer(unsigned(address_B)));
    --    end if;
    --end process ;

    -- reading "read-first"
    operand_A <= data_in when address_write = address_A and reg_write = '1' 
                    else RAM(to_integer(unsigned(address_A)));

    operand_B <= data_in when address_write = address_B and reg_write = '1'
                    else RAM(to_integer(unsigned(address_B)));

end architecture ;