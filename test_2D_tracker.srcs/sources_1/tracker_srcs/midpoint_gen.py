print 'This file is obsolete!'
exit(0)

ClusterWidth = 3
ClusterHeight = 3

ClusterMapWidth = 2 * ClusterWidth
ClusterMapHeight = 2 * ClusterHeight

CenterMapWidth = 2 * ClusterWidth + 1
CenterMapHeight = 2 * ClusterHeight + 1

# possible area for center of 3x3 cluster size
# .-.-.-.-.-.-.
# | | | | | | |
# .-.-.-.-.-.-.
# | | | | | | |
# .-.-.-.-.-.-.
# |o\o\o\o| | |
# .=,=,=,=.-.-.
# |o\o\o\o| | |
# .=,=,=,=.-.-.
# |x\x\o\o| | |
# .=,=,=,=.-.-.
# |x\x\o\o| | |
# .-.-.-.-.-.-.
#  0 1 2 3 4 5    clustermap
#  0123456        centermap


mids = ''
for y in range(CenterMapHeight):
    mid = '    CenterMapY({}) <= '.format(y)
    products = []
    for y1 in range(2):
        y2 = y - y1
        if y2 < y1: continue
        if y2 == ClusterMapHeight: continue
        products.append(
            '(ClusterY({y1}) and ClusterY({y2}))'.format(y1 = y1, y2 = y2))
    if (len(products) == 0): continue
    mids += mid
    mids += ' or\n{sp}'.format(sp = ' '*len(mid)).join(products)
    mids += ';\n\n'

for x in range(CenterMapWidth):
    mid = '    CenterMapX({}) <= '.format(x)
    products = []
    for x1 in range(2):
        x2 = x - x1
        if x2 < x1: continue
        if x2 == ClusterMapHeight: continue
        products.append(
            '(ClusterX({x1}) and ClusterX({x2}))'.format(x1 = x1, x2 = x2))
    if (len(products) == 0): continue
    mids += mid
    mids += ' or\n{sp}'.format(sp = ' '*len(mid)).join(products)
    mids += ';\n\n'

output = """-- generated from midpoint_gen.py
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
    signal ClusterX: std_logic_vector(ClusterMapRow'range);
    signal ClusterY: std_logic_vector(ClusterMap'range);

begin  -- architecture Lookup

    -- purpose: Project cluster map to x and y axis
    -- type   : combinational
    -- inputs : ClusterMap
    -- outputs: ClusterX, ClusterY
    project: process (ClusterMap) is
    variable regY : std_logic_vector(ClusterMap'range) := (others => '0');
    variable regX : std_logic_vector(ClusterMapRow'range) := (others => '0');
    begin  -- process project
        for x in ClusterMapRow'range loop
            for y in ClusterMap'range loop
                regX(x) := regX(x) or Cluster(y)(x);
                regY(y) := regY(y) or Cluster(y)(x);
            end loop;
        end loop;
        ClusterX <= regX;
        ClusterY <= regY;
    end process project;

{}
end architecture Lookup;
""".format(mids)

with open('Midpoint.vhd', 'w') as fout:
    fout.write(output)
