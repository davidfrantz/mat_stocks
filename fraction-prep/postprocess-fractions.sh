#!/bin/bash


function postprocess(){

  TILE=$1
  WKT=$2
  ZMAX=$3
  
  DEM=/data/Jakku/global/dem/global_srtm-aster__-180W-180E-90E--90S.vrt
  SLOPE=/data/Jakku/global/dem/global_srtm-aster__-180W-180E-90E--90S_slope.tif
  WATERBODY=/data/Jakku/global/water-bodies/extent_global.vrt
  
 
  if ls $TILE/*V2*MLP.tif 1> /dev/null 2>&1; then
    FRACTION=$(ls $TILE/*V2*MLP.tif | head -n 1)
  else
    exit
  fi
  

  XSIZE=$(gdalinfo $FRACTION | grep Block | head -n 1 | sed 's/.*Block=//' | cut -d 'x' -f 1)
  YSIZE=$(gdalinfo $FRACTION | grep Block | head -n 1 | sed 's/.*Block=//' | cut -d 'x' -f 2 | sed 's/ .*//')

  RES=$(gdalinfo $FRACTION | grep 'Pixel Size' |  sed 's/[(),=]/ /g' | tr -s ' ' | cut -d ' ' -f 3)

  XMIN=$(gdalinfo $FRACTION | grep 'Upper Left' | sed 's/[(),]//g' | tr -s ' ' | cut -d ' ' -f 3)
  YMAX=$(gdalinfo $FRACTION | grep 'Upper Left' | sed 's/[(),]//g' | tr -s ' ' | cut -d ' ' -f 4)
  XMAX=$(gdalinfo $FRACTION | grep 'Lower Right' | sed 's/[(),]//g' | tr -s ' ' | cut -d ' ' -f 3)
  YMIN=$(gdalinfo $FRACTION | grep 'Lower Right' | sed 's/[(),]//g' | tr -s ' ' | cut -d ' ' -f 4)

  # country
  COUNTRY=$TILE/COUNTRY.dat
  gdal_rasterize -burn 1 -a_nodata 255 -ot 'Byte' -of 'ENVI' -init 255 -tr $RES $RES -te $XMIN $YMIN $XMAX $YMAX tempshape.shp $COUNTRY &> /dev/null

  if ! ls $COUNTRY 1> /dev/null 2>&1; then
    exit
  fi

  MAX=$(gdalinfo -stats $COUNTRY | grep Maximum | head -n 1 | sed 's/[=,]/ /g' | tr -s ' ' | cut -d ' ' -f 5 | sed 's/\..*//' ) 
  echo "max: " $MAX

  if [ -z $MAX ]; then
    rm $COUNTRY
    exit
  fi
  
  if [ ! $MAX -eq 1 ]; then
    rm $COUNTRY
    exit
  fi

  # convert fractions to byte
  BYTEFRAC=$TILE/FRACTIONS_BYTE.dat
  gdal_calc.py -A $FRACTION --allBands=A  --outfile=$BYTEFRAC --calc='(minimum(A,10000)/100)*(A>0)' --NoDataValue=0 --type=Byte --format=ENVI --overwrite &> /dev/null

  # warp water bodies (temp)
  gdalwarp -t_srs "$WKT" -te $XMIN $YMIN $XMAX $YMAX -tr $RES $RES -r mode -multi -of VRT -overwrite $WATERBODY $TILE/WATER-EXTENT.vrt &> /dev/null

  # water bodies
  WATER_EXTENT=$TILE/WATER-EXTENT.dat
  gdal_calc.py -A $TILE/WATER-EXTENT.vrt --outfile=$WATER_EXTENT --calc='A!=1' --NoDataValue=255 --type=Byte --format=ENVI --overwrite &> /dev/null

  # slope
  SLOPE_ALL=$TILE/SLOPE.dat
  gdalwarp -t_srs "$WKT" -te $XMIN $YMIN $XMAX $YMAX -tr $RES $RES -r bilinear -ot Byte -multi -of ENVI -overwrite $SLOPE $SLOPE_ALL &> /dev/null

  # high slope mask
  SLOPE_25=$TILE/SLOPE-25.dat
  gdal_calc.py -A $SLOPE_ALL --outfile=$SLOPE_25 --calc='(A<25)' --NoDataValue=255 --type=Byte --format=ENVI --overwrite &> /dev/null
  
  # low slope mask
  SLOPE_10=$TILE/SLOPE-10.dat
  gdal_calc.py -A $SLOPE_ALL --outfile=$SLOPE_10 --calc='(A<10)' --NoDataValue=255 --type=Byte --format=ENVI --overwrite &> /dev/null
  
  # dem
  DEM_ALL=$TILE/DEM.dat
  gdalwarp -t_srs "$WKT" -te $XMIN $YMIN $XMAX $YMAX -tr $RES $RES -r bilinear -multi -of ENVI -overwrite $DEM $DEM_ALL &> /dev/null

  # high altitude mask
  DEM_HIGH=$TILE/DEM-$ZMAX.dat
  gdal_calc.py -A $DEM_ALL --outfile=$DEM_HIGH --calc="A<$ZMAX" --NoDataValue=255 --type=Byte --format=ENVI --overwrite &> /dev/null

  # make sure nodata is set okay
  gdal_edit.py -a_nodata 255 $BYTEFRAC
  gdal_edit.py -a_nodata 255 $COUNTRY
  gdal_edit.py -a_nodata 255 $WATER_EXTENT
  gdal_edit.py -a_nodata 255 $SLOPE_10
  gdal_edit.py -a_nodata 255 $SLOPE_25
  gdal_edit.py -a_nodata 255 $DEM_HIGH 

  gdal_calc.py -A $BYTEFRAC --A_band=1 -B $COUNTRY -C $WATER_EXTENT -D $DEM_HIGH -E $SLOPE_25 --calc="A*B*C*D*E" --format=ENVI --NoDataValue=255 --outfile=$TILE/BU.dat --overwrite &> /dev/null
  gdal_calc.py -A $BYTEFRAC --A_band=2 -B $COUNTRY -C $WATER_EXTENT --calc="A*B*C" --format=ENVI --NoDataValue=255 --outfile=$TILE/WV.dat --overwrite &> /dev/null
  gdal_calc.py -A $BYTEFRAC --A_band=3 -B $COUNTRY -C $WATER_EXTENT --calc="A*B*C" --format=ENVI --NoDataValue=255 --outfile=$TILE/NWV.dat --overwrite &> /dev/null
  gdal_calc.py -A $BYTEFRAC --A_band=4 -B $COUNTRY -C $WATER_EXTENT -D $SLOPE_10 --calc="maximum((A*B*D),((C==0)*100))" --format=ENVI --NoDataValue=255 --outfile=$TILE/W.dat --overwrite &> /dev/null

  gdal_merge.py -o $TILE/FRACTIONS_BU-WV-NWV-W_clean.tif -of GTiff -co 'COMPRESS=LZW' -co 'PREDICTOR=2' -co 'NUM_THREADS=ALL_CPUS' -co 'BIGTIFF=YES' -co "BLOCKXSIZE=$XSIZE" -co "BLOCKYSIZE=$YSIZE" -co 'INTERLEAVE=BAND' -separate -init 255 -n 255 -a_nodata 255 -ot Byte $TILE/BU.dat $TILE/WV.dat $TILE/NWV.dat $TILE/W.dat &> /dev/null

  rm $TILE/*.vrt $TILE/*.dat $TILE/*.hdr $TILE/*.xml

  #echo done with $TILE
  exit

}

export -f postprocess



EXPECTED_ARGS=4

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: fraction-cube country-shape z-max njobs"
  exit
fi

INP=$1
SHP=$2
ZMAX=$3
NJOB=$4

if [ ! -r $SHP ]; then
  echo "$SHP is not existing/readable"
  exit
fi

if [ ! -r $INP ]; then
  echo "$INP is not existing/readable"
  exit
fi

cd $INP


WKT=$(head -n 1 datacube-definition.prj)

# reproject country shapefile

ogr2ogr -t_srs "$WKT" tempshape.shp $SHP &> /dev/null

# post-process the fraction maps
echo "postprocessing fractions:"
ls -d X* | parallel -j $NJOB --eta postprocess {} "$WKT" $ZMAX

# remove reprojected shapefile
rm tempshape.*

# virtual mosaics
echo "computing virtual mosaics:"
force-mosaic . &> /dev/null
cd mosaic

# overviews
echo "computing overviews:"
force-pyramid FRACTIONS_BU-WV-NWV-W_clean.vrt

