#!/usr/bin/python

import os
import sys
import pandas as pd
import numpy as np

print('Number of arguments:', len(sys.argv), 'arguments.')
print('Argument List:', str(sys.argv))

outPath = str(sys.argv[1]).split(" ")[0]

sums = []
for i in range(2,len(sys.argv)):
    df = pd.read_csv(sys.argv[i], header = None)
    sums.append(df)
  
frame = pd.concat(sums, axis=0, ignore_index = True)
groupedDF = frame.groupby(0).sum()  
exit()
groupedDF.to_csv(outPath, sep=";", header=False)