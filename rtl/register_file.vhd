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
    );
    port (
        clk : in std_logic;

    );
end register_file;

architecture behavioral of register_file is

    type ram_file is array(0 to registers-1) 
        of std_logic_vector(register_width-1 downto 0);
    shared variable RAM : ram_file;

begin

    ram_dual_port : process( clk )
    begin
        
    end process ; -- ram_dual_port

end architecture ; -- arch