#!/usr/bin/python

import os
import sys
import pandas as pd
import numpy as np

print('Number of arguments:', len(sys.argv), 'arguments.')
print('Argument List:', str(sys.argv))

sums = []
for i in range(1,len(sys.argv)):
    f.append(sys.argv[i])
    
    df = pd.read_csv(sys.argv[i], header = None)
    sums.append(df)

frame = pd.concat(sums, axis=0, ignore_index = True)
groupedDF = frame.groupby(0).sum()  
groupedDF.to_csv("/data/Jakku/usa/counties/stats/US_" + state + "/US_AL.txt", sep=",", header=False)