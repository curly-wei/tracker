import numpy as np

# free parameters
# pt range
minPt = 0.3
# number of cells
nX = 160
nY = 34
# vertical shift (up / down /off: +1 / -1 / 0)
shiftSign = 0
# extra cells on each side for quarter plane
extraXleft = 2
extraXright = 4
# starting index for quarter plane
x0 = 100
# switch for using a separate map to create inverse mapping
useFineMappingForInverse = False

# derived values
# phi range (x axis of Hough plane)
minX = -np.pi
maxX = np.pi
dx = (maxX - minX) / nX
# limited range for qurater detector with overlap
xL = x0 - extraXleft
x1 = x0 + nX / 4
xR = x1 + extraXright
# 1/r range (y axis of Hough plane)
maxYsym = 29.9792458 * 1.5e-4 / minPt
minY = -maxYsym + shiftSign * maxYsym / nY / 2;
maxY = maxYsym + shiftSign * maxYsym / nY / 2
dy = (maxY - minY) / nY

# CDC constants
r = np.array([[19.8, 40.16, 62., 83.84, 105.68],
              [20.8, 41.98, 63.82, 85.66, 107.5]])
nTS = np.array([160, 192, 256, 320, 384])

# dimension: SL, Hough map rows, Hough map columns, TS ID, priority
def createMapping(Xlist, Ylist):
    mapping = np.zeros((5, len(Ylist) - 1, len(Xlist) - 1, nTS[-1], 2))
    for iax in range(0, 5):
        TSlist = np.array(range(nTS[iax])) * 2 * np.pi / nTS[iax]
        PRlist = np.array([0, 1])
        Xgrid, Ygrid, TSgrid, PRgrid = np.meshgrid(Xlist, Ylist, TSlist, PRlist)
        XgridMin = Xgrid[:, :-1] - 1e-10
        XgridMax = Xgrid[:, 1:] + 1e-10
        Ygrid = Ygrid[:, :-1]
        TSgrid = TSgrid[:, :-1]
        TSgrid[:, :, :, 1] += np.pi / nTS[iax]
        RgridMin = np.sin(XgridMin - TSgrid)
        RgridMax = np.sin(XgridMax - TSgrid)
        for ipr in PRlist:
            RgridMin[:, :, :, ipr] *= 2 / r[ipr][iax]
            RgridMax[:, :, :, ipr] *= 2 / r[ipr][iax]
        rising = (RgridMin < RgridMax)
        diffYmaxToRmin = Ygrid[1:] - RgridMin[:-1]
        diffYminToRmax = Ygrid[:-1] - RgridMax[1:]
        crossing = (diffYmaxToRmin * diffYminToRmax <= 0)
        mapping[iax][np.where(np.logical_and(rising[:-1], crossing))] = 1
    return mapping

print("calculating mappings")

Xlist = np.linspace(minX, maxX, nX + 1)[xL:xR + 1]
Ylist = np.linspace(minY, maxY, nY + 1)
mapping = createMapping(Xlist, Ylist)
print("mapping has shape", mapping.shape)

largest_ID =  []
for iax in range(5):
    ts = np.argwhere(mapping[iax])[:,2:].sum(axis=1)
    largest_ID.append(
        '({}: {})'.format(iax * 2, np.where(ts < nTS[iax]*0.75, ts, 0).max(0)))
print "(SL, largest TS): " + ", ".join(largest_ID)

print("calculating fine mappings (for inverse map)")

Xlist = np.linspace(minX, maxX, 4 * nX + 1)[(4 * x0 + 1):(4 * x1 + 2 * extraXright):2]
Ylist = np.linspace(minY, maxY, 4 * nY + 1)[1:-1:2]
finemapping = createMapping(Xlist, Ylist)
print("finemapping has shape", finemapping.shape)

print("writing Mapping_SL*.vhd")

# write mapping files
for iax in range(0, 5):
    isl = 2 * iax
    filename = "Mapping_SL%d.vhd" % isl
    header = """
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.types.all;


entity Mapping_SL{sl} is

Port (
     SL{sl}_map : out SL_Map_ex (ConstHoughMap'range) := (others => (others => '0'));
     SL{sl}_TS  : in  SL_HIT (NumTSF{sl} downto 0)
     );
end Mapping_SL{sl};


architecture Behavioral of Mapping_SL{sl} is

begin

""".format(sl = isl)
    fileMap = open(filename, 'w')
    fileMap.write(header)
    for k in range(nY):
        for j in range(xR - xL):
            TSlist = []
            for i in range(nTS[iax]):
                # shift TS ID in SL8 so that all IDs are non-negative
                if iax == 4:
                    shifted_ID = (i + 16) % nTS[4]
                else:
                    shifted_ID = i
                if mapping[iax, k, j, i, 0]:
                    TSlist.append("SL%d_TS(%d)(3)" % (isl, shifted_ID))
                if mapping[iax, k, j, i, 1]:
                    TSlist.append("SL%d_TS(%d)(2)" % (isl, shifted_ID))
                    TSlist.append("SL%d_TS(%d)(1)" % (isl, shifted_ID + 1))
            if len(TSlist) == 0: continue
            fileMap.write("SL%d_map(%d)(%d) <= " % (isl, k, j))
            fileMap.write(" or ".join(TSlist) + ";\n")
    fileMap.write("\nend Behavioral;\n")
    fileMap.close()

print("writing InverseMap*.vhd")

# write inverse mapping file
for iax in range(0, 5):
    isl = 2 * iax
    filename = "InverseMap%d.vhd" % isl
    fileMap = open(filename, 'w')
    header = """
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.types.all;

entity InverseMap{sl} is

Port (
     SL{sl}_TS : out std_logic_vector (NumTSF{sl} downto 0) := (others => '0');
     M         : in  InvMap);

end entity InverseMap{sl};

architecture invmap of InverseMap{sl} is
begin

""".format(sl = isl)
    fileMap.write(header)
    for i in range(nTS[iax]):
        # shift TS ID in SL8 so that all IDs are non-negative
        if iax == 4:
            shifted_ID = (i + 16) % nTS[4]
        else:
            shifted_ID = i
        line = "SL%d_TS(%d) <= " % (isl, shifted_ID)
        cellList = []
        if useFineMappingForInverse:
            for k in range(finemapping.shape[1]):
                for j in range(finemapping.shape[2]):
                    if np.any(finemapping[iax, k, j, i]) or finemapping[iax, k, j, i - 1, 1]:
                        cellList.append("M(%d)(%d)" % (k, j))
        else:
            for k in range(nY):
                for j in range(extraXleft, extraXleft + nX/4 + extraXright/2):
                    if np.any(mapping[iax, k, j, i]) or mapping[iax, k, j, i - 1, 1]:
                        cellList.append("M(%d)(%d)" % (k, j - extraXleft))
        if len(cellList) == 0:
            continue
        line += " or ".join(cellList) + ";\n"
        fileMap.write(line)
    fileMap.write("\nend invmap;\n")
    fileMap.close()
