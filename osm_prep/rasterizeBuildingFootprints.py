#!/usr/bin/python

# Use: rasterizeVector.py tile
# parallel -a tiles.txt --eta -j 10 python rasterizeVector{}

import os
os.environ['OMP_NUM_THREADS'] = '1'

import sys
import time
from hubflow.core import *
from hubdc.core import *

print('Number of arguments:', len(sys.argv), 'arguments.')
print('Argument List:', str(sys.argv))

s = time.time()
allargs = str(sys.argv[1]).split(" ")
allargs2 = str(sys.argv[2]).split(" ")
state = allargs[0]
state2 = allargs2[0]

#### set
pathToVectorFile = ''
pathToDirWithReferenceRasters = ''
outPath = ''

print("starting state " + state)
vectorPath = pathToVectorFile + "/merge.sqlite"
options = ['COMPRESS=LZW', 'BIGTIFF=YES', 'INTERLEAVE=BAND']
country = "us"
ll = "bld"  # can take "highway", "railway", "apron", "parking", "runway", "taxiway", "rail-brdtun", "road-brdtun"
classes = 1
    
attribute = "layer"
drv = ogr.GetDriverByName('ESRI Shapefile')
	
s = time.time()

allTiles = [x for x in os.listdir(pathToDirWithReferenceRasters)]
for tile in allTiles:
    print(tile)
    if os.path.exists(outPath + "/" + state2 + "/" + tile + "/" + state2 + ".tif"):
        if not os.path.exists(outPath "/" + state2 + "-" + ll + "/vector/" + tile + "/"):
            os.makedirs(outPath + "/" + state2 + "-" + ll + "/vector/" + tile + "/")
            os.makedirs(outPath + "/temp/" + state2 + "-" + ll + "/vector/" + tile + "/")
        
        tempOutVectorPath = pathToDirWithReferenceRasters + "/" + state2 + "-" + ll + "/vector/" + tile + "/" + state2 + ".shp"
        
        controls = ApplierControls()
        
        referenceGridPath = pathToDirWithReferenceRasters + "/" + state2 + "/" + tile + "/" + state2 + ".tif"
        grid = Raster(referenceGridPath).grid()
        ### clip vector to reference raster extent
        referenceRaster = gdal.Open(referenceGridPath)
        ulx, xres, xskew, uly, yskew, yres = referenceRaster.GetGeoTransform()
        sizeX  = referenceRaster.RasterXSize * xres
        sizeY  = referenceRaster.RasterYSize * yres
        lrx = ulx + sizeX
        lry = uly + sizeY
        
        destRef = osr.SpatialReference(wkt=referenceRaster.GetProjection())
        destRef = osr.SpatialReference()   
        destRef.ImportFromWkt(referenceRaster.GetProjectionRef())
        
        ds_in = gdal.OpenEx(vectorPath)
        ds_out = gdal.VectorTranslate(tempOutVectorPath, ds_in, format = 'ESRI Shapefile', srcSRS = destRef, dstSRS = destRef, spatFilter = [ulx, lry, lrx, uly], spatSRS = destRef)
        del ds_out

        dataSet = drv.Open(tempOutVectorPath, 1)
        layer = dataSet.GetLayer()
        featureCount = layer.GetFeatureCount()
        
        fd = ogr.FieldDefn("layer", ogr.OFTInteger)
        layer.CreateField(fd)
        
        counter = 0
        for feature in layer:
            counter = counter + 1
            feature.SetField("layer", 1)
            layer.SetFeature(feature)
        
        dataSet.Destroy()
        dataSet = None

        raster = Raster(referenceGridPath)
        rds = raster.dataset()
        
        fn = outPath + "/" + state2 + "-" + ll + "/" + tile + "/" + state2 + ".tif"
        if(featureCount == 0):
            arr = np.zeros((classes, rds.xsize(), rds.ysize()))
            arr = arr.astype(np.uint8)
            rd = RasterDataset.fromArray(arr, grid=grid, driver=RasterDriver('GTiff'), filename=fn, options=options)
            rd.setNoDataValue(value=255)
            rd = None
        
        if(featureCount != 0):
            classification = VectorClassification(tempOutVectorPath, attribute, minOverallCoverage=0, minDominantCoverage=0, oversampling=10)
            fraction = Fraction.fromClassification(outPath + "/temp/" + state2 + "-" + ll + "/" + tile + "/" + state2 + ".tif", classification, grid=grid, controls=controls)
            fraction = fraction.array()
            fraction[fraction < 0] = 0
            if(len(fraction) < classes):
                arr = np.zeros((classes-len(fraction), rds.xsize(), rds.ysize()))
                fraction = np.concatenate((fraction, arr), axis = 0)
            fraction = (fraction * 100).astype(np.uint8)
        
            rd = RasterDataset.fromArray(fraction, grid=grid, driver=RasterDriver('GTiff'), filename=fn, options=options)
            rd.setNoDataValue(value=255)
            rd = None
        
        dataSet = None
        outds = None
        print("done" + "--- %s seconds ---" % (time.time() - s))