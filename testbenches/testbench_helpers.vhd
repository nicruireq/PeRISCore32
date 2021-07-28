---------------------------------------------------------------------------------------------
--! @file   testbench_helpers.vhd
--! @brief types, procedures and functions utilities for
--!        testbenches in PeRISCore32
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

library ieee;
use ieee.std_logic_1164.all;
USE ieee.math_real.all;

library periscore32;
use periscore32.cpu_types.word;

--! Provides the types "string", "text" and "line"
use STD.TEXTIO.ALL;
--! Allows "std_logic" can be used as a type in the text file
--! It is a not standard package and is deprecated.
use IEEE.STD_LOGIC_TEXTIO.ALL;

package testbench_helpers is
    
    --! @brief  Performs the assertion between a signal and
    --!         an expected value
    --! @param[in]  asserted_signal    signal of type word to be asserted
    --! @param[in]  expected_value     value that the signal must be
    --! @param[in]  message            error message
    --! @param[in]  operation_time     the time in nanoseconds that the assertion takes
    procedure assert_comb_eq(
        signal asserted_signal : in word;
        expected_value : in word;
        message : in string;
        operation_time : in Time
    );

    --! @brief  Performs the assertion between a signal and
    --!         an expected value
    --! @param[in]  asserted_signal    signal of type std_logic to be asserted
    --! @param[in]  expected_value     value that the signal must be
    --! @param[in]  message            error message
    --! @param[in]  operation_time     the time in nanoseconds that the assertion takes
    procedure assert_comb_eq(
        signal asserted_signal : in std_logic;
        expected_value : in std_logic;
        message : in string;
        operation_time : in Time
    );

    --! @brief  Generates random slv
    --! @param[in]  len    width in bits of generated slv
    --! @return     random slv
    impure function rand_slv(len : integer) return std_logic_vector;

    --! Global variables needed by uniform procedure in 
    --! rand_slv function
    shared variable seed1 : positive := 546545; -- FAIL: --positive'value(time'image(now) / 1 ns); --time'image(now) / 1 ns * 1000;
    shared variable seed2 : positive := 125;

    type word_array is array (0 to 255) of word;

    impure function load_memory_image(file_name : in string)
        return word_array;

end package ;

package body testbench_helpers is

    procedure assert_comb_eq(signal asserted_signal : in word;
                             expected_value : in word;
                             message : in string;
                             operation_time : in Time) is
        variable mid_time : Time := operation_time / 2;
    begin
        wait for mid_time;
        assert asserted_signal = expected_value
        report message;
        wait for mid_time;
    end procedure assert_comb_eq;

    procedure assert_comb_eq(signal asserted_signal : in std_logic;
                             expected_value : in std_logic;
                             message : in string;
                             operation_time : in Time) is
        variable mid_time : Time := operation_time / 2;
    begin
        wait for mid_time;
        assert asserted_signal = expected_value
        report message;
        wait for mid_time;
    end procedure assert_comb_eq;

    impure function rand_slv(len : integer) return std_logic_vector is
        variable r : real;
        variable slv : std_logic_vector(len - 1 downto 0);
    begin
        for i in slv'range loop
            uniform(seed1, seed2, r);
            if r > 0.5 then
                slv(i) := '1';
            else
                slv(i) := '0';
            end if;
            --slv(i) := '1' when r > 0.5 else '0';
        end loop;
        return slv;
    end function;


    impure function load_memory_image(file_name : in string)
        return word_array is
            file fdata : text open read_mode is file_name;
            variable mline : line;
            variable temp_mem: word_array;
    begin
        for i in word_array'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

        return temp_mem;
    end function;


end package body;