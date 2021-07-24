-------------------------------------------------------
--! @file   mem_forward_unit.vhd
--! @brief MEM forwarding unit
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library periscore32;
use periscore32.cpu_types.all;

entity mem_forward_unit is
    port (
        ex_mem_write : in control_signal;
        ex_mem_rt : in register_index;
        mem_wb_rd : in register_index;
        mem_wb_rt : in register_index;
        mem_wb_reg_write : in control_signal;
        mem_wb_mem_read : in control_signal;
        mem_wb_is_IType : in control_signal;
        forward_mem : out mem_forward
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