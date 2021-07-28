---------------------------------------------------------------------------------------------
--! @file   memory_utils.vhd
--! @brief types, procedures and functions utilities for
--!        memory initialization in PeRISCore32
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

--! Provides the types "string", "text" and "line"
use STD.TEXTIO.ALL;
--! Allows "std_logic" can be used as a type in the text file
--! It is a not standard package and is deprecated.
use IEEE.STD_LOGIC_TEXTIO.ALL;

--! Allow to use types provided for periscore32 development
library periscore32;
use periscore32.cpu_types.all;

package memory_utils is

    --! Type to build the main control unit's ROM
    type control_unit_rom is array (0 to (2**opcode_width)-1)
            of  main_control_bus;
    
    --! Type to build the ALU control unit's ROM for not-class
    --! instructions
    type alu_control_rom is array (0 to (2**alu_op_width)-1)
            of alu_control_bus;

    --! Type to build the ALU control unit's ROM for SPECIAL
    --! class instructions
    type special_control_rom is array (0 to (2**function_width)-1)
            of special_control_bus;

    -------------------------------------------------------
    --      FUNCTION DECLARATIONS TO LOAD MEMORIES 
    -------------------------------------------------------

    --! @brief  Given a file with lines of binary strings ,
    --!         fill memory data blocks (a line per address)
    --! @param[in] file_name relative or absolute path to the 
    --!            data memory file plus its full name
    --! @return Memory image with the microcode to be loaded 
    --!         in main control unit
    impure function load_memory_from_file(file_name : in string)
        return control_unit_rom;

    --! @brief  Given a file with lines of binary strings ,
    --!         fill memory data blocks (a line per address)
    --! @param[in] file_name relative or absolute path to the 
    --!            data memory file plus its full name
    --! @return Memory image with the microcode to be loaded 
    --!         in alu not-class control unit
    impure function load_memory_from_file(file_name : in string)
        return alu_control_rom;
    
    --! @brief  Given a file with lines of binary strings ,
    --!         fill memory data blocks (a line per address)
    --! @param[in] file_name relative or absolute path to the 
    --!            data memory file plus its full name
    --! @return Memory image with the microcode to be loaded 
    --!         in alu SPECIAL class control unit
    impure function load_memory_from_file(file_name : in string)
        return special_control_rom;

end package;

package body memory_utils is
    
    impure function load_memory_from_file(file_name : in string)
            return control_unit_rom is

        -- "fdata" is the object type "file"
        file fdata : text open read_mode is file_name;
        -- "mline" is a variable to read the file, line to line
        variable mline : line;
        -- "temp_mem" is a variable to read values in a line
        variable temp_mem: control_unit_rom;

    begin

        for i in control_unit_rom'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

        return temp_mem;
    end function;

    impure function load_memory_from_file(file_name : in string)
            return alu_control_rom is

        -- "fdata" is the object type "file"
        file fdata : text open read_mode is file_name;
        -- "mline" is a variable to read the file, line to line
        variable mline : line;
        -- "temp_mem" is a variable to read values in a line
        variable temp_mem: alu_control_rom;
        
    begin

        for i in alu_control_rom'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

        return temp_mem;
    end function;

    impure function load_memory_from_file(file_name : in string)
            return special_control_rom is

        -- "fdata" is the object type "file"
        file fdata : text open read_mode is file_name;
        -- "mline" is a variable to read the file, line to line
        variable mline : line;
        -- "temp_mem" is a variable to read values in a line
        variable temp_mem: special_control_rom;
        
    begin

        for i in special_control_rom'range loop
            readline(fdata, mline);
            read(mline, temp_mem(i));
        end loop;

        return temp_mem;
    end function;

end package body;