-------------------------------------------------------------------------------
-- Title      : Midpoint
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Midpoint.vhd
-- Author     : Tzu-An Sheng
-- Company    : 
-- Created    : 2016-10-29
-- Last update: 2016-10-31
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Find middle point of two clustet corners
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-10-29  1.0      ta	Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.types.all;

entity midpoint is

    port (
        ClusterMap : in  ClusterMapType;
        CenterX    : out CenterMapX;
        CenterY    : out CenterMapY);

end entity midpoint;

architecture Lookup of midpoint is
    signal ClusterX : std_logic_vector(ClusterMapRow'range);
    signal ClusterY : std_logic_vector(ClusterMapType'range);
    signal ClusterAccuX : ClusterMapType := (others =>(others => '0'));
    signal ClusterAccuY : ClusterMapType := (others =>(others => '0'));

begin  -- architecture Lookup

    -- purpose: Project cluster map to x and y axis
    projX: for x in ClusterMapRow'range generate
        projY: for y in ClusterMap'range generate
            ClusterAccuX(ClusterMapType'high)(x) <= ClusterMap(ClusterMapType'high)(x);
            ClusterAccuY(y)(ClusterMapRow'high) <= ClusterMap(y)(ClusterMapRow'high);
            accuX: if y < ClusterMapType'high generate
                ClusterAccuX(y)(x) <= ClusterMap(y)(x) or ClusterAccuX(y + 1)(x);
            end generate;
            accuY: if x < ClusterMapRow'high generate
                ClusterAccuY(y)(x) <= ClusterMap(y)(x) or ClusterAccuY(y)(x + 1);
            end generate;
            ClusterX(x) <= ClusterAccuX(0)(x);
            ClusterY(y) <= ClusterAccuY(y)(0);
        end generate;
    end generate;

    -- purpose: Find middle point of two cluster corners
    -- type   : combinational
    -- inputs : ClusterX, ClusterY
    -- outputs: CenterX, CenterY
    Centering: process (ClusterX, ClusterY, ClusterAccuX, ClusterAccuY, ClusterMap) is
        variable x2 : integer := 0;
        variable y2 : integer := 0;
        type CenterXArray is array (0 to 1) of CenterMapX;
        type CenterYArray is array (0 to 1) of CenterMapY;
        variable CenterXReg : CenterXArray := (others => (others => '0'));
        variable CenterYReg : CenterYArray := (others => (others => '0'));
    begin  -- process Centering
        CenterX(0) <= ClusterAccuX(2)(0) or (ClusterMap(1)(0) and ClusterMap(0)(0));
        for x in 1 to CenterX'high loop
            for x1 in 0 to 1 loop
                x2 := x - x1;
                if x = 2 and x1 = 1 then
                    -- Warning: Only work for 3x3 cluster
                    CenterXReg(x1)(x) := ClusterX(x1) and not
                                         (ClusterX(0) or
                                          ClusterX(2) or
                                          ClusterX(3) or
                                          ClusterX(4) or
                                          ClusterX(5));
                elsif x2 < x1 or x2 > ClusterX'high then
                    CenterXReg(x1)(x) := '0';
                else
                    CenterXReg(x1)(x) := ClusterX(x1) and ClusterX(x2);
                end if;
            end loop;
            CenterX(x) <= CenterXReg(0)(x) or CenterXReg(1)(x);
        end loop;

        CenterY(0) <= ClusterAccuY(0)(2) or (ClusterMap(0)(1) and ClusterMap(0)(0));
        for y in 1 to CenterY'high loop
            for y1 in 0 to 1 loop
                y2 := y - y1;
                if y = 2 and y1 = 1 then
                    CenterYReg(y1)(y) := ClusterY(y1) and not
                                         (ClusterY(0) or
                                          ClusterY(2) or
                                          ClusterY(3) or
                                          ClusterY(4) or
                                          ClusterY(5));
                elsif y2 < y1 or y2 > ClusterY'high then
                    CenterYReg(y1)(y) := '0';
                else
                    CenterYReg(y1)(y) := ClusterY(y1) and ClusterY(y2);
                end if;
            end loop;
            CenterY(y) <= CenterYReg(0)(y) or CenterYReg(1)(y);
        end loop;
    end process Centering;

end architecture Lookup;
