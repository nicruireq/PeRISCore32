---------------------------------------------------------------------------------------------
--! @file   register_file_tb.vhd
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

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.testbench_helpers.all;

entity register_file_tb is
    generic (
        registers : integer := registers_amount;
        register_width : integer := word_width;
        address_width : integer := regfile_address_width
    );
end;

architecture bench of register_file_tb is

  component register_file
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
  end component;

  signal clk: std_logic;
  signal reg_write: std_logic;
  signal address_A: std_logic_vector(address_width-1 downto 0);
  signal address_B: std_logic_vector(address_width-1 downto 0);
  signal address_write: std_logic_vector(address_width-1 downto 0);
  signal data_in: word;
  signal operand_A: word;
  signal operand_B: word ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: register_file port map ( clk            => clk,
                                reg_write      => reg_write,
                                address_A      => address_A,
                                address_B      => address_B,
                                address_write  => address_write,
                                data_in        => data_in,
                                operand_A      => operand_A,
                                operand_B      => operand_B );

  stimulus: process
  begin
  
    -- Put initialisation code here
    wait for 10 ns;

    -- Put test bench stimulus code here

    -- only writes
    reg_write <= '1';

    address_write <= "00000";
    data_in <= rand_slv(word_width);
    wait for 10 ns;

    address_write <= "00001";
    data_in <= rand_slv(word_width);
    wait for 10 ns;


    address_write <= "00010";
    data_in <= rand_slv(word_width);
    wait for 10 ns;

    -- only reads
    reg_write <= '0';
    address_A <= "00001";
    address_B <= "00001";
    wait for 10 ns;
    address_A <= "00001";
    address_B <= "00010";
    wait for 10 ns;
    address_A <= "00000";
    address_B <= "00001";
    wait for 10 ns;


    -- reading and writing at the same time
    -- one port
    reg_write <= '1';

    address_write <= "00001";
    address_A <= "00001";
    address_B <= "00010";
    data_in <= rand_slv(word_width);
    wait for 10 ns;
    reg_write <= '0';
    wait for 10 ns;

    -- reading and writing at the same time
    -- all ports
    reg_write <= '1';
    address_write <= "00010";
    address_A <= "00010";
    address_B <= "00010";
    data_in <= rand_slv(word_width);
    wait for 10 ns;
    reg_write <= '0';
    wait for 10 ns;


    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
