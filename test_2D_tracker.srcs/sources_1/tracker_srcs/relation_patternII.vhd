----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:34:09 03/31/2014 
-- Design Name: 
-- Module Name:    relation_patternII - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.types.all;

entity relation_patternII is
port(
    ClusterMap : out ClusterMapType;
    X : IN  std_logic_vector(3 downto 0);
    Y : IN  std_logic_vector(3 downto 0);
    Z : IN  std_logic_vector(3 downto 0);
    InputMap : IN ClusterMapType;
    Top_clkData_s:IN std_logic
    );
end relation_patternII;

architecture Behavioral of relation_patternII is
    signal OutputMap : ClusterMapType := (others => (others => '0'));
begin

    ClusterMap <= OutputMap;

    -- Is X, Y, Z related to A?
    seed_i: for i in 0 to 1 generate
      seed_j: for j in 0 to 1 generate
        OutputMap(i)(j) <= not((X(1) and InputMap(0)(0)) or
                                 (X(3) and InputMap(1)(0)) or
                                 (X(1) and InputMap(1)(0)) or
                                 (Y(3) and InputMap(0)(0)) or
                                 (Z(2) and InputMap(0)(0)) or
                                 (Z(3) and InputMap(0)(1)) or
                                 (Z(2) and InputMap(0)(1))) and
                            InputMap(i)(j);
      end generate seed_j;
    end generate seed_i;

    -- Check connections of bottom row
    relateBottom_x: for x2 in 1 to ClusterWidth - 1 generate
      relateBottom_i: for i in 0 to 1 generate
        relateBottom_j: for j in 0 to 1 generate
          OutputMap(i)(2 * x2 + j) <= ((OutputMap(0)(2 * x2 - 1) and InputMap(0)(2 * x2)) or
                                        (OutputMap(1)(2 * x2 - 1) and InputMap(1)(2 * x2)) or
                                        (OutputMap(0)(2 * x2 - 1) and InputMap(1)(2 * x2))) and
                                       InputMap(i)(2 * x2 + j);
        end generate relateBottom_j;
      end generate relateBottom_i;
    end generate relateBottom_x;

    -- Check connections of left column
    relateLeft_y: for y2 in 1 to ClusterHeight - 1 generate
      relateLeft_i: for i in 0 to 1 generate
        relateLeft_j: for j in 0 to 1 generate
          OutputMap(2 * y2 + i)(j) <= ((OutputMap(2 * y2 - 1)(0) and InputMap(2 * y2)(0)) or
                                        (OutputMap(2 * y2 - 1)(1) and InputMap(2 * y2)(1)) or
                                        (OutputMap(2 * y2 - 1)(0) and InputMap(2 * y2)(1))) and
                                       InputMap(2 * y2 + i)(j);
        end generate relateLeft_j;
      end generate relateLeft_i;
    end generate relateLeft_y;

    -- Check connections of the rest
    relate_x: for x2 in 1 to ClusterWidth - 1 generate
      relate_y: for y2 in 1 to ClusterHeight - 1 generate
        relate_i: for i in 0 to 1 generate
          relate_j: for j in 0 to 1 generate
            OutputMap(2 * y2 + i)(2 * x2 + j) <= ((OutputMap(2 * y2    )(2 * x2 - 1) and InputMap(2 * y2    )(2 * x2)) or    -- \
                                                   (OutputMap(2 * y2 + 1)(2 * x2 - 1) and InputMap(2 * y2 + 1)(2 * x2)) or    -- horizontal
                                                   (OutputMap(2 * y2    )(2 * x2 - 1) and InputMap(2 * y2 + 1)(2 * x2)) or    -- /
                                                   (OutputMap(2 * y2 - 1)(2 * x2 - 1) and InputMap(2 * y2)(2 * x2)) or    -- diagonal
                                                   (OutputMap(2 * y2 - 1)(2 * x2    ) and InputMap(2 * y2)(2 * x2    )) or    -- \
                                                   (OutputMap(2 * y2 - 1)(2 * x2 + 1) and InputMap(2 * y2)(2 * x2 + 1)) or    -- vertical
                                                   (OutputMap(2 * y2 - 1)(2 * x2    ) and InputMap(2 * y2)(2 * x2 + 1))) and  -- /
                                                  InputMap(2 * y2 + i)(2 * x2 + j);
          end generate relate_j;
        end generate relate_i;
      end generate relate_y;
    end generate relate_x;

end Behavioral;

