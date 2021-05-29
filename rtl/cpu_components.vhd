-------------------------------------------------------
--! @file   cpu_components.vhd
--! @brief Components definitions for
--!        PeRISCore32
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library periscore32;

package cpu_components is
    
    component direct_mapped_DCache is
        generic(
            address_bits : integer := 32; 
            index_width : integer := 8; 
            block_size : integer := 32; 
            byte_select : integer := 2 
        );
        port (
            clk : in std_logic;
            write_enable : in std_logic;
            address : in word;
            select_type : in operand_type;   
            signed_unsigned : in std_logic; 
            data_in : in word;
            data_out : out word
        );
    end component ;

    component direct_mapped_ICache is
        generic(
            address_bits : integer := 32; 
            index_width : integer := 8; 
            block_size : integer := 32; 
            byte_select : integer := 2 
        );
        port (
            clk : in std_logic;
            write_enable : in std_logic;
            address : in word;
            data_in : in word;
            data_out : out word
        );
    end component ;

end package ;
