#!/usr/bin/env python3

import sys
import gdal
import numpy as np

#print('Number of arguments:', len(sys.argv), 'arguments.')
#print('Argument List:', str(sys.argv))

outPath = str(sys.argv[1]).split(" ")[0]
targetPath = str(sys.argv[2]).split(" ")[0]
zonesPath = str(sys.argv[3]).split(" ")[0]

targetDS = gdal.Open(targetPath)
zonesDS = gdal.Open(zonesPath)

targetND = targetDS.GetRasterBand(1).GetNoDataValue()
#zonesND = zonesDS.GetRasterBand(1).GetNoDataValue()

target = targetDS.ReadAsArray()
zones = zonesDS.ReadAsArray()

## ID unique ids in zones, write to array
uids = np.unique(zones)
sums = []

## loop through ids, for each id, build sum of target[zones == ID)
for uid in uids:
    sums.append(np.sum(target, where = (zones == uid) & (target != targetND)))

all = [uids, sums]

## write array to text file
np.savetxt(outPath, np.transpose(all), delimiter=";", fmt='%1.2f')
