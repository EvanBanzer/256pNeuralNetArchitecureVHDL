library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture behavioral of ann_layer is
  type weight_array is array (0 to N_OUT-1, 0 to N_IN) of integer;
  type pixel_array is array (0 to N_IN-1) of integer;
  type output_array is array (0 to N_OUT-1) of integer;
  type phase_type is (IDLE, LOAD_W, READ_IMG, COMPUTE, SEND_OUT);

begin
  process(clk)
    variable weights : weight_array;
    variable pixels : pixel_array;
    variable outputs : output_array;
    variable phase : phase_type := IDLE;

  begin 
    if rising_edge(clk) then
      if rst='1' then
        phase := IDLE;
      else
        case phase is 
          when IDLE => null; --WIP waiting for start
          when LOAD_W => null; -- WIP store weights
          when READ_IMG => null; --WIP store pixcels
          when COMPUTE => null; -- multiply, add and ReLU
          when SEND_OUT => null; -- WIP output results
        end case;
      end if;
    end if;
  end process;
end architecture behavioral;
