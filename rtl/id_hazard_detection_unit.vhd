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
        id_ex_mem_read : in control_signal;
        id_ex_rt : in register_index;
        if_id_rs : in register_index;
        if_id_rt : in register_index;
        id_mem_write : in control_signal; --! to detect a sw being decoded in ID stage
        stall : out control_signal;
        pc_write : out control_signal;
        if_id_write : out control_signal
    );
end entity id_hazard_detection_unit;

architecture behavioral of id_hazard_detection_unit is
    
begin
    
    proc_name: process(id_ex_mem_read, id_ex_rt, if_id_rs, if_id_rt, 
                        id_mem_write)
    begin
        if (id_ex_mem_read = '1') and
            (id_mem_write = '0') and
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
    end process proc_name;
    
end architecture behavioral;