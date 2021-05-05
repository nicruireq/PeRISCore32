
library ieee;
use ieee.std_logic_1164.all;

library periscore32;
use periscore32.cpu_types.word;

package testbench_helpers is
    
    procedure wait_for_assert(time_pre_assert : Time := 1 ps);

    procedure assert_comb_eq(
        signal asserted_signal : in word;
        expected_value : in word;
        message : in string;
        operation_time : in Time
    );

end package ;

package body testbench_helpers is

    procedure wait_for_assert(time_pre_assert : Time := 1 ps) is
    begin
        wait for time_pre_assert;
    end procedure wait_for_assert;

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

end package body;