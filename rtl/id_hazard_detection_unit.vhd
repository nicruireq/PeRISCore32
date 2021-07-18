-------------------------------------------------------
--! @file   id_hazard_detection_unit.vhd
--! @brief ID hazard detection unit
-------------------------------------------------------

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
        stall : out control_signal;
        pc_write : out control_signal;
        if_id_write : out control_signal
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