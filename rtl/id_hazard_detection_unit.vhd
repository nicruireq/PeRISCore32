---------------------------------------------------------------------------------------------
--! @file   id_hazard_detection_unit.vhd
--! @brief ID hazard detection unit
--! @author Nicolas Ruiz Requejo
--! @details    id_hazard_detection_unit is a block of 
--!             combinational logic aimed to stall the 
--!             pipeline operation when a hazard is impossible
--!             to be resolved by forward mechanisms.
--!             This hazards must be detected in ID stage,
--!             where the nop pseudo instruction can be
--!             inserted in the ID/EX register to allow
--!             that the bubble can flow through the pipeline
--!              - id_hazard_detection_unit is located in ID stage.
--!              - Stall operation means: 
--!                 + Insert a NOP in ID/EX
--!                 + Inhibits PC writings
--!                 + Inhibits IF/ID writings
--!              - List of detected hazards:
--!                 + load-use hazards (lw-x)
--!                 + beq operands having a RAW with
--!                   past instructions
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

entity id_hazard_detection_unit is
    port (
        ex_mem_mem_read : in control_signal;
        ex_mem_rt : in register_index;
        id_ex_mem_read : in control_signal;
        id_ex_reg_write : in control_signal;
        id_ex_operandB_src : in control_signal;
        id_ex_rd : in register_index;
        id_ex_rt : in register_index;
        if_id_rs : in register_index;
        if_id_rt : in register_index;
        id_mem_write : in control_signal; --! to detect a sw being decoded in ID stage
        id_branch : in control_signal;  --! to detect a beq being decoded in ID stage
        stall : out control_signal; --! Inserts a "bubble" through the pipeline
        pc_write : out control_signal;  --! Inhibits writing in PC register
        if_id_write : out control_signal    --! Inhibits writing in IF/ID register
    );
end entity id_hazard_detection_unit;

architecture behavioral of id_hazard_detection_unit is
    
begin
    
    analyze_hazards: process(ex_mem_mem_read, ex_mem_rt,
        id_ex_mem_read, id_ex_reg_write, 
        id_ex_operandB_src, id_ex_rd, id_ex_rt,
        if_id_rs, if_id_rt, id_mem_write, id_branch)
    begin
        -- LW-x-BEQ, when lw is in ex/mem register
        if (ex_mem_mem_read = '1') and
            (id_branch = '1') and
            ((ex_mem_rt = if_id_rs) or (ex_mem_rt = if_id_rt))
        then
            stall <= '1';
            pc_write <= '0';
            if_id_write <= '0';
        -- load use hazard and lw-beq
        elsif (id_ex_mem_read = '1') and
                (id_mem_write = '0') and    -- instruction in ID stage is not a SW
                ((id_ex_rt = if_id_rs) or (id_ex_rt = if_id_rt))
        then
            stall <= '1';
            pc_write <= '0'; 
            if_id_write <= '0';
        -- R-BEQ hazard
        elsif (id_ex_reg_write = '1') and
                (id_branch = '1') and
                (id_ex_rd /= zero) and
                ((id_ex_rd = if_id_rs) or (id_ex_rd = if_id_rt))
        then
            stall <= '1';
            pc_write <= '0';
            if_id_write <= '0';
        -- I-BEQ hazard
        elsif (id_ex_reg_write = '1') and
                (id_branch = '1') and
                (id_ex_operandB_src = '1') and
                (id_ex_rt /= zero) and
                ((id_ex_rt = if_id_rs) or (id_ex_rt = if_id_rt))
        then
            stall <= '1';
            pc_write <= '0';
            if_id_write <= '0';
        else
            stall <= '0';
            pc_write <= '1';
            if_id_write <= '1';
        end if;        
    end process analyze_hazards;
    
end architecture behavioral;