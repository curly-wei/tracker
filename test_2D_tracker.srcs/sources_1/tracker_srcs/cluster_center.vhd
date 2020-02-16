----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:03:37 04/07/2014 
-- Design Name: 
-- Module Name:    cluster_center - Behavioral 
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
use IEEE.STD_LOGIC_1164.all;

library work;
use work.types.all;

entity cluster_center is
    port(
        CenterX       : out CenterMapX;
        CenterY       : out CenterMapY;
        X             : in  std_logic_vector(3 downto 0);
        Y             : in  std_logic_vector(3 downto 0);
        Z             : in  std_logic_vector(3 downto 0);
        InputMap      : in  ClusterMapType;
        top_clkdata_s : in  std_logic
        );

end cluster_center;

architecture Behavioral of cluster_center is
    signal ClusterMap : ClusterMapType;
    signal squareList : std_logic_vector(ClusterWidth * ClusterHeight - 1 downto 0);
    signal isTRbelow  : std_logic_vector(ClusterWidth * ClusterHeight downto 0);

    subtype square is std_logic_vector(3 downto 0);
    type SquareRow is array (0 to ClusterWidth - 1) of square;
    type SquareM is array (0 to ClusterHeight - 1) of SquareRow;
    signal corner_TRList : SquareM;
    signal corner_TR     : std_logic_vector(3 downto 0);
    signal corner_BL     : std_logic_vector(3 downto 0);
    signal new_corner_TR : std_logic_vector(3 downto 0);
    signal new_corner_BL : std_logic_vector(3 downto 0);
    signal CornerMap     : ClusterMapType;

    component relation_patternII
        port(
            ClusterMap    : out ClusterMapType;
            X             : in  std_logic_vector(3 downto 0);
            Y             : in  std_logic_vector(3 downto 0);
            Z             : in  std_logic_vector(3 downto 0);
            InputMap      : in  ClusterMapType;
            Top_clkData_s : in  std_logic
            );
    end component;

    component patternI_corners is
        port(
            new_corner_TR : out std_logic_vector(3 downto 0);
            new_corner_BL : out std_logic_vector(3 downto 0);
            corner_TR     : in  std_logic_vector(3 downto 0);
            corner_BL     : in  std_logic_vector(3 downto 0);
            Top_clkData_s : in  std_logic
            );
    end component;

    component midpoint is
        port (
            ClusterMap : in  ClusterMapType;
            CenterX    : out CenterMapX;
            CenterY    : out CenterMapY);
    end component midpoint;

begin

    clusterPII : relation_patternII
        port map(
            ClusterMap    => ClusterMap,
            X             => X,
            Y             => Y,
            Z             => Z,
            InputMap      => InputMap,
            Top_clkData_s => Top_clkData_s
            );
---------------------------------------------------------------------
    clusterPI : patternI_corners
        port map (
            corner_TR(3 downto 0)     => corner_TR(3 downto 0),
            corner_BL(3 downto 0)     => corner_BL(3 downto 0),
            new_corner_TR(3 downto 0) => new_corner_TR(3 downto 0),
            new_corner_BL(3 downto 0) => new_corner_BL(3 downto 0),
            Top_clkData_s             => Top_clkData_s
            );

    -- get the bottom left square
    BLin_i : for i in 0 to 1 generate
        BLin_j : for j in 0 to 1 generate
            corner_BL(2 * i + j) <= ClusterMap(i)(j);
        end generate BLin_j;
    end generate BLin_i;

    -- example:
    -- squareList: 000100101
    -- isTRbelow: 1111000000..
    -- get the top right square
    isTRbelow(ClusterWidth * ClusterHeight) <= '1';
    TRin_y : for y2 in ClusterHeight - 1 downto 0 generate
        TRin_x : for x2 in ClusterWidth - 1 downto 0 generate
            squareList(x2 + y2 * ClusterWidth) <= ClusterMap(2 * y2)(2 * x2) or
                                                  ClusterMap(2 * y2)(2 * x2 + 1) or
                                                  ClusterMap(2 * y2 + 1)(2 * x2) or
                                                  ClusterMap(2 * y2 + 1)(2 * x2 + 1);
            isTRbelow(x2 + y2 * ClusterWidth) <= isTRbelow(x2 + y2 * ClusterWidth + 1) and
                                                 not squareList(x2 + y2 * ClusterWidth);
            TRin_i : for i in 0 to 1 generate
                TRin_j : for j in 0 to 1 generate
                    corner_TRList(y2)(x2)(2 * i + j) <= ClusterMap(2 * y2 + i)(2 * x2 + j) and
                                                        isTRbelow(x2 + y2 * ClusterWidth + 1) and
                                                        squareList(x2 + y2 * ClusterWidth);
                end generate TRin_j;
            end generate TRin_i;
        end generate TRin_x;
    end generate TRin_y;

    corner_TR <= corner_TRList(0)(0) or corner_TRList(0)(1) or corner_TRList(0)(2) or
                 corner_TRList(1)(0) or corner_TRList(1)(1) or corner_TRList(1)(2) or
                 corner_TRList(2)(0) or corner_TRList(2)(1) or corner_TRList(2)(2);

    --write new top right square to corner map
    TRout_y : for y2 in ClusterHeight - 1 downto 0 generate
        TRout_x : for x2 in ClusterWidth -1 downto 0 generate
            TRout_i : for i in 0 to 1 generate
                TRout_j : for j in 0 to 1 generate
                    BLout : if y2 = 0 and x2 = 0 generate
                        -- write new bottom left square to corner map
                        CornerMap(i)(j) <= new_corner_BL(2 * i + j) xor
                                           (new_corner_TR(2 * i + j) and
                                            isTRbelow(x2 + y2 * ClusterWidth + 1) and
                                            squareList(x2 + y2 * ClusterWidth));
                    end generate BLout;
                    nonBLout: if y2 > 0 or x2 > 0 generate
                        CornerMap(2 * y2 + i)(2 * x2 + j) <= new_corner_TR(2 * i + j) and
                                                             isTRbelow(x2 + y2 * ClusterWidth + 1) and
                                                             squareList(x2 + y2 * ClusterWidth);
                    end generate nonBLout;
                end generate TRout_j;
            end generate TRout_i;
        end generate TRout_x;
    end generate TRout_y;

    -- find mid points of the two corners
    -- skip if the two corners overlap
    midpoint_1: entity work.midpoint
        port map (
            ClusterMap => CornerMap,
            CenterX    => CenterX,
            CenterY    => CenterY);

end Behavioral;
