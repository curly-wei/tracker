-------------------------------------------------------------------------------
-- Title      : High Pass
-- Project    : 
-------------------------------------------------------------------------------
-- File       : HighPass.vhd
-- Author     : Tzu-An Sheng  <tasheng@hep1.phys.ntu.edu.tw>
-- Company    : 
-- Created    : 2016-10-20
-- Last update: 2018-05-25
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Pick tracks with highest pt and suppress following signals
-- latency: 1 + NumTracks + 1
-- pureReg + select high + extract r phi
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-10-20  1.0      tristesse	Created
-- 2016-10-27  1.1      tristesse	Seperate nested encoder to x and y encoders
-- 2016-10-29  1.2      tristesse	Use group map instead of fine map
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.types.all;

entity HighPass is

    generic (
        preserved : natural := 0);

    port (
        Top_clkData_s  : in  std_logic;
        WholeTrackMap  : in  SquareMap;
        SingleTrackX   : out Phis := (others => (others => '0'));
        SingleTrackY   : out Rhos := (others => (others => '0'));
        CellIndex      : out CellInfoArray;
        old_track      : out std_logic_vector(NumTracks - 1 downto 0) := (others => '1')
        );

end entity HighPass;

architecture part1 of HighPass is

    signal WholeMapPre     : GroupMap              := (others => (others => '0'));
    signal WholeMapReduced : GroupMapArray(0 to NumTracks - 1) :=
        (others => (others => (others => '0')));
    signal WholeMapReg     : GroupMapArray(0 to NumTracks - 1) :=
        (others => (others => (others => '0')));

    signal Groups   : GroupMap;
    --signal GroupReg : GroupMap := (others => ( others => '0'));
    --signal Squares  : SquareMapArray(0 to NumTracks + 1) :=
    signal Squares  : SquareMapArray(0 to NumTracks) :=
        (others => (others => (others => (others => (others =>'0')))));
    --signal SquareYs : SquareSingleMapArray(0 to 7);
    signal MaskedSquares : SquareMapArray(0 to NumTracks - 1);
    signal AccumulatedSquares : SquareMapArray(0 to NumTracks - 1);

    -- output track maps
    signal track_map_o : GroupMapArray(0 to NumTracks - 1) :=
        (others => (others => (others => '0')));
    signal track_x : Phi1s := (others => (others => '0'));
    signal track_y : Rho1s := (others => (others => '0'));

    -- registers
    type track_map_reg is array (0 to NumTracks - 2) of GroupMapArray(0 to NumTracks - 2);
    signal track_map_r1 : GroupMapArray(0 to NumTracks - 1) :=
        (others => (others => (others => '0')));
    signal track_map_regs : track_map_reg :=
        (others => (others => (others => (others => '0'))));
    constant CellID_NOHIT : std_logic_vector(CellInfo'range) :=
        (CellInfo'high => '0', others => '1');
    signal CellID : CellInfoArray := (others => CellID_NOHIT);
    type unsigned_y is array (0 to NumTracks - 1) of unsigned (rBitSize - 1 downto 0);
    signal yindex : unsigned_y := (others => (others => '1'));
    signal yindex_r : unsigned_y := (others => (others => '1'));
    type unsigned_x is array (0 to NumTracks - 1) of unsigned (PhiBitSize - 1 downto 0);
    signal xindex : unsigned_x := (others => (others => '1'));
    signal xindex_r : unsigned_x := (others => (others => '1'));

begin

    RegisterSquares: process (Top_clkData_s) is
    begin
        if rising_edge(Top_clkData_s) then
            Squares(Squares'high) <= WholeTrackMap;
            Squares(0 to Squares'high - 1) <= Squares(1 to Squares'high);
        end if;
    end process RegisterSquares;

    -- purpose: Group finemap cells into squares
    groupx: for x in GroupMapRow'range generate
        groupy: for y in GroupMap'range generate
            Groups(y)(x) <= WholeTrackMap(y)(x)(0)(0) or
                            WholeTrackMap(y)(x)(0)(1) or
                            WholeTrackMap(y)(x)(0)(2) or
                            WholeTrackMap(y)(x)(0)(3);

            --splitind: for ind in SquareXY'range generate
            --    splitreg: for reg in Squares'range generate
            --        SquareYs(reg)(y)(x)(ind) <= Squares(reg)(y)(x)(1)(ind);
            --    end generate;
            --end generate;
        end generate;
    end generate;

    ---- purpose: suppress the upcoming repeated signal due to persistence
    ---- type   : sequential
    ---- inputs : Top_clkData_s, WholeTrackMap
    ---- outputs: whole_map_reduced
    --reduce: process (Top_clkData_s) is
    --begin  -- process reduce
    --    if (rising_edge(Top_clkData_s)) then
    --        GroupReg <= Groups;
    --        for y in GroupMap'range loop
    --            WholeMapPre(y) <= Groups(y) and not GroupReg(y);
    --        end loop;
    --    end if;
    --end process reduce;

    --Supress : for y in GroupMap'range generate
    --    WholeMapPre(y) <= Groups(y) and not GroupReg(y);
    --end generate;

    -- Suppressing the tracks with the same parameters ignores the updated TS info.
    -- Instead, we postpone the persistence suppression to processor.
    WholeMapPre <= Groups;

    -- purpose: register maps for the xor logic
    -- type   : sequential
    -- inputs : Top_clkData_s, whole_map_reduced
    -- outputs: whole_map_reg
    reg_map: process (Top_clkData_s) is
    begin  -- process reg_map
        if rising_edge(Top_clkData_s) then
            WholeMapReduced(0) <= WholeMapPre;
            WholeMapReg <= WholeMapReduced;
        end if;
    end process reg_map;

    -- Extract single track maps
    SingleTrackXOR: for trk in 1 to NumTracks - 1 generate
        RowXOR: for row in SquareMap'range generate
            WholeMapReduced(trk)(row) <= track_map_r1(trk - 1)(row) xor
                                        WholeMapReg(trk - 1)(row);
        end generate RowXOR;
    end generate SingleTrackXOR;

    GenSelectHigh: for trk in 0 to NumTracks - 1 generate
        trackmap : entity work.select_highpt
            port map(
                --whole_map     => SquareYs(Squares'high - 1 - trk),
                group_map     => WholeMapReduced(trk),
                track_map     => track_map_r1(trk),
                Top_clkData_s => Top_clkData_s);
    end generate GenSelectHigh;

    -- purpose: synchronize track maps from high pt cell outputs
    -- type   : sequential
    -- inputs : Top_clkData_s, track_map_r1
    -- outputs: track_map1
    DelayTrackMap: process (Top_clkData_s) is
    begin  -- process DelayTrackMap
        if rising_edge(Top_clkData_s) then
            for trk in track_map_regs'range loop
                track_map_regs(trk)(0) <= track_map_r1(trk);
                for i in 1 to track_map_regs'high - trk loop
                    track_map_regs(trk)(i) <= track_map_regs(trk)(i - 1);
                end loop;  -- i
            end loop;  -- trk
        end if;
    end process DelayTrackMap;

    SyncedTracks: for trk in 0 to NumTracks - 2 generate
        track_map_o(trk) <= track_map_regs(trk)(track_map_regs'high - trk);
    end generate;
    track_map_o(NumTracks - 1) <= track_map_r1(NumTracks - 1);

    -- purpose: Project single track group map to X and Y axis
    gentrk: for trk in 0 to NumTracks - 1 generate
        geny: for y in GroupMap'range generate
            genx: for x in GroupMapRow'range generate
                genaxis: for axis in Square'range generate
                    genind: for ind in SquareXY'range generate
                        MaskedSquares(trk)(y)(x)(axis)(ind) <=
                            Squares(0)(y)(x)(axis)(ind) and track_map_o(trk)(y)(x);
                    end generate;
                end generate;
            end generate;
        end generate;
    end generate;

    -- accumulate to last row/column
    accutrk: for trk in 0 to NumTracks - 1 generate
        accuy: for y in GroupMap'range generate
            accux: for x in GroupMapRow'range generate
                accuind: for ind in SquareXY'range generate
                    AccumulatedSquares(trk)(0)(x)(0)(ind) <=
                        MaskedSquares(trk)(0)(x)(0)(ind);
                    accuPhi: if y > 0 generate
                        AccumulatedSquares(trk)(y)(x)(0)(ind) <=
                            MaskedSquares(trk)(y    )(x)(0)(ind) or
                            AccumulatedSquares(trk)(y - 1)(x)(0)(ind);
                    end generate accuPhi;
                    AccumulatedSquares(trk)(y)(0)(1)(ind) <=
                        MaskedSquares(trk)(y)(0)(1)(ind);
                    accuRho: if x > 0 generate
                        AccumulatedSquares(trk)(y)(x)(1)(ind) <=
                            MaskedSquares(trk)(y)(x    )(1)(ind) or
                            AccumulatedSquares(trk)(y)(x - 1)(1)(ind);
                    end generate accuRho;
                end generate;
            end generate;
        end generate;
    end generate;

    gettrk: for trk in 0 to NumTracks - 1 generate
        getind: for ind in SquareXY'range generate
            gety: for y in GroupMap'range generate
                track_y(trk)(4*y + ind) <=
                    AccumulatedSquares(trk)(y)(GroupMapRow'high)(1)(ind);
            end generate;
            getx: for x in GroupMapRow'range generate
                track_x(trk)(4*x + ind) <=
                    AccumulatedSquares(trk)(GroupMap'high)(x)(0)(ind);
            end generate;
        end generate;
    end generate;

    -- purpose: extract r and phi info in Hough plane for output
    -- type   : sequential
    -- inputs : Top_clkData_s, track_map_o
    -- outputs: CellID
    HoughCellOutput: process (Top_clkData_s) is
    begin  -- process HoughCellOutput
        if rising_edge(Top_clkData_s) then
            CellID <= (others => CellID_NOHIT);
            xindex <= (others => (others => '1'));
            yindex <= (others => (others => '1'));
            for trk in SingleTrackX'range loop
                SingleTrackY(trk) <= track_y(trk)(0 to FineMap'high);
                SingleTrackX(trk) <= track_x(trk)(0 to FineMapRow'high);
                for y in FineMap'range loop
                    if track_y(trk)(y) = '1' then
                        yindex(trk) <= to_unsigned(y, rBitSize);
                        CellID(trk)(CellInfo'high downto PhiBitSize) <=
                            std_logic_vector(to_signed(y - HoughFineMapHeight/2, rBitSize));
                    end if;
                end loop;
                for x in FineMapRow'range loop
                    if track_x(trk)(x) = '1' then
                        xindex(trk) <= to_unsigned(x, PhiBitSize);
                        CellID(trk)(PhiBitSize - 1 downto 0) <=
                            std_logic_vector(to_unsigned(x, PhiBitSize));
                    end if;
                end loop;
            end loop;
        end if;
    end process HoughCellOutput;

    CellIndex <= CellID;

    -- Check if a track is likely an update of an existing track.
    -- If the difference of omega and phi with another track in last clock
    -- is smaller than 4, mark it as an old track.
    Neighboring : process(Top_clkData_s) is
    begin
        if rising_edge(Top_clkData_s) then
            xindex_r <= xindex;
            yindex_r <= yindex;
            for itrk in 0 to NumTracks - 1 loop
                old_track(itrk) <= '0';
                for jtrk in 0 to NumTracks - 1 loop
                    if (xindex(itrk) - xindex_r(jtrk) < 4 or
                        xindex_r(jtrk) - xindex(itrk) < 4) and
                        (yindex(itrk) - yindex_r(jtrk) < 4 or
                         yindex_r(jtrk) - yindex(itrk) < 4) then
                        old_track(itrk) <= '1';
                    end if;
                end loop;
            end loop;
        end if;
    end process;

end architecture part1;
