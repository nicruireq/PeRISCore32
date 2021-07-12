-------------------------------------------------------
--! @file   ex_forward_unit.vhd
--! @brief EX forwarding unit
-------------------------------------------------------

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
        forward_A : out ex_forward;
        forward_B : out ex_forward
    );
end entity ex_forward_unit;

architecture behavioral of ex_forward_unit is
    
begin
    
    forward_operand_A: process(ex_mem_reg_write,
        mem_wb_reg_write, mem_wb_mem_read, mem_wb_rd, 
        ex_mem_rd, id_ex_rs, id_ex_rt)
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
        ex_mem_rd, id_ex_rs, id_ex_rt)
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