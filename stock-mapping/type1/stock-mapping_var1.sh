#!/bin/bash


function stock(){

  TILE=$1

  # DIRECTORIES
  D_MASK=$BASE/mask/$COUNTRY/$TILE
  D_OSM=$BASE/osm/$COUNTRY/$TILE
  D_TYPE=$BASE/type/$COUNTRY/$TILE
  D_FRACTION=$BASE/fraction/$COUNTRY/$TILE
  D_HEIGHT=$BASE/height/$COUNTRY/$TILE
  D_STOCK=$BASE/stock/$COUNTRY/$DISTRICT/$TILE
  D_MI=$BASE/mi/$COUNTRY

  # INPUT RASTER
  BINARY_MASK=$D_MASK/$DISTRICT.tif
  FRACTION=$D_FRACTION/FRACTIONS_BU-WV-NWV-W_clean.tif
  HEIGHT=$D_HEIGHT/BUILDING-HEIGHT_GLOBAL_HL_ML_MLP.tif
  FUNCTION=$D_TYPE/PREDICTION_HL_ML_MLP.tif
  STREET=$D_OSM/streets.tif
  STREETBRIDGE=$D_OSM/road-brdtun.tif
  RAIL=$D_OSM/railway.tif
  RAILBRIDGE=$D_OSM/rail-brdtun.tif
  APRON=$D_OSM/apron.tif
  TAXI=$D_OSM/taxiway.tif
  RUNWAY=$D_OSM/runway.tif
  PARK=$D_OSM/parking.tif

  # INPUT MATERIAL FACTORS
  MI_BUILDING_LIGHT=($(<$D_MI/building-lightweight.txt))
  MI_BUILDING_SINGLE=($(<$D_MI/building-single-family.txt))
  MI_BUILDING_MULTI=($(<$D_MI/building-multi-family.txt))
  MI_BUILDING_HIGH=($(<$D_MI/building-high-rise.txt))
  MI_BUILDING_COMM=($(<$D_MI/building-commercial.txt))
  MI_STREET_MOTOR=($(<$D_MI/road-motorway.txt))
  MI_STREET_MOTOR_ON_BRIDGE=($(<$D_MI/road-motorway-on-bridge.txt))
  MI_STREET_BRIDGE_UNDER_MOTOR=($(<$D_MI/road-bridge-under-motorway.txt))
  MI_STREET_GRAVEL=($(<$D_MI/road-gravel.txt))
  MI_STREET_PRIMARY=($(<$D_MI/road-primary.txt))
  MI_STREET_SECONDARY=($(<$D_MI/road-secondary.txt))
  MI_STREET_TERTIARY=($(<$D_MI/road-tertiary.txt))
  MI_STREET_OTHER=($(<$D_MI/road-other.txt))
  MI_STREET_OTHER_ON_BRIDGE=($(<$D_MI/road-other-on-bridge.txt))
  MI_STREET_BRIDGE_UNDER_OTHER=($(<$D_MI/road-bridge-under-other.txt))
  MI_STREET_TUNNEL=($(<$D_MI/road-tunnel.txt))
  MI_RAIL_RAILWAY=($(<$D_MI/rail-rail.txt))
  MI_RAIL_TRAM=($(<$D_MI/rail-tram.txt))
  MI_RAIL_BRIDGE=($(<$D_MI/rail-bridge.txt))
  MI_RAIL_OTHER=($(<$D_MI/rail-other.txt))
  MI_RAIL_SUBWAY=($(<$D_MI/rail-subway.txt))
  MI_RAIL_SUBWAY_AG_BRIDGE=($(<$D_MI/rail-subway-above-bridge.txt))
  MI_RAIL_SUBWAY_AG_SURFACE=($(<$D_MI/rail-subway-above-surface.txt))
  MI_RAIL_TUNNEL=($(<$D_MI/rail-tunnel.txt))
  MI_RUNWAY=($(<$D_MI/airport.txt))
  MI_PARKING=($(<$D_MI/airport.txt))

  # MATERIALS
  TYPE=("IRON_STEEL" "COPPER" "ALUMINUM" "ALL_OTHER_METALS" "CONCRETE" "BRICKS" "GLASS" "AGGREGATE" "ALL_OTHER_MINERALS" "TIMBER" "OTHER_BIOMASS_BASED_MATERIALS" "BITUMEN" "ALL_OTHER_FOSSIL_FUEL_BASED_MATERIALS" "ALL_OTHER_MATERIALS" "INSULATION")


  # GETTING STARTED
  #########################################################################

  # INPUT MASK exists?
  if [ ! -r $BINARY_MASK ]; then
    exit 1
  fi

  # make output dir and cd
  mkdir -p $D_STOCK
  cd $D_STOCK


  # COPY MASK and set zero = nodata
  MASK=$DISTRICT"_MASK.tif"
  cp $BINARY_MASK $MASK
  gdal_edit.py -a_nodata 0 $MASK


  # ROADS
  #########################################################################

  # motorway
  STREETMOTOR=$DISTRICT"_AREA_STREET_MOTOR.tif"
  gdal_calc.py -A $STREET --A_band=1 -B $STREET --B_band=2 -C $STREET --C_band=28 -Z $MASK --outfile=$STREETMOTOR --calc='(minimum((A+B+C),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # primary roads
  STREETPRIMARY=$DISTRICT"_AREA_STREET_PRIMARY.tif"
  gdal_calc.py -A $STREET --A_band=3 -B $STREET --B_band=4 -C $STREET --C_band=5 -D $STREET --D_band=6 -Z $MASK --outfile=$STREETPRIMARY --calc='(minimum((A+B+C+D),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null
  
  # secondary roads
  STREETSECONDARY=$DISTRICT"_AREA_STREET_SECONDARY.tif"
  gdal_calc.py -A $STREET --A_band=7 -B $STREET --B_band=8 -Z $MASK --outfile=$STREETSECONDARY --calc='(minimum((A+B),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # tertiary roads
  STREETTERTIARY=$DISTRICT"_AREA_STREET_TERTIARY.tif"
  gdal_calc.py -A $STREET --A_band=9 -B $STREET --B_band=10 -C $STREET --C_band=11 -D $STREET --D_band=12 -E $STREET --E_band=13 -Z $MASK --outfile=$STREETTERTIARY --calc='(minimum((A+B+C+D+E),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # other roads
  STREETOTHER=$DISTRICT"_AREA_STREET_OTHER.tif"
  gdal_calc.py -A $STREET --A_band=14 -B $STREET --B_band=15 -C $STREET --C_band=22 -D $STREET --D_band=23 -E $STREET --E_band=25 -F $STREET --F_band=26 -G $STREET --G_band=29 -H $STREET --H_band=30 -I $STREET --I_band=31 -J $STREET --J_band=32 -Z $MASK --outfile=$STREETOTHER --calc='(minimum((A+B+C+D+E+F+G+H+I+J),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # gravel roads
  STREETGRAVEL=$DISTRICT"_AREA_STREET_GRAVEL.tif"
  gdal_calc.py -A $STREET --A_band=16 -B $STREET --B_band=17 -Z $MASK --outfile=$STREETGRAVEL --calc='(minimum((A+B),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # excluded streets
  STREETEXCLUDE=$DISTRICT"_AREA_STREET_EXCLUDE.tif"
  gdal_calc.py -A $STREET --A_band=18 -B $STREET --B_band=19 -C $STREET --C_band=20 -D $STREET --D_band=21 -E $STREET --E_band=24 -F $STREET --F_band=27 -Z $MASK --outfile=$STREETEXCLUDE --calc='(minimum((A+B+C+D+E+F),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # motorway on bridge (excl. bridge)
  STREETMOTORONBRIDGE=$DISTRICT"_AREA_STREET_MOTOR_ON_BRIDGE.tif"
  gdal_calc.py -A $STREET --A_band=33 -B $STREET --B_band=34 -Z $MASK --outfile=$STREETMOTORONBRIDGE --calc='(minimum((A+B),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # motorway on bridge (excl. bridge)
  STREETOTHERONBRIDGE=$DISTRICT"_AREA_STREET_OTHER_ON_BRIDGE.tif"
  gdal_calc.py -A $STREET --A_band=35 -Z $MASK --outfile=$STREETOTHERONBRIDGE --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # STREET BRIDGES / TUNNELS
  #########################################################################

  # bridge under motorway (excl. street)
  BRIDGEMOTOR=$DISTRICT"_AREA_STREET_BRIDGE_UNDER_MOTOR.tif"
  gdal_calc.py -A $STREETBRIDGE --A_band=3 -Z $MASK --outfile=$BRIDGEMOTOR --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # bridge under other streets (excl. street)
  BRIDGESTREET=$DISTRICT"_AREA_STREET_BRIDGE_UNDER_OTHER.tif"
  gdal_calc.py -A $STREETBRIDGE --A_band=1 -Z $MASK --outfile=$BRIDGESTREET --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # tunnel (excl. street)
  TUNNELSTREET=$DISTRICT"_AREA_STREET_TUNNEL.tif"
  gdal_calc.py -A $STREETBRIDGE --A_band=2 -Z $MASK --outfile=$TUNNELSTREET --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # OTHER INFRASTRUCTURE
  #########################################################################

  # airport
  OTHERRUNWAY=$DISTRICT"_AREA_RUNWAY.tif"
  gdal_calc.py -A $APRON -B $RUNWAY -C $TAXI -Z $MASK --outfile=$OTHERRUNWAY --calc='(minimum((A+B+C),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # parking lots
  OTHERPARKING=$DISTRICT"_AREA_PARKING.tif"
  gdal_calc.py -A $PARK -Z $MASK --outfile=$OTHERPARKING --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # RAILS
  #########################################################################

  # regular rails
  RAILWAY=$DISTRICT"_AREA_RAIL_RAILWAY.tif"
  gdal_calc.py -A $RAIL --A_band=1 -Z $MASK --outfile=$RAILWAY --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # tram
  RAILTRAM=$DISTRICT"_AREA_RAIL_TRAM.tif"
  gdal_calc.py -A $RAIL --A_band=4 -Z $MASK --outfile=$RAILTRAM --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # other rails
  RAILOTHER=$DISTRICT"_AREA_RAIL_OTHER.tif"
  gdal_calc.py  -A $RAIL --A_band=5 -B $RAIL --B_band=7 -C $RAIL --C_band=8 -Z $MASK --outfile=$RAILOTHER --calc='(minimum((A+B+C),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # excluded rails
  RAILEXCLUDE=$DISTRICT"_AREA_RAIL_EXCLUDE.tif"
  gdal_calc.py -A $RAIL --A_band=2 -B $RAIL --B_band=3 -C $RAIL --C_band=9 -D $RAIL --D_band=10 -Z $MASK --outfile=$RAILEXCLUDE --calc='(minimum((A+B+C+D),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # subway
  SUBWAY=$DISTRICT"_AREA_RAIL_SUBWAY.tif"
  gdal_calc.py -A $RAIL  --A_band=6 -Z $MASK --outfile=$SUBWAY --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # subway above ground, on bridge
  SUBWAYBRIDGE=$DISTRICT"_AREA_RAIL_SUBWAY_BRIDGE.tif"
  gdal_calc.py -A $RAIL  --A_band=11 -Z $MASK --outfile=$SUBWAYBRIDGE --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # subway above ground, on surface
  SUBWAYSURFACE=$DISTRICT"_AREA_RAIL_SUBWAY_SURFACE.tif"
  gdal_calc.py -A $RAIL  --A_band=12 -Z $MASK --outfile=$SUBWAYSURFACE --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # RAIL BRIDGES / TUNNELS
  #########################################################################

  # bridge (excl. rail)
  BRIDGERAIL=$DISTRICT"_AREA_RAIL_BRIDGE.tif"
  gdal_calc.py -A $RAILBRIDGE --A_band=1 -Z $MASK --outfile=$BRIDGERAIL --calc='(minimum((A),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # tunnel (excl. rail)
  TUNNELRAIL=$DISTRICT"_AREA_RAIL_TUNNEL.tif"
  gdal_calc.py -A $RAILBRIDGE --A_band=2 -B $RAIL --B_band=6 -Z $MASK --outfile=$TUNNELRAIL --calc='(minimum(maximum(A-B, 0),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # ABOVEGROUND INFRASTRUCTURE
  #########################################################################

  # sum all overground street infrastructure
  AGINF_STREET=$DISTRICT"_AREA_AG_STREET_INFRASTRUCTURE.tif"
  gdal_calc.py -A $STREETMOTOR -B $STREETPRIMARY -C $STREETSECONDARY -D $STREETTERTIARY -E $STREETOTHER -F $STREETGRAVEL -G $STREETEXCLUDE -H $STREETMOTORONBRIDGE -I $STREETOTHERONBRIDGE -J $BRIDGEMOTOR -K $BRIDGESTREET -L $TUNNELSTREET -Z $MASK --outfile=$AGINF_STREET --calc='(minimum((maximum((single(A+B+C+D+E+F+G)-L),0)+(H+I+J+K)),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # sum all overground other infrastructure
  AGINF_OTHER=$DISTRICT"_AREA_AG_OTHER_INFRASTRUCTURE.tif"
  gdal_calc.py -A $OTHERRUNWAY -B $OTHERPARKING -Z $MASK --outfile=$AGINF_OTHER --calc='(minimum((A+B),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # sum all overground rail infrastructure
  AGINF_RAIL=$DISTRICT"_AREA_AG_RAIL_INFRASTRUCTURE.tif"
  gdal_calc.py -A $RAILWAY -B $RAILTRAM -C $RAILOTHER -D $RAILEXCLUDE -E $SUBWAYBRIDGE -F $SUBWAYSURFACE -G $BRIDGERAIL -H $TUNNELRAIL -Z $MASK --outfile=$AGINF_RAIL --calc='(minimum((maximum((single(A+B+C+D+F)-H),0)+(E+G)),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # sum all overground infrastructure to remove from built-up area
  AGINF=$DISTRICT"_AREA_AG_INFRASTRUCTURE.tif"
  gdal_calc.py -A $AGINF_STREET -B $AGINF_OTHER -C $AGINF_RAIL -Z $MASK --outfile=$AGINF --calc='(minimum((A+B+C),100)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # BUILDINGS
  #########################################################################

  # clean noise at lower builtup-fraction end
  BUILTUP=$DISTRICT"_AREA_BUILTUP.tif"
  gdal_calc.py -A $FRACTION --A_band=1 -Z $MASK --outfile=$BUILTUP --calc='(A*(A>25)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building
  BUILDING=$DISTRICT"_AREA_BUILDING.tif"
  gdal_calc.py -A $BUILTUP -B $AGINF -Z $MASK --outfile=$BUILDING --calc='(maximum(minimum((single(A)-(B*(B>0)))*0.526,100),0)*Z)' --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building height
  HEIGHT2=$DISTRICT"_HEIGHT_BUILDING.tif"
  gdal_edit.py -a_nodata 32767 $HEIGHT
  gdal_calc.py -A $BUILDING -B $HEIGHT -Z $MASK --outfile=$HEIGHT2 --calc='((single(B)*(B>0)/10)*Z)' --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null  
  gdal_edit.py -a_nodata 32767 $HEIGHT2

  # clean settlement types
  FUNCTION2=$DISTRICT"_FUNCTION_BUILDING.tif"
  gdal_edit.py -a_nodata 10000 $FUNCTION
  gdal_calc.py -A $FUNCTION -Z $MASK --outfile=$FUNCTION2 --calc="(A*(A>0)*Z)" --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null
  gdal_edit.py -a_nodata -9999 $FUNCTION

  # high-rise / multi-family threshold
  HIGH=30

  # 3 = Lightweight, 
  # 2 = Single Family, 
  # 4 & 5 = Multi Family 
  # 1 = Commercial/Industrial, 




  # building area single family, excl. garages
  AREA_SINGLE=$DISTRICT"_AREA_BUILDING_SINGLEFAMILY.tif"
  gdal_calc.py -A $BUILDING -B $FUNCTION2 -Z $MASK --outfile=$AREA_SINGLE --calc="(((A*(B==2))-(0.1*A*(B==2)))*Z)" --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building area single family garages
  AREA_GARAGE=$DISTRICT"_AREA_BUILDING_GARAGES.tif"
  gdal_calc.py -A $BUILDING -B $FUNCTION2 -Z $MASK --outfile=$AREA_GARAGE --calc="((0.1*A*(B==2))*Z)" --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building area garden houses etc
  AREA_GARDEN=$DISTRICT"_AREA_BUILDING_GARDENHOUSES.tif"
  gdal_calc.py -A $BUILDING -B $FUNCTION2 -Z $MASK --outfile=$AREA_GARDEN --calc="(A*(B==3)*Z)" --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building area lightweight, incl. SFH garages
  AREA_LIGHT=$DISTRICT"_AREA_BUILDING_LIGHTWEIGHT.tif"
  gdal_calc.py -A $AREA_GARDEN -C $AREA_GARAGE -Z $MASK --outfile=$AREA_LIGHT --calc="((A+C)*Z)" --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building area multi family
  AREA_MULTI=$DISTRICT"_AREA_BUILDING_MULTIFAMILY.tif"
  gdal_calc.py -A $BUILDING -B $FUNCTION2 -C $HEIGHT2 -Z $MASK --outfile=$AREA_MULTI --calc="(((A*(B==4)*(C<$HIGH))+(A*(B==5)*(C<$HIGH)))*Z)" --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building area high rise
  AREA_HIGH=$DISTRICT"_AREA_BUILDING_HIGHRISE.tif"
  gdal_calc.py -A $BUILDING -B $FUNCTION2 -C $HEIGHT2 -Z $MASK --outfile=$AREA_HIGH --calc="(((A*(B==4)*(C>=$HIGH))+(A*(B==5)*(C>=$HIGH)))*Z)" --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building area commercial
  AREA_COMM=$DISTRICT"_AREA_BUILDING_COMMERCIAL.tif"
  gdal_calc.py -A $BUILDING -B $FUNCTION2 -Z $MASK --outfile=$AREA_COMM --calc="(A*(B==1)*Z)" --NoDataValue=255 --type=Byte --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # building volume lightweight
  VOLUME_LIGHT=$DISTRICT"_VOLUME_BUILDING_LIGHTWEIGHT.tif"
  gdal_calc.py -A $AREA_GARDEN -G $AREA_GARAGE -H $HEIGHT2 -Z $MASK --outfile=$VOLUME_LIGHT --calc="(((A*H)+(G*2.7))*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building volume single family
  VOLUME_SINGLE=$DISTRICT"_VOLUME_BUILDING_SINGLEFAMILY.tif"
  gdal_calc.py -A $AREA_SINGLE -H $HEIGHT2 -Z $MASK --outfile=$VOLUME_SINGLE --calc="(A*H*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building volume multi family
  VOLUME_MULTI=$DISTRICT"_VOLUME_BUILDING_MULTIFAMILY.tif"
  gdal_calc.py -A $AREA_MULTI -H $HEIGHT2 -Z $MASK --outfile=$VOLUME_MULTI --calc="(A*H*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building volume high rise
  VOLUME_HIGH=$DISTRICT"_VOLUME_BUILDING_HIGHRISE.tif"
  gdal_calc.py -A $AREA_HIGH -H $HEIGHT2 -Z $MASK --outfile=$VOLUME_HIGH --calc="(A*H*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # building volume commercial
  VOLUME_COMM=$DISTRICT"_VOLUME_BUILDING_COMMERCIAL.tif"
  gdal_calc.py -A $AREA_COMM -H $HEIGHT2 -Z $MASK --outfile=$VOLUME_COMM --calc="(A*H*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # total building volume
  VOLUME=$DISTRICT"_VOLUME_BUILDING.tif"
  gdal_calc.py -A $VOLUME_LIGHT -B $VOLUME_SINGLE -C $VOLUME_MULTI -D $VOLUME_HIGH -E $VOLUME_COMM -Z $MASK --outfile=$VOLUME --calc='((A+B+C+D+E)*Z)' --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # STREET STOCKS
  #########################################################################

  # motorways
  MASS_STREET_MOTOR=(x x x x x x x x x x x x x x x)
  MASS_STREET_MOTOR_TOTAL=$DISTRICT"_MASS_STREET_MOTOR_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_MOTOR[i]=$DISTRICT"_MASS_STREET_MOTOR_${TYPE[i]}.tif"

    gdal_calc.py -A $STREETMOTOR -Z $MASK --outfile=${MASS_STREET_MOTOR[i]} --calc="(A*${MI_STREET_MOTOR[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_MOTOR[0]} -B ${MASS_STREET_MOTOR[1]} -C ${MASS_STREET_MOTOR[2]} -D ${MASS_STREET_MOTOR[3]} -E ${MASS_STREET_MOTOR[4]} -F ${MASS_STREET_MOTOR[5]} -G ${MASS_STREET_MOTOR[6]} -H ${MASS_STREET_MOTOR[7]} -I ${MASS_STREET_MOTOR[8]} -J ${MASS_STREET_MOTOR[9]} -K ${MASS_STREET_MOTOR[10]} -L ${MASS_STREET_MOTOR[11]} -M ${MASS_STREET_MOTOR[12]} -N ${MASS_STREET_MOTOR[13]} -O ${MASS_STREET_MOTOR[14]} -Z $MASK --outfile=$MASS_STREET_MOTOR_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null
  

  # primary streets
  MASS_STREET_PRIMARY=(x x x x x x x x x x x x x x x)
  MASS_STREET_PRIMARY_TOTAL=$DISTRICT"_MASS_STREET_PRIMARY_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_PRIMARY[i]=$DISTRICT"_MASS_STREET_PRIMARY_${TYPE[i]}.tif"

    gdal_calc.py -A $STREETPRIMARY -Z $MASK --outfile=${MASS_STREET_PRIMARY[i]} --calc="(A*${MI_STREET_PRIMARY[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_PRIMARY[0]} -B ${MASS_STREET_PRIMARY[1]} -C ${MASS_STREET_PRIMARY[2]} -D ${MASS_STREET_PRIMARY[3]} -E ${MASS_STREET_PRIMARY[4]} -F ${MASS_STREET_PRIMARY[5]} -G ${MASS_STREET_PRIMARY[6]} -H ${MASS_STREET_PRIMARY[7]} -I ${MASS_STREET_PRIMARY[8]} -J ${MASS_STREET_PRIMARY[9]} -K ${MASS_STREET_PRIMARY[10]} -L ${MASS_STREET_PRIMARY[11]} -M ${MASS_STREET_PRIMARY[12]} -N ${MASS_STREET_PRIMARY[13]} -O ${MASS_STREET_PRIMARY[14]} -Z $MASK --outfile=$MASS_STREET_PRIMARY_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # secondary streets
  MASS_STREET_SECONDARY=(x x x x x x x x x x x x x x x)
  MASS_STREET_SECONDARY_TOTAL=$DISTRICT"_MASS_STREET_SECONDARY_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_SECONDARY[i]=$DISTRICT"_MASS_STREET_SECONDARY_${TYPE[i]}.tif"

    gdal_calc.py -A $STREETSECONDARY -Z $MASK --outfile=${MASS_STREET_SECONDARY[i]} --calc="(A*${MI_STREET_SECONDARY[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_SECONDARY[0]} -B ${MASS_STREET_SECONDARY[1]} -C ${MASS_STREET_SECONDARY[2]} -D ${MASS_STREET_SECONDARY[3]} -E ${MASS_STREET_SECONDARY[4]} -F ${MASS_STREET_SECONDARY[5]} -G ${MASS_STREET_SECONDARY[6]} -H ${MASS_STREET_SECONDARY[7]} -I ${MASS_STREET_SECONDARY[8]} -J ${MASS_STREET_SECONDARY[9]} -K ${MASS_STREET_SECONDARY[10]} -L ${MASS_STREET_SECONDARY[11]} -M ${MASS_STREET_SECONDARY[12]} -N ${MASS_STREET_SECONDARY[13]} -O ${MASS_STREET_SECONDARY[14]} -Z $MASK --outfile=$MASS_STREET_SECONDARY_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null
  
  
  # tertiary streets
  MASS_STREET_TERTIARY=(x x x x x x x x x x x x x x x)
  MASS_STREET_TERTIARY_TOTAL=$DISTRICT"_MASS_STREET_TERTIARY_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_TERTIARY[i]=$DISTRICT"_MASS_STREET_TERTIARY_${TYPE[i]}.tif"

    gdal_calc.py -A $STREETTERTIARY -Z $MASK --outfile=${MASS_STREET_TERTIARY[i]} --calc="(A*${MI_STREET_TERTIARY[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_TERTIARY[0]} -B ${MASS_STREET_TERTIARY[1]} -C ${MASS_STREET_TERTIARY[2]} -D ${MASS_STREET_TERTIARY[3]} -E ${MASS_STREET_TERTIARY[4]} -F ${MASS_STREET_TERTIARY[5]} -G ${MASS_STREET_TERTIARY[6]} -H ${MASS_STREET_TERTIARY[7]} -I ${MASS_STREET_TERTIARY[8]} -J ${MASS_STREET_TERTIARY[9]} -K ${MASS_STREET_TERTIARY[10]} -L ${MASS_STREET_TERTIARY[11]} -M ${MASS_STREET_TERTIARY[12]} -N ${MASS_STREET_TERTIARY[13]} -O ${MASS_STREET_TERTIARY[14]} -Z $MASK --outfile=$MASS_STREET_TERTIARY_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # other streets
  MASS_STREET_OTHER=(x x x x x x x x x x x x x x x)
  MASS_STREET_OTHER_TOTAL=$DISTRICT"_MASS_STREET_OTHER_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_OTHER[i]=$DISTRICT"_MASS_STREET_OTHER_${TYPE[i]}.tif"

    gdal_calc.py -A $STREETOTHER -Z $MASK --outfile=${MASS_STREET_OTHER[i]} --calc="(A*${MI_STREET_OTHER[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_OTHER[0]} -B ${MASS_STREET_OTHER[1]} -C ${MASS_STREET_OTHER[2]} -D ${MASS_STREET_OTHER[3]} -E ${MASS_STREET_OTHER[4]} -F ${MASS_STREET_OTHER[5]} -G ${MASS_STREET_OTHER[6]} -H ${MASS_STREET_OTHER[7]} -I ${MASS_STREET_OTHER[8]} -J ${MASS_STREET_OTHER[9]} -K ${MASS_STREET_OTHER[10]} -L ${MASS_STREET_OTHER[11]} -M ${MASS_STREET_OTHER[12]} -N ${MASS_STREET_OTHER[13]} -O ${MASS_STREET_OTHER[14]} -Z $MASK --outfile=$MASS_STREET_OTHER_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # gravel streets
  MASS_STREET_GRAVEL=(x x x x x x x x x x x x x x x)
  MASS_STREET_GRAVEL_TOTAL=$DISTRICT"_MASS_STREET_GRAVEL_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_GRAVEL[i]=$DISTRICT"_MASS_STREET_GRAVEL_${TYPE[i]}.tif"

    gdal_calc.py -A $STREETGRAVEL -Z $MASK --outfile=${MASS_STREET_GRAVEL[i]} --calc="(A*${MI_STREET_GRAVEL[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_GRAVEL[0]} -B ${MASS_STREET_GRAVEL[1]} -C ${MASS_STREET_GRAVEL[2]} -D ${MASS_STREET_GRAVEL[3]} -E ${MASS_STREET_GRAVEL[4]} -F ${MASS_STREET_GRAVEL[5]} -G ${MASS_STREET_GRAVEL[6]} -H ${MASS_STREET_GRAVEL[7]} -I ${MASS_STREET_GRAVEL[8]} -J ${MASS_STREET_GRAVEL[9]} -K ${MASS_STREET_GRAVEL[10]} -L ${MASS_STREET_GRAVEL[11]} -M ${MASS_STREET_GRAVEL[12]} -N ${MASS_STREET_GRAVEL[13]} -O ${MASS_STREET_GRAVEL[14]} -Z $MASK --outfile=$MASS_STREET_GRAVEL_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # motorways on bridges
  MASS_STREET_MOTOR_ON_BRIDGE=(x x x x x x x x x x x x x x x)
  MASS_STREET_MOTOR_ON_BRIDGE_TOTAL=$DISTRICT"_MASS_STREET_MOTOR_ON_BRIDGE_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_MOTOR_ON_BRIDGE[i]=$DISTRICT"_MASS_STREET_MOTOR_ON_BRIDGE_${TYPE[i]}.tif"

    gdal_calc.py -A $STREETMOTORONBRIDGE -Z $MASK --outfile=${MASS_STREET_MOTOR_ON_BRIDGE[i]} --calc="(A*${MI_STREET_MOTOR_ON_BRIDGE[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_MOTOR_ON_BRIDGE[0]} -B ${MASS_STREET_MOTOR_ON_BRIDGE[1]} -C ${MASS_STREET_MOTOR_ON_BRIDGE[2]} -D ${MASS_STREET_MOTOR_ON_BRIDGE[3]} -E ${MASS_STREET_MOTOR_ON_BRIDGE[4]} -F ${MASS_STREET_MOTOR_ON_BRIDGE[5]} -G ${MASS_STREET_MOTOR_ON_BRIDGE[6]} -H ${MASS_STREET_MOTOR_ON_BRIDGE[7]} -I ${MASS_STREET_MOTOR_ON_BRIDGE[8]} -J ${MASS_STREET_MOTOR_ON_BRIDGE[9]} -K ${MASS_STREET_MOTOR_ON_BRIDGE[10]} -L ${MASS_STREET_MOTOR_ON_BRIDGE[11]} -M ${MASS_STREET_MOTOR_ON_BRIDGE[12]} -N ${MASS_STREET_MOTOR_ON_BRIDGE[13]} -O ${MASS_STREET_MOTOR_ON_BRIDGE[14]} -Z $MASK --outfile=$MASS_STREET_MOTOR_ON_BRIDGE_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # other streets on bridges
  MASS_STREET_OTHER_ON_BRIDGE=(x x x x x x x x x x x x x x x)
  MASS_STREET_OTHER_ON_BRIDGE_TOTAL=$DISTRICT"_MASS_STREET_OTHER_ON_BRIDGE_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_OTHER_ON_BRIDGE[i]=$DISTRICT"_MASS_STREET_OTHER_ON_BRIDGE_${TYPE[i]}.tif"

    gdal_calc.py -A $STREETOTHERONBRIDGE -Z $MASK --outfile=${MASS_STREET_OTHER_ON_BRIDGE[i]} --calc="(A*${MI_STREET_OTHER_ON_BRIDGE[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_OTHER_ON_BRIDGE[0]} -B ${MASS_STREET_OTHER_ON_BRIDGE[1]} -C ${MASS_STREET_OTHER_ON_BRIDGE[2]} -D ${MASS_STREET_OTHER_ON_BRIDGE[3]} -E ${MASS_STREET_OTHER_ON_BRIDGE[4]} -F ${MASS_STREET_OTHER_ON_BRIDGE[5]} -G ${MASS_STREET_OTHER_ON_BRIDGE[6]} -H ${MASS_STREET_OTHER_ON_BRIDGE[7]} -I ${MASS_STREET_OTHER_ON_BRIDGE[8]} -J ${MASS_STREET_OTHER_ON_BRIDGE[9]} -K ${MASS_STREET_OTHER_ON_BRIDGE[10]} -L ${MASS_STREET_OTHER_ON_BRIDGE[11]} -M ${MASS_STREET_OTHER_ON_BRIDGE[12]} -N ${MASS_STREET_OTHER_ON_BRIDGE[13]} -O ${MASS_STREET_OTHER_ON_BRIDGE[14]} -Z $MASK --outfile=$MASS_STREET_OTHER_ON_BRIDGE_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # motorway bridges
  MASS_STREET_BRIDGE_UNDER_MOTOR=(x x x x x x x x x x x x x x x)
  MASS_STREET_BRIDGE_UNDER_MOTOR_TOTAL=$DISTRICT"_MASS_STREET_BRIDGE_UNDER_MOTOR_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_BRIDGE_UNDER_MOTOR[i]=$DISTRICT"_MASS_STREET_BRIDGE_UNDER_MOTOR_${TYPE[i]}.tif"

    gdal_calc.py -A $BRIDGEMOTOR -Z $MASK --outfile=${MASS_STREET_BRIDGE_UNDER_MOTOR[i]} --calc="(A*${MI_STREET_BRIDGE_UNDER_MOTOR[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_BRIDGE_UNDER_MOTOR[0]} -B ${MASS_STREET_BRIDGE_UNDER_MOTOR[1]} -C ${MASS_STREET_BRIDGE_UNDER_MOTOR[2]} -D ${MASS_STREET_BRIDGE_UNDER_MOTOR[3]} -E ${MASS_STREET_BRIDGE_UNDER_MOTOR[4]} -F ${MASS_STREET_BRIDGE_UNDER_MOTOR[5]} -G ${MASS_STREET_BRIDGE_UNDER_MOTOR[6]} -H ${MASS_STREET_BRIDGE_UNDER_MOTOR[7]} -I ${MASS_STREET_BRIDGE_UNDER_MOTOR[8]} -J ${MASS_STREET_BRIDGE_UNDER_MOTOR[9]} -K ${MASS_STREET_BRIDGE_UNDER_MOTOR[10]} -L ${MASS_STREET_BRIDGE_UNDER_MOTOR[11]} -M ${MASS_STREET_BRIDGE_UNDER_MOTOR[12]} -N ${MASS_STREET_BRIDGE_UNDER_MOTOR[13]} -O ${MASS_STREET_BRIDGE_UNDER_MOTOR[14]} -Z $MASK --outfile=$MASS_STREET_BRIDGE_UNDER_MOTOR_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # other street bridges
  MASS_STREET_BRIDGE_UNDER_OTHER=(x x x x x x x x x x x x x x x)
  MASS_STREET_BRIDGE_UNDER_OTHER_TOTAL=$DISTRICT"_MASS_STREET_BRIDGE_UNDER_OTHER_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_BRIDGE_UNDER_OTHER[i]=$DISTRICT"_MASS_STREET_BRIDGE_UNDER_OTHER_${TYPE[i]}.tif"

    gdal_calc.py -A $BRIDGESTREET -Z $MASK --outfile=${MASS_STREET_BRIDGE_UNDER_OTHER[i]} --calc="(A*${MI_STREET_BRIDGE_UNDER_OTHER[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_BRIDGE_UNDER_OTHER[0]} -B ${MASS_STREET_BRIDGE_UNDER_OTHER[1]} -C ${MASS_STREET_BRIDGE_UNDER_OTHER[2]} -D ${MASS_STREET_BRIDGE_UNDER_OTHER[3]} -E ${MASS_STREET_BRIDGE_UNDER_OTHER[4]} -F ${MASS_STREET_BRIDGE_UNDER_OTHER[5]} -G ${MASS_STREET_BRIDGE_UNDER_OTHER[6]} -H ${MASS_STREET_BRIDGE_UNDER_OTHER[7]} -I ${MASS_STREET_BRIDGE_UNDER_OTHER[8]} -J ${MASS_STREET_BRIDGE_UNDER_OTHER[9]} -K ${MASS_STREET_BRIDGE_UNDER_OTHER[10]} -L ${MASS_STREET_BRIDGE_UNDER_OTHER[11]} -M ${MASS_STREET_BRIDGE_UNDER_OTHER[12]} -N ${MASS_STREET_BRIDGE_UNDER_OTHER[13]} -O ${MASS_STREET_BRIDGE_UNDER_OTHER[14]} -Z $MASK --outfile=$MASS_STREET_BRIDGE_UNDER_OTHER_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null
  
  
  # street tunnels
  MASS_STREET_TUNNEL=(x x x x x x x x x x x x x x x)
  MASS_STREET_TUNNEL_TOTAL=$DISTRICT"_MASS_STREET_TUNNEL_TOTAL.tif"

  for i in {0..14}; do

    MASS_STREET_TUNNEL[i]=$DISTRICT"_MASS_STREET_TUNNEL_${TYPE[i]}.tif"

    gdal_calc.py -A $TUNNELSTREET -Z $MASK --outfile=${MASS_STREET_TUNNEL[i]} --calc="(A*${MI_STREET_TUNNEL[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_STREET_TUNNEL[0]} -B ${MASS_STREET_TUNNEL[1]} -C ${MASS_STREET_TUNNEL[2]} -D ${MASS_STREET_TUNNEL[3]} -E ${MASS_STREET_TUNNEL[4]} -F ${MASS_STREET_TUNNEL[5]} -G ${MASS_STREET_TUNNEL[6]} -H ${MASS_STREET_TUNNEL[7]} -I ${MASS_STREET_TUNNEL[8]} -J ${MASS_STREET_TUNNEL[9]} -K ${MASS_STREET_TUNNEL[10]} -L ${MASS_STREET_TUNNEL[11]} -M ${MASS_STREET_TUNNEL[12]} -N ${MASS_STREET_TUNNEL[13]} -O ${MASS_STREET_TUNNEL[14]} -Z $MASK --outfile=$MASS_STREET_TUNNEL_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # total mass of streets
  MASS_STREET_TOTAL=$DISTRICT"_MASS_STREET_TOTAL.tif"
  gdal_calc.py -A $MASS_STREET_MOTOR_TOTAL -B $MASS_STREET_PRIMARY_TOTAL -C $MASS_STREET_SECONDARY_TOTAL -D $MASS_STREET_TERTIARY_TOTAL -E $MASS_STREET_OTHER_TOTAL -F $MASS_STREET_GRAVEL_TOTAL -G $MASS_STREET_MOTOR_ON_BRIDGE_TOTAL -H $MASS_STREET_OTHER_ON_BRIDGE_TOTAL -I $MASS_STREET_BRIDGE_UNDER_MOTOR_TOTAL -J $MASS_STREET_BRIDGE_UNDER_OTHER_TOTAL -K $MASS_STREET_TUNNEL_TOTAL -Z $MASK --outfile=$MASS_STREET_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # OTHER INFRASTRUCTURE STOCKS
  #########################################################################

  # runways
  MASS_RUNWAY=(x x x x x x x x x x x x x x x)
  MASS_RUNWAY_TOTAL=$DISTRICT"_MASS_RUNWAY_TOTAL.tif"

  for i in {0..14}; do

    MASS_RUNWAY[i]=$DISTRICT"_MASS_RUNWAY_${TYPE[i]}.tif"

    gdal_calc.py -A $OTHERRUNWAY -Z $MASK --outfile=${MASS_RUNWAY[i]} --calc="(A*${MI_RUNWAY[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_RUNWAY[0]} -B ${MASS_RUNWAY[1]} -C ${MASS_RUNWAY[2]} -D ${MASS_RUNWAY[3]} -E ${MASS_RUNWAY[4]} -F ${MASS_RUNWAY[5]} -G ${MASS_RUNWAY[6]} -H ${MASS_RUNWAY[7]} -I ${MASS_RUNWAY[8]} -J ${MASS_RUNWAY[9]} -K ${MASS_RUNWAY[10]} -L ${MASS_RUNWAY[11]} -M ${MASS_RUNWAY[12]} -N ${MASS_RUNWAY[13]} -O ${MASS_RUNWAY[14]} -Z $MASK --outfile=$MASS_RUNWAY_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null
  
  
  # parking lots
  MASS_PARKING=(x x x x x x x x x x x x x x x)
  MASS_PARKING_TOTAL=$DISTRICT"_MASS_PARKING_TOTAL.tif"

  for i in {0..14}; do

    MASS_PARKING[i]=$DISTRICT"_MASS_PARKING_${TYPE[i]}.tif"

    gdal_calc.py -A $OTHERPARKING -Z $MASK --outfile=${MASS_PARKING[i]} --calc="(A*${MI_PARKING[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_PARKING[0]} -B ${MASS_PARKING[1]} -C ${MASS_PARKING[2]} -D ${MASS_PARKING[3]} -E ${MASS_PARKING[4]} -F ${MASS_PARKING[5]} -G ${MASS_PARKING[6]} -H ${MASS_PARKING[7]} -I ${MASS_PARKING[8]} -J ${MASS_PARKING[9]} -K ${MASS_PARKING[10]} -L ${MASS_PARKING[11]} -M ${MASS_PARKING[12]} -N ${MASS_PARKING[13]} -O ${MASS_PARKING[14]} -Z $MASK --outfile=$MASS_PARKING_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # total mass of other infrastructure
  MASS_OTHER_TOTAL=$DISTRICT"_MASS_OTHER_TOTAL.tif"
  gdal_calc.py -A $MASS_RUNWAY_TOTAL -B $MASS_PARKING_TOTAL -Z $MASK --outfile=$MASS_OTHER_TOTAL --calc="(A+B)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # total mass of street and other infrastructure
  MASS_STREETANDOTHER_TOTAL=$DISTRICT"_MASS_STREETANDOTHER_TOTAL.tif"
  gdal_calc.py -A $MASS_STREET_TOTAL -B $MASS_OTHER_TOTAL -Z $MASK --outfile=$MASS_STREETANDOTHER_TOTAL --calc="(A+B)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # RAIL STOCKS
  #########################################################################

  # regular rails
  MASS_RAIL_RAILWAY=(x x x x x x x x x x x x x x x)
  MASS_RAIL_RAILWAY_TOTAL=$DISTRICT"_MASS_RAIL_RAILWAY_TOTAL.tif"

  for i in {0..14}; do

    MASS_RAIL_RAILWAY[i]=$DISTRICT"_MASS_RAIL_RAILWAY_${TYPE[i]}.tif"

   gdal_calc.py -A $RAILWAY -Z $MASK --outfile=${MASS_RAIL_RAILWAY[i]} --calc="(A*${MI_RAIL_RAILWAY[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

 gdal_calc.py -A ${MASS_RAIL_RAILWAY[0]} -B ${MASS_RAIL_RAILWAY[1]} -C ${MASS_RAIL_RAILWAY[2]} -D ${MASS_RAIL_RAILWAY[3]} -E ${MASS_RAIL_RAILWAY[4]} -F ${MASS_RAIL_RAILWAY[5]} -G ${MASS_RAIL_RAILWAY[6]} -H ${MASS_RAIL_RAILWAY[7]} -I ${MASS_RAIL_RAILWAY[8]} -J ${MASS_RAIL_RAILWAY[9]} -K ${MASS_RAIL_RAILWAY[10]} -L ${MASS_RAIL_RAILWAY[11]} -M ${MASS_RAIL_RAILWAY[12]} -N ${MASS_RAIL_RAILWAY[13]} -O ${MASS_RAIL_RAILWAY[14]} -Z $MASK --outfile=$MASS_RAIL_RAILWAY_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # tram
  MASS_RAIL_TRAM=(x x x x x x x x x x x x x x x)
  MASS_RAIL_TRAM_TOTAL=$DISTRICT"_MASS_RAIL_TRAM_TOTAL.tif"

  for i in {0..14}; do

    MASS_RAIL_TRAM[i]=$DISTRICT"_MASS_RAIL_TRAM_${TYPE[i]}.tif"

    gdal_calc.py -A $RAILTRAM -Z $MASK --outfile=${MASS_RAIL_TRAM[i]} --calc="(A*${MI_RAIL_TRAM[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_RAIL_TRAM[0]} -B ${MASS_RAIL_TRAM[1]} -C ${MASS_RAIL_TRAM[2]} -D ${MASS_RAIL_TRAM[3]} -E ${MASS_RAIL_TRAM[4]} -F ${MASS_RAIL_TRAM[5]} -G ${MASS_RAIL_TRAM[6]} -H ${MASS_RAIL_TRAM[7]} -I ${MASS_RAIL_TRAM[8]} -J ${MASS_RAIL_TRAM[9]} -K ${MASS_RAIL_TRAM[10]} -L ${MASS_RAIL_TRAM[11]} -M ${MASS_RAIL_TRAM[12]} -N ${MASS_RAIL_TRAM[13]} -O ${MASS_RAIL_TRAM[14]} -Z $MASK --outfile=$MASS_RAIL_TRAM_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # subway (underground)
  MASS_RAIL_SUBWAY=(x x x x x x x x x x x x x x x)
  MASS_RAIL_SUBWAY_TOTAL=$DISTRICT"_MASS_RAIL_SUBWAY_TOTAL.tif"

  for i in {0..14}; do

    MASS_RAIL_SUBWAY[i]=$DISTRICT"_MASS_RAIL_SUBWAY_${TYPE[i]}.tif"

    gdal_calc.py -A $SUBWAY -Z $MASK --outfile=${MASS_RAIL_SUBWAY[i]} --calc="(A*${MI_RAIL_SUBWAY[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_RAIL_SUBWAY[0]} -B ${MASS_RAIL_SUBWAY[1]} -C ${MASS_RAIL_SUBWAY[2]} -D ${MASS_RAIL_SUBWAY[3]} -E ${MASS_RAIL_SUBWAY[4]} -F ${MASS_RAIL_SUBWAY[5]} -G ${MASS_RAIL_SUBWAY[6]} -H ${MASS_RAIL_SUBWAY[7]} -I ${MASS_RAIL_SUBWAY[8]} -J ${MASS_RAIL_SUBWAY[9]} -K ${MASS_RAIL_SUBWAY[10]} -L ${MASS_RAIL_SUBWAY[11]} -M ${MASS_RAIL_SUBWAY[12]} -N ${MASS_RAIL_SUBWAY[13]} -O ${MASS_RAIL_SUBWAY[14]} -Z $MASK --outfile=$MASS_RAIL_SUBWAY_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # subway (AG on bridge)
  MASS_RAIL_SUBWAY_BRIDGE=(x x x x x x x x x x x x x x x)
  MASS_RAIL_SUBWAY_BRIDGE_TOTAL=$DISTRICT"_MASS_RAIL_SUBWAY_BRIDGE_TOTAL.tif"

  for i in {0..14}; do

    MASS_RAIL_SUBWAY_BRIDGE[i]=$DISTRICT"_MASS_RAIL_SUBWAY_BRIDGE_${TYPE[i]}.tif"

    gdal_calc.py -A $SUBWAYBRIDGE -Z $MASK --outfile=${MASS_RAIL_SUBWAY_BRIDGE[i]} --calc="(A*${MI_RAIL_SUBWAY_AG_BRIDGE[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_RAIL_SUBWAY_BRIDGE[0]} -B ${MASS_RAIL_SUBWAY_BRIDGE[1]} -C ${MASS_RAIL_SUBWAY_BRIDGE[2]} -D ${MASS_RAIL_SUBWAY_BRIDGE[3]} -E ${MASS_RAIL_SUBWAY_BRIDGE[4]} -F ${MASS_RAIL_SUBWAY_BRIDGE[5]} -G ${MASS_RAIL_SUBWAY_BRIDGE[6]} -H ${MASS_RAIL_SUBWAY_BRIDGE[7]} -I ${MASS_RAIL_SUBWAY_BRIDGE[8]} -J ${MASS_RAIL_SUBWAY_BRIDGE[9]} -K ${MASS_RAIL_SUBWAY_BRIDGE[10]} -L ${MASS_RAIL_SUBWAY_BRIDGE[11]} -M ${MASS_RAIL_SUBWAY_BRIDGE[12]} -N ${MASS_RAIL_SUBWAY_BRIDGE[13]} -O ${MASS_RAIL_SUBWAY_BRIDGE[14]} -Z $MASK --outfile=$MASS_RAIL_SUBWAY_BRIDGE_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # subway (AG on surface)
  MASS_RAIL_SUBWAY_SURFACE=(x x x x x x x x x x x x x x x)
  MASS_RAIL_SUBWAY_SURFACE_TOTAL=$DISTRICT"_MASS_RAIL_SUBWAY_SURFACE_TOTAL.tif"

  for i in {0..14}; do

    MASS_RAIL_SUBWAY_SURFACE[i]=$DISTRICT"_MASS_RAIL_SUBWAY_SURFACE_${TYPE[i]}.tif"

    gdal_calc.py -A $SUBWAYSURFACE -Z $MASK --outfile=${MASS_RAIL_SUBWAY_SURFACE[i]} --calc="(A*${MI_RAIL_SUBWAY_AG_SURFACE[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_RAIL_SUBWAY_SURFACE[0]} -B ${MASS_RAIL_SUBWAY_SURFACE[1]} -C ${MASS_RAIL_SUBWAY_SURFACE[2]} -D ${MASS_RAIL_SUBWAY_SURFACE[3]} -E ${MASS_RAIL_SUBWAY_SURFACE[4]} -F ${MASS_RAIL_SUBWAY_SURFACE[5]} -G ${MASS_RAIL_SUBWAY_SURFACE[6]} -H ${MASS_RAIL_SUBWAY_SURFACE[7]} -I ${MASS_RAIL_SUBWAY_SURFACE[8]} -J ${MASS_RAIL_SUBWAY_SURFACE[9]} -K ${MASS_RAIL_SUBWAY_SURFACE[10]} -L ${MASS_RAIL_SUBWAY_SURFACE[11]} -M ${MASS_RAIL_SUBWAY_SURFACE[12]} -N ${MASS_RAIL_SUBWAY_SURFACE[13]} -O ${MASS_RAIL_SUBWAY_SURFACE[14]} -Z $MASK --outfile=$MASS_RAIL_SUBWAY_SURFACE_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # other rails
  MASS_RAIL_OTHER=(x x x x x x x x x x x x x x x)
  MASS_RAIL_OTHER_TOTAL=$DISTRICT"_MASS_RAIL_OTHER_TOTAL.tif"

  for i in {0..14}; do

    MASS_RAIL_OTHER[i]=$DISTRICT"_MASS_RAIL_OTHER_${TYPE[i]}.tif"

    gdal_calc.py -A $RAILOTHER -Z $MASK --outfile=${MASS_RAIL_OTHER[i]} --calc="(A*${MI_RAIL_OTHER[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_RAIL_OTHER[0]} -B ${MASS_RAIL_OTHER[1]} -C ${MASS_RAIL_OTHER[2]} -D ${MASS_RAIL_OTHER[3]} -E ${MASS_RAIL_OTHER[4]} -F ${MASS_RAIL_OTHER[5]} -G ${MASS_RAIL_OTHER[6]} -H ${MASS_RAIL_OTHER[7]} -I ${MASS_RAIL_OTHER[8]} -J ${MASS_RAIL_OTHER[9]} -K ${MASS_RAIL_OTHER[10]} -L ${MASS_RAIL_OTHER[11]} -M ${MASS_RAIL_OTHER[12]} -N ${MASS_RAIL_OTHER[13]} -O ${MASS_RAIL_OTHER[14]} -Z $MASK --outfile=$MASS_RAIL_OTHER_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # rail bridges
  MASS_RAIL_BRIDGE=(x x x x x x x x x x x x x x x)
  MASS_RAIL_BRIDGE_TOTAL=$DISTRICT"_MASS_RAIL_BRIDGE_TOTAL.tif"

  for i in {0..14}; do

    MASS_RAIL_BRIDGE[i]=$DISTRICT"_MASS_RAIL_BRIDGE_${TYPE[i]}.tif"

    gdal_calc.py -A $BRIDGERAIL -Z $MASK --outfile=${MASS_RAIL_BRIDGE[i]} --calc="(A*${MI_RAIL_BRIDGE[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_RAIL_BRIDGE[0]} -B ${MASS_RAIL_BRIDGE[1]} -C ${MASS_RAIL_BRIDGE[2]} -D ${MASS_RAIL_BRIDGE[3]} -E ${MASS_RAIL_BRIDGE[4]} -F ${MASS_RAIL_BRIDGE[5]} -G ${MASS_RAIL_BRIDGE[6]} -H ${MASS_RAIL_BRIDGE[7]} -I ${MASS_RAIL_BRIDGE[8]} -J ${MASS_RAIL_BRIDGE[9]} -K ${MASS_RAIL_BRIDGE[10]} -L ${MASS_RAIL_BRIDGE[11]} -M ${MASS_RAIL_BRIDGE[12]} -N ${MASS_RAIL_BRIDGE[13]} -O ${MASS_RAIL_BRIDGE[14]} -Z $MASK --outfile=$MASS_RAIL_BRIDGE_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # rail tunnels
  MASS_RAIL_TUNNEL=(x x x x x x x x x x x x x x x)
  MASS_RAIL_TUNNEL_TOTAL=$DISTRICT"_MASS_RAIL_TUNNEL_TOTAL.tif"

  for i in {0..14}; do

    MASS_RAIL_TUNNEL[i]=$DISTRICT"_MASS_RAIL_TUNNEL_${TYPE[i]}.tif"

    gdal_calc.py -A $TUNNELRAIL -Z $MASK --outfile=${MASS_RAIL_TUNNEL[i]} --calc="(A*${MI_RAIL_TUNNEL[i]}*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_RAIL_TUNNEL[0]} -B ${MASS_RAIL_TUNNEL[1]} -C ${MASS_RAIL_TUNNEL[2]} -D ${MASS_RAIL_TUNNEL[3]} -E ${MASS_RAIL_TUNNEL[4]} -F ${MASS_RAIL_TUNNEL[5]} -G ${MASS_RAIL_TUNNEL[6]} -H ${MASS_RAIL_TUNNEL[7]} -I ${MASS_RAIL_TUNNEL[8]} -J ${MASS_RAIL_TUNNEL[9]} -K ${MASS_RAIL_TUNNEL[10]} -L ${MASS_RAIL_TUNNEL[11]} -M ${MASS_RAIL_TUNNEL[12]} -N ${MASS_RAIL_TUNNEL[13]} -O ${MASS_RAIL_TUNNEL[14]} -Z $MASK --outfile=$MASS_RAIL_TUNNEL_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # total mass of rails
  MASS_RAIL_TOTAL=$DISTRICT"_MASS_RAIL_TOTAL.tif"
  gdal_calc.py -A $MASS_RAIL_RAILWAY_TOTAL -B $MASS_RAIL_TRAM_TOTAL -C $MASS_RAIL_SUBWAY_TOTAL -D $MASS_RAIL_SUBWAY_BRIDGE_TOTAL -E $MASS_RAIL_SUBWAY_SURFACE_TOTAL -F $MASS_RAIL_OTHER_TOTAL -G $MASS_RAIL_BRIDGE_TOTAL -H $MASS_RAIL_TUNNEL_TOTAL -Z $MASK --outfile=$MASS_RAIL_TOTAL --calc="(A+B+C+D+E+F+G+H)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # BUILDING STOCKS
  #########################################################################

  # lightweight buildings
  MASS_BUILDING_LIGHT=(x x x x x x x x x x x x x x x)
  MASS_BUILDING_LIGHT_TOTAL=$DISTRICT"_MASS_BUILDING_LIGHTWEIGHT_TOTAL.tif"

  for i in {0..14}; do

    MASS_BUILDING_LIGHT[i]=$DISTRICT"_MASS_BUILDING_LIGHTWEIGHT_${TYPE[i]}.tif"

    gdal_calc.py -A $VOLUME_LIGHT -Z $MASK --outfile=${MASS_BUILDING_LIGHT[i]} --calc="((A*${MI_BUILDING_LIGHT[i]})*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_BUILDING_LIGHT[0]} -B ${MASS_BUILDING_LIGHT[1]} -C ${MASS_BUILDING_LIGHT[2]} -D ${MASS_BUILDING_LIGHT[3]} -E ${MASS_BUILDING_LIGHT[4]} -F ${MASS_BUILDING_LIGHT[5]} -G ${MASS_BUILDING_LIGHT[6]} -H ${MASS_BUILDING_LIGHT[7]} -I ${MASS_BUILDING_LIGHT[8]} -J ${MASS_BUILDING_LIGHT[9]} -K ${MASS_BUILDING_LIGHT[10]} -L ${MASS_BUILDING_LIGHT[11]} -M ${MASS_BUILDING_LIGHT[12]} -N ${MASS_BUILDING_LIGHT[13]} -O ${MASS_BUILDING_LIGHT[14]} -Z $MASK --outfile=$MASS_BUILDING_LIGHT_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # single family buildings
  MASS_BUILDING_SINGLE=(x x x x x x x x x x x x x x x)
  MASS_BUILDING_SINGLE_TOTAL=$DISTRICT"_MASS_BUILDING_SINGLEFAMILY_TOTAL.tif"

  for i in {0..14}; do

    MASS_BUILDING_SINGLE[i]=$DISTRICT"_MASS_BUILDING_SINGLEFAMILY_${TYPE[i]}.tif"

    gdal_calc.py -A $VOLUME_SINGLE -Z $MASK --outfile=${MASS_BUILDING_SINGLE[i]} --calc="((A*${MI_BUILDING_SINGLE[i]})*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_BUILDING_SINGLE[0]} -B ${MASS_BUILDING_SINGLE[1]} -C ${MASS_BUILDING_SINGLE[2]} -D ${MASS_BUILDING_SINGLE[3]} -E ${MASS_BUILDING_SINGLE[4]} -F ${MASS_BUILDING_SINGLE[5]} -G ${MASS_BUILDING_SINGLE[6]} -H ${MASS_BUILDING_SINGLE[7]} -I ${MASS_BUILDING_SINGLE[8]} -J ${MASS_BUILDING_SINGLE[9]} -K ${MASS_BUILDING_SINGLE[10]} -L ${MASS_BUILDING_SINGLE[11]} -M ${MASS_BUILDING_SINGLE[12]} -N ${MASS_BUILDING_SINGLE[13]} -O ${MASS_BUILDING_SINGLE[14]} -Z $MASK --outfile=$MASS_BUILDING_SINGLE_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # multi family buildings
  MASS_BUILDING_MULTI=(x x x x x x x x x x x x x x x)
  MASS_BUILDING_MULTI_TOTAL=$DISTRICT"_MASS_BUILDING_MULTIFAMILY_TOTAL.tif"
  
  for i in {0..14}; do

    MASS_BUILDING_MULTI[i]=$DISTRICT"_MASS_BUILDING_MULTIFAMILY_${TYPE[i]}.tif"

    gdal_calc.py -A $VOLUME_MULTI -C $HEIGHT2 -Z $MASK --outfile=${MASS_BUILDING_MULTI[i]} --calc="((A*${MI_BUILDING_MULTI[i]})*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_BUILDING_MULTI[0]} -B ${MASS_BUILDING_MULTI[1]} -C ${MASS_BUILDING_MULTI[2]} -D ${MASS_BUILDING_MULTI[3]} -E ${MASS_BUILDING_MULTI[4]} -F ${MASS_BUILDING_MULTI[5]} -G ${MASS_BUILDING_MULTI[6]} -H ${MASS_BUILDING_MULTI[7]} -I ${MASS_BUILDING_MULTI[8]} -J ${MASS_BUILDING_MULTI[9]} -K ${MASS_BUILDING_MULTI[10]} -L ${MASS_BUILDING_MULTI[11]} -M ${MASS_BUILDING_MULTI[12]} -N ${MASS_BUILDING_MULTI[13]} -O ${MASS_BUILDING_MULTI[14]} -Z $MASK --outfile=$MASS_BUILDING_MULTI_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # high rise buildings
  MASS_BUILDING_HIGH=(x x x x x x x x x x x x x x x)
  MASS_BUILDING_HIGH_TOTAL=$DISTRICT"_MASS_BUILDING_HIGHRISE_TOTAL.tif"
  
  for i in {0..14}; do

    MASS_BUILDING_HIGH[i]=$DISTRICT"_MASS_BUILDING_HIGHRISE_${TYPE[i]}.tif"

    gdal_calc.py -A $VOLUME_HIGH -C $HEIGHT2 -Z $MASK --outfile=${MASS_BUILDING_HIGH[i]} --calc="((A*${MI_BUILDING_HIGH[i]})*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_BUILDING_HIGH[0]} -B ${MASS_BUILDING_HIGH[1]} -C ${MASS_BUILDING_HIGH[2]} -D ${MASS_BUILDING_HIGH[3]} -E ${MASS_BUILDING_HIGH[4]} -F ${MASS_BUILDING_HIGH[5]} -G ${MASS_BUILDING_HIGH[6]} -H ${MASS_BUILDING_HIGH[7]} -I ${MASS_BUILDING_HIGH[8]} -J ${MASS_BUILDING_HIGH[9]} -K ${MASS_BUILDING_HIGH[10]} -L ${MASS_BUILDING_HIGH[11]} -M ${MASS_BUILDING_HIGH[12]} -N ${MASS_BUILDING_HIGH[13]} -O ${MASS_BUILDING_HIGH[14]} -Z $MASK --outfile=$MASS_BUILDING_HIGH_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # commercial buildings
  MASS_BUILDING_COMM=(x x x x x x x x x x x x x x x)
  MASS_BUILDING_COMM_TOTAL=$DISTRICT"_MASS_BUILDING_COMMERCIAL_TOTAL.tif"

  for i in {0..14}; do

    MASS_BUILDING_COMM[i]=$DISTRICT"_MASS_BUILDING_COMMERCIAL_${TYPE[i]}.tif"

    gdal_calc.py -A $VOLUME_COMM -Z $MASK --outfile=${MASS_BUILDING_COMM[i]} --calc="((A*${MI_BUILDING_COMM[i]})*Z)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  done

  gdal_calc.py -A ${MASS_BUILDING_COMM[0]} -B ${MASS_BUILDING_COMM[1]} -C ${MASS_BUILDING_COMM[2]} -D ${MASS_BUILDING_COMM[3]} -E ${MASS_BUILDING_COMM[4]} -F ${MASS_BUILDING_COMM[5]} -G ${MASS_BUILDING_COMM[6]} -H ${MASS_BUILDING_COMM[7]} -I ${MASS_BUILDING_COMM[8]} -J ${MASS_BUILDING_COMM[9]} -K ${MASS_BUILDING_COMM[10]} -L ${MASS_BUILDING_COMM[11]} -M ${MASS_BUILDING_COMM[12]} -N ${MASS_BUILDING_COMM[13]} -O ${MASS_BUILDING_COMM[14]} -Z $MASK --outfile=$MASS_BUILDING_COMM_TOTAL --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # total mass of buildings
  MASS_BUILDING_TOTAL=$DISTRICT"_MASS_BUILDING_TOTAL.tif"
  gdal_calc.py -A $MASS_BUILDING_SINGLE_TOTAL -B $MASS_BUILDING_MULTI_TOTAL -C $MASS_BUILDING_HIGH_TOTAL -D $MASS_BUILDING_COMM_TOTAL -E $MASS_BUILDING_LIGHT_TOTAL -Z $MASK --outfile=$MASS_BUILDING_TOTAL --calc="(A+B+C+D+E)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # total mass of lightweight and single-family buildings
  MASS_BUILDING_LIGHTSINGLE_TOTAL=$DISTRICT"_MASS_BUILDING_LIGHTWEIGHTSINGLEFAMILY_TOTAL.tif"
  gdal_calc.py -A $MASS_BUILDING_SINGLE_TOTAL -E $MASS_BUILDING_LIGHT_TOTAL -Z $MASK --outfile=$MASS_BUILDING_LIGHTSINGLE_TOTAL --calc="(A+E)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # total mass of multi-family and high-rise buildings
  MASS_BUILDING_MULTIHIGH_TOTAL=$DISTRICT"_MASS_BUILDING_MULTIFAMILYHIGHRISE_TOTAL.tif"
  gdal_calc.py -B $MASS_BUILDING_MULTI_TOTAL -C $MASS_BUILDING_HIGH_TOTAL -Z $MASK --outfile=$MASS_BUILDING_MULTIHIGH_TOTAL --calc="(B+C)" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null


  # TOTAL STOCK
  #########################################################################

  # total mass of all stocks
  MASS_STOCK_TOTAL=$DISTRICT"_MASS_TOTAL_10m_t.tif"
  gdal_calc.py -A $MASS_STREET_TOTAL -B $MASS_RAIL_TOTAL -C $MASS_OTHER_TOTAL -D $MASS_BUILDING_TOTAL -Z $MASK --outfile=$MASS_STOCK_TOTAL --calc="A+B+C+D" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=3000 --creation-option=BLOCKYSIZE=300 --overwrite &> /dev/null

  # nodata-removed mass of all stocks @10m
  TEMP10=temp_10m.dat
  gdal_edit.py -a_nodata 32767 $MASS_STOCK_TOTAL
  gdal_calc.py -A $MASS_STOCK_TOTAL --outfile=$TEMP10 --calc="A*(A>0)" --NoDataValue=-9999 --type=Float32 --format=ENVI &> /dev/null
  gdal_edit.py -a_nodata -9999 $MASS_STOCK_TOTAL

  # total mass of all stocks @100m
  TEMP100=temp_100m.dat
  gdal_translate -ot Float32 -of ENVI -tr 100 100 -r average $TEMP10 $TEMP100 &> /dev/null

  MASS_STOCK_TOTAL_100=$DISTRICT"_MASS_TOTAL_100m_kt.tif"
  gdal_calc.py -A $TEMP100 --outfile=$MASS_STOCK_TOTAL_100 --calc="A*100/1000" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=300 --creation-option=BLOCKYSIZE=30 --overwrite &> /dev/null

  # total mass of all stocks @1000m
  TEMP1000=temp_1000m.dat
  gdal_translate -ot Float32 -of ENVI -tr 1000 1000 -r average $TEMP100 $TEMP1000 &> /dev/null

  MASS_STOCK_TOTAL_1000=$DISTRICT"_MASS_TOTAL_1000m_mt.tif"
  gdal_calc.py -A $TEMP1000 --outfile=$MASS_STOCK_TOTAL_1000 --calc="A*10000/1000000" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --creation-option=BLOCKXSIZE=30 --creation-option=BLOCKYSIZE=3 --overwrite &> /dev/null

  # total mass of all stocks @10000m
  TEMP10000=temp_10000m.dat
  gdal_translate -ot Float32 -of ENVI -tr 10000 10000 -r average $TEMP1000 $TEMP10000 &> /dev/null

  MASS_STOCK_TOTAL_10000=$DISTRICT"_MASS_TOTAL_10000m_gt.tif"
  gdal_calc.py -A $TEMP10000 --outfile=$MASS_STOCK_TOTAL_10000 --calc="A*1000000/1000000000" --NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option='COMPRESS=LZW' --creation-option='PREDICTOR=2' --creation-option='NUM_THREADS=ALL_CPUS' --creation-option='BIGTIFF=YES' --overwrite &> /dev/null


  rm temp_1*

  exit

}

export -f stock


function sum_(){

  IMAGE=$1

  NODATA=$(gdalinfo $IMAGE | grep NoData | head -n 1 |  sed 's/ //g' | cut -d '=' -f 2)
  
  imgsum $IMAGE $NODATA

  exit

}

export -f sum_


EXPECTED_ARGS=3

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: country(DEU/AUT/..) district(DE_BE/DE_RP/..) njobs"
  exit
fi

COUNTRY=$1
DISTRICT=$2
NJOB=$3

BASE=/data/Jakku/mat_stocks

export BASE=$BASE
export COUNTRY=$COUNTRY
export DISTRICT=$DISTRICT


echo "Computing Stock:"
parallel -a $BASE/tiles/$DISTRICT.txt -j $NJOB --eta stock {}
#stock X0069_Y0043
exit
echo "Computing Virtual Mosaics:"
cd $BASE"/stock/"$COUNTRY"/"$DISTRICT
force-mosaic . #&> /dev/null

cd mosaic

echo "Computing Sum:"
ls *.vrt | parallel -j $NJOB --eta "sum_ {} > {.}.txt"

echo "Computing Pyramids:"
ls *.vrt | parallel -j $NJOB --eta force-pyramid {}

