---------------------------------------------------------------------------------------------
--! @file   ex_forward_unit.vhd
--! @brief EX forwarding unit
--! @author Nicolas Ruiz Requejo
--! @details    ex_forward_unit unit is a block of 
--!             combinational logic aimed to forward
--!             operands needed during EX stage when
--!             any type of RAW hazard happens between
--!             instruction currently runinng in EX stage
--!             and past instruction in MEM and WB stages.
--!              - ex_forward_unit is located in EX stage.
--!              - List of hazards managed:
--!                 + Combinations of R or I type instructions
--!                   between EX and MEM or EX and WB stages
--!                   that lead to RAW hazards
--!                 + RAW hazard between lw/sw address calculation
--!                   in EX stage and  R/I type instructions in
--!                   MEM or WB stages
--!                 + Allows forwarding of destination operand
--!                   of lw instruction in a load-use hazard after
--!                   the stall cycles
--!              - Table of forwardings:
--!                 *forward_A* value  |   operand being forwarded
--!                 -------------------|--------------------------
--!                         00         |    none
--!                         01         |    Alu result from EX/MEM
--!                         10         |    Alu result from MEM/WB
--!                         11         |    data cache from MEM/WB
--!
--!                 *forward_B* value  |   operand being forwarded
--!                 -------------------|--------------------------
--!                         00         |    none
--!                         01         |    Alu result from EX/MEM
--!                         10         |    Alu result from MEM/WB
--!                         11         |    data cache from MEM/WB
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

entity ex_forward_unit is
    port (
        ex_mem_reg_write : in control_signal;
        ex_mem_rd : in register_index;
        mem_wb_reg_write : in control_signal;
        mem_wb_mem_read : in control_signal;
        mem_wb_rd : in register_index;
        mem_wb_rt : in register_index;
        id_ex_rs : in register_index;
        id_ex_rt : in register_index;
        forward_A : out ex_forward; --! control signal to command the forwarding action for operand_A
        forward_B : out ex_forward  --! control signal to command the forwarding action for operand_B
    );
end entity ex_forward_unit;

architecture behavioral of ex_forward_unit is
    
begin
    
    forward_operand_A: process(ex_mem_reg_write,
        mem_wb_reg_write, mem_wb_mem_read, mem_wb_rd, 
        mem_wb_rt, ex_mem_rd, id_ex_rs, id_ex_rt)
    begin
        -- First evaluate hazard between EX and MEM
        if (ex_mem_reg_write = '1') and 
            (ex_mem_rd /= zero) and
            (ex_mem_rd = id_ex_rs) then
                forward_A <= "01";
        -- load-use hazard forwarding
        -- High priority, the order matters
        elsif (mem_wb_reg_write = '1') and
                (mem_wb_mem_read = '1') and
                (mem_wb_rt /= zero) and
                (mem_wb_rt = id_ex_rs) then
                    forward_A <= "11";
        -- Second evaluate hazard between EX and WB
        elsif (mem_wb_reg_write = '1') and
                (mem_wb_rd /= zero) and
                (ex_mem_rd /= id_ex_rs) and
                (mem_wb_rd = id_ex_rs) then
                    forward_A <= "10";
        else    -- no hazard
            forward_A <= "00";
        end if;
    end process forward_operand_A;

    forward_operand_B: process(ex_mem_reg_write,
        mem_wb_reg_write, mem_wb_mem_read, mem_wb_rd,
        mem_wb_rt, ex_mem_rd, id_ex_rs, id_ex_rt)
    begin
        if (ex_mem_reg_write = '1') and 
            (ex_mem_rd /= zero) and
            (ex_mem_rd = id_ex_rt) then
                forward_B <= "01";
        elsif (mem_wb_reg_write = '1') and
            (mem_wb_mem_read = '1') and
            (mem_wb_rt /= zero) and
            (mem_wb_rt = id_ex_rt) then
                forward_B <= "11";
        elsif (mem_wb_reg_write = '1') and
                (mem_wb_rd /= zero) and
                (ex_mem_rd /= id_ex_rt) and
                (mem_wb_rd = id_ex_rt) then
                    forward_B <= "10";
        else
            forward_B <= "00";
        end if;
    end process forward_operand_B;
    
end architecture behavioral;