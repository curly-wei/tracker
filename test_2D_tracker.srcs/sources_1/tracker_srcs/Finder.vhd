-------------------------------------------------------------------------------
-- Title      : Finder.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Finder.vhd
-- Author     : Tzu-An Sheng  <tasheng@hep1.phys.ntu.edu.tw>
-- Company    : 
-- Created    : 2016-10-19
-- Last update: 2016-11-04
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-10-19  1.0      tristesse	Created
-------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;

library work;
use work.types.all;

entity Finder is

    port (
        rPhiPlane     : out SquareMap;
        SL0_TS        : in  SL_Hit (NumTSF0 downto 0);
        SL2_TS        : in  SL_Hit (NumTSF2 downto 0);
        SL4_TS        : in  SL_Hit (NumTSF4 downto 0);
        SL6_TS        : in  SL_Hit (NumTSF6 downto 0);
        SL8_TS        : in  SL_Hit (NumTSF8 downto 0);
        Top_clkData_s : in  std_logic);

end entity Finder;

architecture FinderLogic of Finder is

    component HoughVoting is
        port (
            HoughMap      : out SL_map_ex(ConstHoughMap'range);
            SL0_TS        : IN  SL_Hit(NumTSF0 downto 0);
            SL2_TS        : IN  SL_Hit(NumTSF2 downto 0);
            SL4_TS        : IN  SL_Hit(NumTSF4 downto 0);
            SL6_TS        : IN  SL_Hit(NumTSF6 downto 0);
            SL8_TS        : IN  SL_Hit(NumTSF8 downto 0);
            Top_clkData_s : IN  std_logic);
    end component HoughVoting;

    component cluster_center is
        port (
            CenterX       : out CenterMapX;
            CenterY       : out CenterMapY;
            X             : IN  std_logic_vector(3 downto 0);
            Y             : IN  std_logic_vector(3 downto 0);
            Z             : IN  std_logic_vector(3 downto 0);
            InputMap      : in  ClusterMapType;
            top_clkdata_s : IN  std_logic);
    end component cluster_center;

    constant sqr_x0 : natural := x0 / 2;
    constant sqr_x1 : natural := (x1 - 1) / 2;
    constant sqr_y0 : natural := y0 / 2;
    constant sqr_y1 : natural := (y1 - 1) / 2;

    -- type ExtendedMap is array (0 to HoughMapHeight + ClusterMapHeight - 1) of MapRow;
    -- slice assignment only works for arrays of the same type, so ...
    signal PaddedMap : SL_Map_ex(0 to HoughMapHeight + ClusterMapHeight - 1);

    type CenterMapXRows is array (0 to sqr_x1 - sqr_x0) of CenterMapX;
    type CenterMapXs    is array (0 to sqr_y1 - sqr_y0) of CenterMapXRows;
    type CenterMapYRows is array (0 to sqr_x1 - sqr_x0) of CenterMapY;
    type CenterMapYs    is array (0 to sqr_y1 - sqr_y0) of CenterMapYRows;
    signal CenterXs : CenterMapXs;
    signal CenterYs : CenterMapYs;

    signal HoughMap  : SL_map_ex(ConstHoughMap'range) := (others => (others => '0'));

    -- inputs
    subtype square_ser is std_logic_vector(3 downto 0);
    type SquareRow is array (sqr_x0 to sqr_x1) of square_ser;
    type SquareArray is array (sqr_y0 to sqr_y1) of SquareRow;
    signal InputX : SquareArray;
    signal InputY : SquareArray;
    signal InputZ : SquareArray;
    type ClusterRow is array (sqr_x0 to sqr_x1) of ClusterMaptype;
    type ClusterArray is array (sqr_y0 to sqr_y1) of ClusterRow;

    signal CombinedMap : SquareMap;
    signal InputCluster : ClusterArray;

-- purpose: return specified cluster region
    function GetClusterMap (
        -- signal InputMap : ExtendedMap;
        signal InputMap : SL_Map_ex(PaddedMap'range);
        constant x      : natural;  -- x index of the 2x2 square
        constant y      : natural)  -- y index of the 2x2 square
        return ClusterMapType is
        variable OutputMap : ClusterMapType := (others => (others => '0'));
    begin  -- function GetClusterMap
        for i in 0 to ClusterMapHeight -1 loop
            OutputMap(i) := InputMap(2*y + i)(2*x to 2*x + ClusterMapWidth - 1);
        end loop;
        return OutputMap;
    end function GetClusterMap;

    function GetNeighbor (
        signal InputMap : SL_Map_ex(PaddedMap'range);
        constant x      : natural;  -- x index of the 2x2 square
        constant y      : natural)  -- y index of the 2x2 square
        return std_logic_vector is
    begin  -- function GetNeighbor
        return InputMap(2 * y + 1)(2 * x + 1) &
            InputMap(2 * y + 1)(2 * x) &
            InputMap(2 * y)(2 * x + 1) &
            InputMap(2 * y)(2 * x);
    end function GetNeighbor;

    function OR0to3X (
        signal input : CenterMapXs;
        constant y: natural;
        constant x: natural)
        return std_logic_vector is
        variable result : std_logic;
    begin  -- function OR3
        result := input(y)(x)(0) or input(y)(x)(1) or input(y)(x)(2) or input(y)(x)(3);
        return result & result & result & result;
    end function OR0to3X;

    function OR0to3Y (
        signal input : CenterMapYs;
        constant y: natural;
        constant x: natural)
        return std_logic_vector is
        variable result : std_logic;
    begin  -- function OR3
        result := input(y)(x)(0) or input(y)(x)(1) or input(y)(x)(2) or input(y)(x)(3);
        return result & result & result & result;
    end function OR0to3Y;

    function OR4to6X (
        signal input : CentermapXs;
        constant y: natural;
        constant x: natural)
        return std_logic_vector is
        variable result : std_logic;
    begin  -- function OR3
        result := input(y)(x)(4) or input(y)(x)(5) or input(y)(x)(6);
        return result & result & result & result;
    end function OR4to6X;

    function OR4to6Y (
        signal input : CentermapYs;
        constant y: natural;
        constant x: natural)
        return std_logic_vector is
        variable result : std_logic;
    begin  -- function OR3
        result := input(y)(x)(4) or input(y)(x)(5) or input(y)(x)(6);
        return result & result & result & result;
    end function OR4to6Y;

begin  -- architecture FinderLogic

    -- voting
    HoughVoting_1: HoughVoting
        port map (
            HoughMap      => HoughMap,
            SL0_TS        => SL0_TS,
            SL2_TS        => SL2_TS,
            SL4_TS        => SL4_TS,
            SL6_TS        => SL6_TS,
            SL8_TS        => SL8_TS,
            Top_clkData_s => Top_clkData_s);

    -- Filling extended map and padding zeros
    PaddedMap(0 to 1)                         <= (others => (others => '0'));
    PaddedMap(y0 to y1)                       <= HoughMap;
    PaddedMap(y1 + 1 to PaddedMap'length - 1) <= (others => (others => '0'));

    -- clustering
    geny: for y in sqr_y0 to sqr_y1 generate
        genx: for x in sqr_x0 to sqr_x1 generate
            InputCluster(y)(x) <= GetClusterMap(PaddedMap, x, y);
            InputX(y)(x) <= GetNeighbor(PaddedMap, x - 1, y    );
            InputY(y)(x) <= GetNeighbor(PaddedMap, x - 1, y - 1);
            InputZ(y)(x) <= GetNeighbor(PaddedMap, x    , y - 1);
            center: cluster_center
                port map (
                    CenterX       => CenterXs(y - sqr_y0)(x - sqr_x0),
                    CenterY       => CenterYs(y - sqr_y0)(x - sqr_x0),
                    InputMap      => InputCluster(y)(x),
                    X             => InputX(y)(x),
                    Y             => InputY(y)(x),
                    Z             => InputZ(y)(x),
                    top_clkdata_s => top_clkdata_s);
        end generate genx;
    end generate geny;

-- purpose: combine center map instances into fine map X and Y
-- type   : combinational
-- inputs : CenterXs, CenterYs
-- outputs: CombinedMap
Combine: process (CenterXs, CenterYs) is
    type SquareMapReg is array(0 to 3) of SquareMap;
    variable CombinedReg: SquareMapReg :=
        (others => (others => (others => (others => (others =>'0')))));
begin  -- process Combine
    insty: for y in 0 to SquareMap'high loop
        instx: for x in 0 to SquareMapRow'high loop
            if x /= SquareMapRow'high then
                CombinedReg(0)(y)(x)(0) := CenterXs(y)(x)(0 to 3) and
                                           OR0to3Y(CenterYs, y, x);
                CombinedReg(0)(y)(x)(1) := CenterYs(y)(x)(0 to 3) and
                                           OR0to3X(CenterXs, y, x);
            else
                CombinedReg(0)(y)(x)(0) := "0000";
                CombinedReg(0)(y)(x)(1) := "0000";
            end if;
            if x /= 0 then
                CombinedReg(1)(y)(x)(0) := CenterXs(y)(x - 1)(4 to 6) & '0' and
                                           OR0to3Y(CenterYs, y, x - 1);
                CombinedReg(1)(y)(x)(1) := CenterYs(y)(x - 1)(0 to 3) and
                                           OR4to6X(CenterXs, y, x - 1);
            else
                CombinedReg(1)(y)(x)(0) := "0000";
                CombinedReg(1)(y)(x)(1) := "0000";
            end if;
            if y /= 0 and x /= SquareMapRow'high then
                CombinedReg(2)(y)(x)(0) := CenterXs(y - 1)(x)(0 to 3) and
                                           OR4to6Y(CenterYs, y - 1, x);
                CombinedReg(2)(y)(x)(1) := CenterYs(y - 1)(x)(4 to 6) & '0' and
                                           OR0to3X(CenterXs, y - 1, x);
            else
                CombinedReg(2)(y)(x)(0) := "0000";
                CombinedReg(2)(y)(x)(1) := "0000";
            end if;
            if x /= 0 and y /= 0 then
                CombinedReg(3)(y)(x)(0) := CenterXs(y - 1)(x - 1)(4 to 6) & '0' and
                                           OR4to6Y(CenterYs, y - 1, x - 1);
                CombinedReg(3)(y)(x)(1) := CenterYs(y - 1)(x - 1)(4 to 6) & '0' and
                                           OR4to6X(CenterXs, y - 1, x - 1);
            else
                CombinedReg(3)(y)(x)(0) := "0000";
                CombinedReg(3)(y)(x)(1) := "0000";
            end if;
            CombineOR: for axis in Square'range loop
                CombinedMap(y)(x)(axis) <= CombinedReg(0)(y)(x)(axis) or
                                           CombinedReg(1)(y)(x)(axis) or
                                           CombinedReg(2)(y)(x)(axis) or
                                           CombinedReg(3)(y)(x)(axis);
                end loop;
        end loop;
    end loop;
end process Combine;

    rPhiPlane <= CombinedMap;

end architecture FinderLogic;
