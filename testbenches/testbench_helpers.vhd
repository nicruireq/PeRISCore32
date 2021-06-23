
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
    
    procedure assert_comb_eq(
        signal asserted_signal : in word;
        expected_value : in word;
        message : in string;
        operation_time : in Time
    );

    procedure assert_comb_eq(
        signal asserted_signal : in std_logic;
        expected_value : in std_logic;
        message : in string;
        operation_time : in Time
    );

    impure function rand_slv(len : integer) return std_logic_vector;

    -- Global variables needed by uniform procedure in 
    -- rand_slv function
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