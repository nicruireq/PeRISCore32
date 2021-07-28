---------------------------------------------------------------------------------------------
--! @file   id_forward_unit.vhd
--! @brief ID forwarding unit
--! @author Nicolas Ruiz Requejo
--! @details    id_forward_unit unit is a block of 
--!             combinational logic aimed to forward
--!             operands needed during ID stage when
--!             any type of RAW hazard happens between
--!             instruction currently runinng ID stage
--!             when past instruction in EX, MEM and WB stages
--!             have RAW hazards with branch (beq) instruction
--!             in ID.
--!              - id_forward_unit is located in ID stage.
--!              - Forwarding happens one-two cycles after 
--!                hazard detection unit stalled the pipeline
--!              - List of hazards managed:
--!                 + lw-beq (after one cycle stall)
--!                 + lw-x-beq (after two cycles stall)
--!                 + lw-x-x-beq
--!                 + R-beq (after one cycle stall)
--!                 + R-x-beq (after two cycle stall)
--!                 + R-x-x-beq
--!                 + I-beq (after one cycle stall)
--!                 + I-x-beq (after two cycle stall)
--!                 + I-x-x-beq
--!                 + And combinations of the above
--!                 + Acts over two operands of beq instruction
--!                   (rs and rt)
--!              - Table of forwardings:
--!                 *forward_A* value  |   operand being forwarded
--!                 -------------------|--------------------------
--!                         00         |    none
--!                         01         |    Alu result from EX/MEM
--!                         10         |    data cache from MEM/WB
--!                         11         |    Alu result from MEM/WB
--!                 *forward_A* value  |   operand being forwarded
--!                 -------------------|--------------------------
--!                         00         |    none
--!                         01         |    Alu result from EX/MEM
--!                         10         |    data cache from MEM/WB
--!                         11         |    Alu result from MEM/WB
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

entity id_forward_unit is
    port (
        ex_mem_reg_write : in control_signal;
        ex_mem_is_IType : in control_signal;
        ex_mem_rd : in register_index;
        ex_mem_rt : in register_index;
        mem_wb_reg_write : in control_signal;
        mem_wb_mem_read : in control_signal;
        mem_wb_is_IType : in control_signal;
        mem_wb_rd : in register_index;
        mem_wb_rt : in register_index;
        if_id_rs : in register_index;
        if_id_rt : in register_index;
        forward_A : out id_forward; --! control signal to command the forwarding action for operand_A
        forward_B : out id_forward  --! control signal to command the forwarding action for operand_B
    );
end entity id_forward_unit;

architecture behavioral of id_forward_unit is
    -- Destination register in EX/MEM register
    signal ex_mem_dst : register_index;
    -- Destination register in MEM/WB register
    signal mem_wb_dst : register_index;
begin

    -- Selects destination register between rd or rt
    -- rd when R-Type and rt when I-Type
    ex_mem_dst <= ex_mem_rt when ex_mem_is_IType = '1'
                    else ex_mem_rd;
    
    mem_wb_dst <= mem_wb_rt when mem_wb_is_IType = '1'
                    else mem_wb_rd;
    
    forward_operand_A: process(ex_mem_reg_write, ex_mem_dst,
        mem_wb_dst, if_id_rs, mem_wb_reg_write, mem_wb_mem_read)
    begin
        -- First resolve R type in EX/MEM
        if (ex_mem_reg_write = '1') and
            (ex_mem_dst /= zero) and
            (ex_mem_dst = if_id_rs)
        then
            forward_A <= "01";
        -- Second, resolve LW in MEM/WB.
        -- Always have priority over R type
        -- because control signals for R-Type are
        -- a subset of those of LW. If not, LWs are
        -- never detected
        elsif (mem_wb_mem_read = '1') and
                (mem_wb_dst /= zero) and
                (mem_wb_dst = if_id_rs)
        then
            forward_A <= "10";
        -- Resolve R type in MEM/WB at the end
        elsif (mem_wb_reg_write = '1') and
                (mem_wb_dst /= zero) and
                (mem_wb_dst = if_id_rs)
        then
            forward_A <= "11";
        else
            forward_A <= "00";
        end if;
    end process forward_operand_A;

    forward_operand_B: process(ex_mem_reg_write, ex_mem_dst,
        mem_wb_dst, if_id_rt, mem_wb_reg_write, mem_wb_mem_read)
    begin
        if (ex_mem_reg_write = '1') and
            (ex_mem_dst /= zero) and
            (ex_mem_dst = if_id_rt)
        then
            forward_B <= "01";
        elsif (mem_wb_mem_read = '1') and
                (mem_wb_dst /= zero) and
                (mem_wb_dst = if_id_rt)
        then
            forward_B <= "10";
        elsif (mem_wb_reg_write = '1') and
                (mem_wb_dst /= zero) and
                (mem_wb_dst = if_id_rt)
        then
            forward_B <= "11";
        else
            forward_B <= "00";
        end if;
    end process forward_operand_B;
    
end architecture behavioral;