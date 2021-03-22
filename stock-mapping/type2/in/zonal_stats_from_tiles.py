#!/usr/bin/python

import sys
import gdal
import numpy as np

print('Number of arguments:', len(sys.argv), 'arguments.')
print('Argument List:', str(sys.argv))

targetPath = str(sys.argv[1]).split(" ")[0]
zonesPath = str(sys.argv[2]).split(" ")[0]

zones = gdal.Open(zonesPath).ReadAsArray()
target = gdal.Open(stocksPath).ReadAsArray()

## ID unique ids in zones, write to array
uids = np.unique(zones)
sums = []

## loop through ids, for each id, build sum of target[zones == ID)
for uid in uids:
    sums.append(np.sum(target, where = zones == uid))

all = [uids, sums]

## write array to text file
np.savetxt(targetPath + "/sum_.txt", np.transpose(all), delimiter=",", fmt='%1.2f')
