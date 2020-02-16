library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package types is
    type SWITCHTYPE is (FULL, SKELETON, CORE);

    constant NumTracks         : natural range 1 to 6          := 4;

    -- largest used TS ID + 2
    constant NumTSF0           : natural                       := 70;
    constant NumTSF2           : natural                       := 89;
    constant NumTSF4           : natural                       := 125;
    constant NumTSF6           : natural                       := 166;
    -- shifted by 16
    constant NumTSF8           : natural                       := 213 + 16;

    constant NumTS             : natural                       := 11 - 1;

    type NaturalArray          is array (natural range <>) of natural;
    constant NumTSFs           : NaturalArray(0 to 4)     :=
        (NumTSF0, NumTSF2, NumTSF4, NumTSF6, NumTSF8);
    constant HoughMapWidth     : natural                       := 40;
    constant HoughMapHeight    : natural                       := 34;

    alias nX : natural is HoughMapWidth;
    alias nY : natural is HoughMapHeight;
    constant xL : natural := 2;
    constant xR : natural := 4;
    constant yB : natural := 2;
    constant yT : natural := 4;

    constant HoughMapWholeWidth: natural                       := HoughMapWidth + xL + xR;

    -- derived indices
    alias x0 : natural is xL;             -- index of first column in active region
    constant x1 : natural := xL + nX - 1; -- index of last column in active region
    constant x2 : natural := x1 + xR;     -- index of last column on total map
    alias y0 : natural is yB;             -- index of first row in active region
    constant y1 : natural := yB + nY - 1; -- index of last row in active region
    constant y2 : natural := y1 + yT;     -- index of last row on extended map

    constant ClusterWidth         : natural              := 3;
    constant ClusterHeight        : natural              := 3;
    constant ClusterMapWidth      : natural              := ClusterWidth * 2;
    constant ClusterMapHeight     : natural              := ClusterHeight * 2;
    constant CenterMapWidth       : natural              := ClusterWidth * 2 + 1;
    constant CenterMapHeight      : natural              := ClusterHeight * 2 + 1;
    constant HoughFineMapHeight   : natural              := HoughMapHeight * 2 - 1;
    constant HoughFineMapWidth    : natural              := 2*nX + XR - 1;
    constant InverseMapWidth      : natural              := nX + ClusterWidth - 1;

    subtype centermapx is std_logic_vector(0 to CenterMapWidth  - 1);
    subtype centermapy is std_logic_vector(0 to CenterMapHeight - 1);

    subtype clustermaprow is std_logic_vector(0 to ClusterMapWidth - 1);
    type ClusterMapType is array (0 to ClusterMapHeight - 1) of clustermaprow;

    subtype maprow is std_logic_vector(0 to HoughMapWholeWidth - 1);
    type SL_Map_Ex is array (natural range <>) of maprow;
    constant ConstHoughMap : SL_map_ex(0 to HoughMapHeight - 1) := (others => (others => '0'));

    subtype InvMapRow is std_logic_vector(0 to InverseMapWidth - 1);
    type InvMap is array (0 to HoughMapHeight - 1) of InvMapRow;

    subtype FineMaprow is std_logic_vector(0 to HoughFineMapWidth - 1);
    type FineMap  is array (0 to HoughFineMapHeight - 1) of FineMaprow;

    type FineMap2D is array (0 to HoughFineMapHeight -1, 0 to HoughFineMapWidth - 1) of std_logic;
    type Rhos is array (0 to NumTracks - 1) of std_logic_vector(FineMap'range);
    type Phis is array (0 to NumTracks - 1) of std_logic_vector(FineMapRow'range);

    type Rho1s is array (0 to NumTracks - 1) of std_logic_vector(0 to FineMap'high + 1);
    type Phi1s is array (0 to NumTracks - 1) of std_logic_vector(0 to FineMapRow'high + 1);

    constant SquareMapWidth  : natural := (nX - 2)/2 + (1 + ClusterWidth)/2;
    constant SquareMapHeight : natural := nY/2;
    subtype SquareXY is std_logic_vector(0 to 3);
    type Square is array(0 to 1) of SquareXY;
    type SquareMapRow is array(0 to SquareMapWidth - 1) of Square;
    type SquareMap is array(0 to SquareMapHeight - 1) of SquareMapRow;
    --type SquareMapArray is array (0 to 5) of SquareMap;
    type SquareMapArray is array (natural range <>) of SquareMap;

    type SquareSingleMapRow is array(0 to SquareMapWidth - 1) of SquareXY;
    type SquareSingleMap is array(0 to SquareMapHeight - 1) of SquareSingleMapRow;
    type SquareSingleMapArray is array(natural range <>) of SquareSingleMap;

    subtype GroupMapRow is std_logic_vector(0 to SquareMapWidth - 1);
    type GroupMap is array(0 to SquareMapHeight - 1) of GroupMapRow;
    type GroupMapArray is array (natural range <>) of GroupMap;

    -- type cell is array (HoughMapHeight)
    type SL_InputPst is array (natural range <>) of std_logic_vector(20 downto 0);
    -- type SL_InputPst is array (natural range <>) of std_logic_vector(12 downto 0);
    type tsfPipe is array (natural range <>) of std_logic_vector(15 downto 0);
    -- subtype HoughMap is std_logic_vector (639 downto 0);
    -- type maps is array (0 to 2) of HoughMap;
    -- subtype HoughCell is std_logic_vector (9 downto 0);
    type SL_Hit is array (natural range <>) of std_logic_vector(3 downto 1);

    type FineMapArray is array (natural range <>) of Finemap;
    type InvMapArray is array (natural range <>) of InvMap;

    subtype SL0_TSHit is std_logic_vector (NumTSF0 downto 0);
    subtype SL2_TSHit is std_logic_vector (NumTSF2 downto 0);
    subtype SL4_TSHit is std_logic_vector (NumTSF4 downto 0);
    subtype SL6_TSHit is std_logic_vector (NumTSF6 downto 0);
    subtype SL8_TSHit is std_logic_vector (NumTSF8 downto 0);

    type SL0_TSHitArray is array (0 to NumTracks - 1) of SL0_TSHit;
    type SL2_TSHitArray is array (0 to NumTracks - 1) of SL2_TSHit;
    type SL4_TSHitArray is array (0 to NumTracks - 1) of SL4_TSHit;
    type SL6_TSHitArray is array (0 to NumTracks - 1) of SL6_TSHit;
    type SL8_TSHitArray is array (0 to NumTracks - 1) of SL8_TSHit;

    subtype TS_Info is std_logic_vector(20 downto 0);
    type TS_Info_SL is array (0 to 4) of TS_Info;
    type TS_Info_SL_Track is array (0 to NumTracks - 1) of TS_Info_SL;


    constant PhiBitSize : natural := 7;
    constant rBitSize   : natural := 1 + 6; -- signed
    subtype CellInfo is std_logic_vector(rBitSize + PhiBitSize - 1 downto 0);
    type CellInfoArray is array (0 to NumTracks - 1) of CellInfo;

end package types;
