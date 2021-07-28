---------------------------------------------------------------------------------------------
--! @file   mem_forward_unit.vhd
--! @brief MEM forwarding unit
--! @author Nicolas Ruiz Requejo
--! @details    mem_forward unit is a block of 
--!             combinational logic aimed to forward
--!             operands needed during MEM stage when
--!             any type of RAW hazard happens between
--!             instruction currently runinng in MEM stage
--!             and past instruction in WB stage.
--!              - mem_forward_unit is located in MEM stage.
--!              - List of hazards managed:
--!                 + Pair of lw-sw instructions
--!                 + Store hazard between R/I-type instruction
--!                   and sw
--!              - Table of forwardings:
--!                 *forward_A* value  |   operand being forwarded
--!                 -------------------|--------------------------
--!                         00         |    none
--!                         01         |    Alu result from MEM/WB
--!                         10         |    data cache from MEM/WB
--!                         11         |    none
--!
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

library periscore32;
use periscore32.cpu_types.all;

entity mem_forward_unit is
    port (
        ex_mem_write : in control_signal;   --! ex_mem.write
        ex_mem_rt : in register_index;  --! ex_mem.rt
        mem_wb_rd : in register_index;  --! mem_wb.rd
        mem_wb_rt : in register_index;  --! mem_wb.rt
        mem_wb_reg_write : in control_signal;   --! mem_wb.reg_write
        mem_wb_mem_read : in control_signal;    --! mem_wb.mem_read
        mem_wb_is_IType : in control_signal;    --! mem_wb.is_IType
        forward_mem : out mem_forward   --! control signal to command the forwarding action
    );
end entity mem_forward_unit;

architecture behavioral of mem_forward_unit is
    
begin
    
    forward_to_sw: process(
        ex_mem_write, ex_mem_rt, mem_wb_rd,
        mem_wb_rt, mem_wb_reg_write,
        mem_wb_mem_read, mem_wb_is_IType
    )
    begin
        -- if (ex_mem_write = '1') and 
        --     (mem_wb_reg_write = '1') and
        --     (mem_wb_rd /= zero) and
        --     (mem_wb_rd = ex_mem_rt)
        -- Store hazard with R and I instruction types
        if (ex_mem_write = '1') and 
            (mem_wb_reg_write = '1') and
            ( ((mem_wb_rd /= zero) and
                (mem_wb_rd = ex_mem_rt)) or 
              ((mem_wb_is_IType = '1') and
                (mem_wb_mem_read = '0') and
                (mem_wb_rt /= zero) and
                (mem_wb_rt = ex_mem_rt)) 
            )
        then
            forward_mem <= "01";
        -- lw-sw pair hazard
        elsif (mem_wb_mem_read = '1') and
                (mem_wb_rt /= zero) and
                (ex_mem_write = '1') and
                (mem_wb_rt = ex_mem_rt)
        then
            forward_mem <= "10";
        else
            forward_mem <= "00";
        end if;
    end process forward_to_sw;
    
end architecture behavioral;