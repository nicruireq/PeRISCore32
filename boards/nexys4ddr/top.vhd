----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.07.2021 23:58:50
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library periscore32;
use periscore32.cpu_components.all;
use periscore32.cpu_types.word;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
        port (
            clk : in std_logic;
            reset : in std_logic;
            --stop_start : in std_logic;
            --dcache_address : in word;
            dcache_out : out std_logic_vector(15 downto 0)
        ) ;
end top;

architecture Behavioral of top is
    COMPONENT vio_0
      PORT (
        clk : IN STD_LOGIC;
        probe_in0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;
    
    signal dbg_stop_start : std_logic;
    signal dbg_dcache_address : word;
    signal dbg_dcache_out : word;
begin

    vio_debugger : vio_0
      PORT MAP (
        clk => clk,
        probe_in0 => dbg_dcache_out,
        probe_out0(0) => dbg_stop_start,
        probe_out1 => dbg_dcache_address
      );
      
      dbg_pipeline: pipelined_datapath
      generic map (
            icache_instructions => "./images/bubble_sort.dat",
            icache_tags => "./images/e1_tags.dat",
            dcache_data => "./images/e1_data.dat"
      )
      port map (
            clk => clk,
            reset => reset,
            stop_start => dbg_stop_start,
            dcache_address => dbg_dcache_address,
            dcache_out => dbg_dcache_out
      );
      
      dcache_out <= dbg_dcache_out(15 downto 0);

end Behavioral;
