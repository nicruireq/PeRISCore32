
-- VHDL Testbench Template 
-- Autogenerated from nicruireq::hdltools app 
-- Written by Nicolas Ruiz Requejo
-- 
-- Notice:
-- Fill this template with your test code
-- Please if you discover a bug submit an Issue in
-- https://github.com/nicruireq/XilinxTclStore
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

library periscore32;
use periscore32.cpu_types.all;
use periscore32.testbench_helpers.all;

ENTITY pipelined_datapath_hazards2_tb IS
END pipelined_datapath_hazards2_tb;

ARCHITECTURE behavior OF pipelined_datapath_hazards2_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
    component pipelined_datapath is
        generic (
            icache_instructions : string;
            icache_tags : string;
            dcache_data : string
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            stop_start : in std_logic;
            dcache_address : in word;
            dcache_out : out word
        ) ;
    end component ;

    signal clk : std_logic;
    signal reset : std_logic;
    signal stop_start : std_logic;
    signal dcache_address : word;
    signal dcache_out : word;

    constant clock_period: time := 10 ns;
    signal stop_the_clock: boolean;

BEGIN    

    -- Instantiate the Unit Under Test (UUT)
	-- UUT:
	-- set "icache_instructions" for a different program execution
    my_pipelined_datapath : pipelined_datapath
    generic map(
        icache_instructions => "./images/hazards2.dat",
        icache_tags => "./images/e1_tags.dat",
        dcache_data => "./images/dcache_empty.dat"
    )
    port map(
        clk => clk,
        reset => reset,
        stop_start => stop_start,
        dcache_address => dcache_address,
        dcache_out => dcache_out
    );

     -- Stimulus process
    stim_proc: process
        variable expected_results : word_array := load_memory_image("./images/hazards2_result.dat");
    begin
        -- Put initialisation code here
        reset <= '1';
        wait for 20 ns;
	    -- Put test bench stimulus code here
        reset <= '0';
        stop_start <= '1';
        -- wait cycles for all instructions in test program
        wait for 200 ns; 
        reset <= '0';
        -- force to stop all memory elements to update
        stop_start <= '0';

        -- assert dcache memory with correct program results
        for i in word_array'range loop
            dcache_address <= std_logic_vector(to_unsigned(i*4, word'length));
            assert_comb_eq(
                dcache_out, expected_results(i), 
                "Address " & integer'image(i) & " do not match", --& " yields: " & std_logic_vector'image(dcache_out) & " but expected: " & std_logic_vector'image(expected_results(i)),
                10 ns
            );
        end loop;

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

END;