-------------------------------------------------------
--! @file   memory_utils.vhd
--! @brief procedures and functions utilities for
--!        PeRISCore32
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Provides the types "string", "text" and "line"
use STD.TEXTIO.ALL;
--! Allows "std_logic" can be used as a type in the text file
--! It is a not standard package and is deprecated.
use IEEE.STD_LOGIC_TEXTIO.ALL;

--! Allow to use types provide for periscore32 development
library periscore32;
use periscore32.cpu_types.all;

package memory_utils is

    --! Type to build the main control unit's ROM
    type control_unit_rom is array (0 to (2**opcode_width)-1)
            of  main_control_bus;
    
    --! Type to build the ALU control unit's ROM
    type alu_control_rom is array (0 to (2**alu_op_width)-1)
            of alu_control_bus;

    -------------------------------------------------------
    --      FUNCTION DECLARATIONS TO LOAD MEMORIES 
    -------------------------------------------------------

    impure function load_memory_from_file(file_name : in string)
        return control_unit_rom;

    impure function load_memory_from_file(file_name : in string)
        return alu_control_bus;

end package;

package body memory_utils is
    
    --!
    --!
    impure function load_memory_from_file(file_name : in string)
            return control_unit_rom is

        -- "fdata" is the object type "file"
        file fdata : text open read_mode is file_name;
        -- "mline" is a variable to read the file, line to line
        variable mline : line;
        -- "temp_mem" is a variable to read values in a line
        variable temp_mem: control_unit_rom;

    begin

        for i in ram_type'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

    end function;

    --!
    --!
    impure function load_memory_from_file(file_name : in string)
            return alu_control_rom is

        -- "fdata" is the object type "file"
        file fdata : text open read_mode is file_name;
        -- "mline" is a variable to read the file, line to line
        variable mline : line;
        -- "temp_mem" is a variable to read values in a line
        variable temp_mem: alu_control_rom;
        
    begin

        for i in ram_type'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

    end function;

end package body;