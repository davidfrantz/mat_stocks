#!/usr/bin/env nextflow

// enable modules
nextflow.enable.dsl=2


/**-----------------------------------------------------------------------
--- PARAMETERS, PATHS, OPTIONS AND THRESHOLDS ----------------------------
-----------------------------------------------------------------------**/

// country
params.country      = "UGA"
params.country_code = "UG"

// project directory
params.dir_project = "/data/Jakku/mat_stocks"

// directories
params.dir = [
    "tiles":      params.dir_project + "/tiles/"    + params.country,
    "mask":       params.dir_project + "/mask/"     + params.country,
    "zone":       params.dir_project + "/zone/"     + params.country,
    "osm":        params.dir_project + "/osm/"      + params.country,
    "type":       params.dir_project + "/type/"     + params.country,
    "footprint":  params.dir_project + "/building/" + params.country,
    "pub":        params.dir_project + "/stock/"    + params.country,
    "mi":         params.dir_project + "/mi/"       + params.country,
    "areacorr":   params.dir_project + "/areacorr/" + params.country
]

// raster collections
params.raster = [
    "mask":             [params.dir.mask,       "mask.tif"],
    "zone":             [params.dir.zone,       "districts.tif"],
    "street":           [params.dir.osm,        "streets.tif"],
    "street_brdtun":    [params.dir.osm,        "road-brdtun.tif"],
    "rail":             [params.dir.osm,        "railway.tif"],
    "rail_brdtun":      [params.dir.osm,        "rail-brdtun.tif"],
    "apron":            [params.dir.osm,        "apron.tif"],
    "taxi":             [params.dir.osm,        "taxiway.tif"],
    "runway":           [params.dir.osm,        "runway.tif"],
    "parking":          [params.dir.osm,        "parking.tif"],
    "footprint":        [params.dir.footprint,  "bld.tif"],
    "type":             [params.dir.type,       "BUILDING-TYPE_HL_ML_MLP.tif" ],
    "areacorr":         [params.dir.areacorr,   "true_area.tif"]
]

// MI files
params.mi = [
    "building": [params.dir.mi, "building.csv"], 
    "street":   [params.dir.mi, "street.csv"], 
    "rail":     [params.dir.mi, "rail.csv"], 
    "other":    [params.dir.mi, "other.csv"], 
]

params.class = [
    // building type classes (mapped)
    "sdr":         1, // semi-detached residential
    "dlr":         2, // dense lightweight residential housing
    "ci":          3,
    "mixed":       4,
    "traditional": 5
]

// height of ALL buildings
params.height = 4

params.threshold = [
    // area thresholds
    "area_impervious":   0,
]

// options for gdal
params.gdal = [
    "calc_opt_byte":  '--NoDataValue=255   --type=Byte    --format=GTiff --creation-option=INTERLEAVE=BAND --creation-option=COMPRESS=LZW --creation-option=PREDICTOR=2 --creation-option=BIGTIFF=YES --creation-option=TILED=YES',
    "calc_opt_int16": '--NoDataValue=-9999 --type=Int16   --format=GTiff --creation-option=INTERLEAVE=BAND --creation-option=COMPRESS=LZW --creation-option=PREDICTOR=2 --creation-option=BIGTIFF=YES --creation-option=TILED=YES',
    "calc_opt_float": '--NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option=INTERLEAVE=BAND --creation-option=COMPRESS=LZW --creation-option=PREDICTOR=2 --creation-option=BIGTIFF=YES --creation-option=TILED=YES',
    "tran_opt_float": '-a_nodata -9999 -ot Float32 -of GTiff  -co INTERLEAVE=BAND -co COMPRESS=LZW -co PREDICTOR=2 -co BIGTIFF=YES -co TILED=YES'
]


/**-----------------------------------------------------------------------
--- INCLUDE MODULES ------------------------------------------------------
-----------------------------------------------------------------------**/

include { multijoin }                       from './module/defs.nf'
include { proc_unit }                       from './module/proc_unit.nf'
include { collection }                      from './module/import_collections.nf'
include { mi }                              from './module/import_mi.nf'
include { area_street }                     from './module/area_street.nf'
include { area_rail }                       from './module/area_rail.nf'
include { area_other }                      from './module/area_other.nf'
include { area_aboveground_infrastructure } from './module/area_aboveground_infrastructure.nf'
include { area_building }                   from './module/area_building.nf'
include { volume_building }                 from './module/volume_building.nf'
include { area_impervious }                 from './module/area_impervious.nf'
include { mass_street }                     from './module/mass_street.nf'
include { mass_rail }                       from './module/mass_rail.nf'
include { mass_other }                      from './module/mass_other.nf'
include { mass_building }                   from './module/mass_building.nf'
include { mass_grand_total }                from './module/mass_grand_total.nf'


/**-----------------------------------------------------------------------
--- START OF WORKFLOW ----------------------------------------------------
-----------------------------------------------------------------------**/

workflow {

    // get processing units (tile / state)
    proc_unit()
 
    // import raster collections
    collection(proc_unit.out)

    // import material intensity factors
    mi()

    // area of street types
    area_street(
        collection.out.street, 
        collection.out.street_brdtun,
        collection.out.zone)

    // area of rail types
    area_rail(
        collection.out.rail, 
        collection.out.rail_brdtun,
        collection.out.zone)
 
    // area of other infrastructure types
    area_other(
        collection.out.apron, 
        collection.out.taxi,
        collection.out.runway, 
        collection.out.parking,
        collection.out.zone)

    // area of building types
    area_building(
        collection.out.footprint,
        collection.out.type,
        collection.out.zone)

    // volume of building types
    volume_building(
        area_building.out.sdr,
        area_building.out.dlr,
        area_building.out.ci,
        area_building.out.mixed,
        area_building.out.traditional,
        collection.out.zone)


    // mass of streets
    mass_street(
        area_street.out.motorway,
        area_street.out.primary,
        area_street.out.secondary,
        area_street.out.tertiary,
        area_street.out.local,
        area_street.out.track,
        area_street.out.motorway_elevated,
        area_street.out.other_elevated,
        area_street.out.bridge_motorway,
        area_street.out.bridge_other,
        area_street.out.tunnel,
        collection.out.zone,
        mi.out.street,
    )


    // mass of rails
    mass_rail(
        area_rail.out.railway,
        area_rail.out.tram,
        area_rail.out.subway,
        area_rail.out.subway_elevated,
        area_rail.out.subway_surface,
        area_rail.out.other,
        area_rail.out.bridge,
        area_rail.out.tunnel,
        collection.out.zone,
        mi.out.rail
    )


    // mass of other infrastructure
    mass_other(
        area_other.out.airport,
        area_other.out.parking,
        collection.out.zone,
        mi.out.other
    )


    // mass of buildings
    mass_building(
        volume_building.out.sdr,
        volume_building.out.dlr,
        volume_building.out.ci,
        volume_building.out.mixed,
        volume_building.out.traditional,
        collection.out.zone,
        mi.out.building
    )


    // total techno-mass
    mass_grand_total(
        mass_street.out.total,
        mass_rail.out.total,
        mass_other.out.total,
        mass_building.out.total,
        collection.out.zone
    )

}
