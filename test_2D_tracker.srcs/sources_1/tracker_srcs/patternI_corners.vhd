----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    11:32:45 04/08/2014
-- Design Name:
-- Module Name:    patternI_corners - Behavioral
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

entity patternI_corners is
	port(
        new_corner_TR : out  std_logic_vector(3 downto 0);
        new_corner_BL : out  std_logic_vector(3 downto 0);
        corner_TR : IN  std_logic_vector(3 downto 0);
        corner_BL : IN  std_logic_vector(3 downto 0);
			Top_clkData_s: IN std_logic
		  );
	end patternI_corners;

architecture Behavioral of patternI_corners is

begin
    -- numbering:
    -- 23
    -- 01

    -- favor top right
    -- favor 1 over 2
    new_corner_TR(3) <= corner_TR(3);
    new_corner_TR(1) <= not corner_TR(3) and corner_TR(1);
    new_corner_TR(2) <= not corner_TR(3) and not corner_TR(1) and corner_TR(2);
    new_corner_TR(0) <= not corner_TR(3) and not corner_TR(1) and not corner_TR(2) and corner_TR(0);

    -- favor buttom left
    -- favor 2 over 1
    new_corner_BL(0) <= corner_BL(0);
    new_corner_BL(2) <= not corner_BL(0) and corner_BL(2);
    new_corner_BL(1) <= not corner_BL(0) and not corner_BL(2) and corner_BL(1);
    new_corner_BL(3) <= not corner_BL(0) and not corner_BL(2) and not corner_BL(1) and corner_BL(3);

end Behavioral;
