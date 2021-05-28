-------------------------------------------------------
--! @file   cpu_components.vhd
--! @brief Components definitions for
--!        PeRISCore32
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library periscore32;

package cpu_components is
    
    component cache_L1 is
        generic(
            address_bits : integer := 32; --! width in bits of input address
            depth_bits : integer := 8; --! number of memory rows = 2^depth_bits
            width : integer := 32 --! memory word width in bits
        );
        port (
            clk : in std_logic;
            enable : in std_logic;
            write_enable : in std_logic;
            --read_enable : in std_logic;
            address : in word;
            data_in : in word;
            data_out : out word
        );
    end component ;

end package ;