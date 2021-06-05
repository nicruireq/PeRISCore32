-------------------------------------------------------
--! @file
--! @brief register file of cpu
-------------------------------------------------------

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
        reg_write : in std_logic;
        address_A : in std_logic_vector(address_width-1 downto 0);
        address_B : in std_logic_vector(address_width-1 downto 0);
        address_write : in std_logic_vector(address_width-1 downto 0);
        data_in   : in word;
        operand_A : out word;
        operand_B : out word
    );
end register_file;

architecture behavioral of register_file is

    type ram_file is array(0 to registers-1) 
        of std_logic_vector(register_width-1 downto 0);
    --shared variable RAM : ram_file;
    signal RAM : ram_file;

begin

    writing : process( clk )
    begin
        if rising_edge(clk) then
            if reg_write = '1' then
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
    operand_A <= data_in when address_write = address_A else
                 RAM(to_integer(unsigned(address_A)));

    operand_B <= data_in when address_write = address_B else
                 RAM(to_integer(unsigned(address_B)));

end architecture ;