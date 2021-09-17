#!/usr/bin/env python3
# (C) Andreas Rabe (2019)

from collections import defaultdict, OrderedDict
from os import scandir, makedirs
from os.path import join, exists

from osgeo import gdal

import sys

#import os

#try:
#    from os import scandir, makedirs, DirEntry
#except ImportError:
#    import tempfile
#    with tempfile.NamedTemporaryFile() as ftemp:
#        scan = os.scandir(os.path.dirname(ftemp.name))
#        DirEntry = type(next(scan))
#    del scan, ftemp, tempfile


def convertS1ToForce(infolder, outfolder):
    names = list()
    vvFilenames = defaultdict(list)
    vhFilenames = defaultdict(list)

#    entry: DirEntry
    for entry in scandir(infolder):
        if not entry.name.endswith('.tif'):
            continue

        date = entry.name[1:9]
        polarization = entry.name[39:41]
        idHead = entry.name[29:33]
        idTail = entry.name[41:42]
        #name = f'{date}_LEVEL2_{idHead}{idTail}_SIG.vrt'
        name = date+"_LEVEL2_"+idHead+idTail+"_SIG.vrt"
        if polarization == 'VV':
            vvFilenames[name].append(entry.path)
        if polarization == 'VH':
            vhFilenames[name].append(entry.path)
        if polarization == 'HH':
            continue
        if polarization == 'HV':
            continue
        names.append(name)
    names = set(names)

    if not exists(outfolder):
        makedirs(outfolder)

    for name in names:
        filename = join(outfolder, name)
        print('build VRT:', filename)
        buildVrt(filename=filename, vvFilenames=vvFilenames[name], vhFilenames=vhFilenames[name])


def buildVrt(filename, vvFilenames, vhFilenames):
    # grab infos from first raster
    #ds0: gdal.Dataset = gdal.Open(vvFilenames[0])
    ds0 = gdal.Open(vvFilenames[0])
    xsize = ds0.RasterXSize
    ysize = ds0.RasterYSize
    bands = 2
    
    # create VRT
    driver = gdal.GetDriverByName('VRT')
    ds = driver.Create(filename, xsize, ysize, bands, gdal.GDT_Int16)
    ds.SetGeoTransform(ds0.GetGeoTransform())
    ds.SetProjection(ds0.GetProjection())
    vvSources = OrderedDict()
    vhSources = OrderedDict()
    for i, filename in enumerate(vvFilenames):
        xmlsource = [
            '    <ComplexSource>\n',
            #f'      <SourceFilename relativeToVRT="0">{filename}</SourceFilename>\n',
            '      <SourceFilename relativeToVRT="0">'+filename+'</SourceFilename>\n',
            '      <SourceBand>1</SourceBand>\n',
            '      <NODATA>-9999</NODATA>\n',
            '    </ComplexSource>\n']
        #vvSources[f'source_{i}'] = ''.join(xmlsource)
        vvSources['source_'+str(i)] = ''.join(xmlsource)
    for i, filename in enumerate(vhFilenames):
        xmlsource = [
            '    <ComplexSource>\n',
            #f'      <SourceFilename relativeToVRT="0">{filename}</SourceFilename>\n',
            '      <SourceFilename relativeToVRT="0">'+filename+'</SourceFilename>\n',
            '      <SourceBand>1</SourceBand>\n',
            '      <NODATA>-9999</NODATA>\n',
            '    </ComplexSource>\n']
        #vhSources[f'source_{i}'] = ''.join(xmlsource)
        vhSources['source_'+str(i)] = ''.join(xmlsource)
    ds.GetRasterBand(1).SetMetadata(vvSources, 'vrt_sources')
    ds.GetRasterBand(2).SetMetadata(vhSources, 'vrt_sources')

    # set metadata
    ds.GetRasterBand(1).SetNoDataValue(-9999)
    ds.GetRasterBand(2).SetNoDataValue(-9999)
    ds.GetRasterBand(1).SetDescription('VV')
    ds.GetRasterBand(2).SetDescription('VH')


if __name__ == '__main__':

    #print('Number of arguments:', len(sys.argv)-1, 'arguments.')
    #print('Argument List:', str(sys.argv))
    
    if (len(sys.argv)-1 != 2): 
        print('Usage: '+sys.argv[0]+' input-dir output-dir')
        sys.exit()

    convertS1ToForce(infolder=sys.argv[1], outfolder=sys.argv[2])

