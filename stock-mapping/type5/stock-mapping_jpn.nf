#!/usr/bin/env nextflow

// enable modules
nextflow.enable.dsl=2


/**-----------------------------------------------------------------------
--- PARAMETERS, PATHS, OPTIONS AND THRESHOLDS ----------------------------
-----------------------------------------------------------------------**/

// country
params.country      = "JPN"
params.country_code = "JP"

// project directory
params.dir_project = "/data/Jakku/mat_stocks"

// directories
params.dir = [
    "tiles":      params.dir_project + "/tiles/"    + params.country,
    "mask":       params.dir_project + "/mask/"     + params.country,
    "zone":       params.dir_project + "/zone/"     + params.country,
    "osm":        params.dir_project + "/osm/"      + params.country,
    "type":       params.dir_project + "/type/"     + params.country,
    "impervious": params.dir_project + "/fraction/" + params.country,
    "height":     params.dir_project + "/height/"   + params.country,
    "pub":        params.dir_project + "/stock/"    + params.country,
    "mi":         params.dir_project + "/mi/"       + params.country,
    "areacorr":   params.dir_project + "/areacorr/" + params.country
]

// raster collections
params.raster = [
    "mask":             [params.dir.mask,       "mask.tif"],
    "zone":             [params.dir.zone,       "zone-local.tif"],
    "street":           [params.dir.osm,        "streets.tif"],
    "street_brdtun":    [params.dir.osm,        "road-brdtun.tif"],
    "rail":             [params.dir.osm,        "railway.tif"],
    "rail_brdtun":      [params.dir.osm,        "rail-brdtun.tif"],
    "apron":            [params.dir.osm,        "apron.tif"],
    "taxi":             [params.dir.osm,        "taxiway.tif"],
    "runway":           [params.dir.osm,        "runway.tif"],
    "parking":          [params.dir.osm,        "parking.tif"],
    "impervious":       [params.dir.impervious, "FRACTIONS_BU-WV-NWV-W_clean.tif"],
    "height":           [params.dir.height,     "HEIGHT_HL_ML_MLP_height-jpn.tif"],
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
    "hard_lr": 1,
    "wood_lr": 2,
    // additional bulding type classes (set within workflow)
    "hard_mr": 3,
    "wood_mr": 4,
    "high":  8,
    "sky":   9
]

params.threshold = [
    // height thresholds
    "height_building":   2,
    "height_midrise":   10,
    "height_high":   30,
    "height_sky": 75,
    // area thresholds
    "area_impervious":   25,
]

// scaling factors
params.scale = [
    "height":   10,
    "building": 0.40
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
include { property_building }               from './module/property_building.nf'
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

    // area of aboveground infrastructure
    area_aboveground_infrastructure(
        area_street.out.motorway,
        area_street.out.primary,
        area_street.out.secondary,
        area_street.out.tertiary,
        area_street.out.local,
        area_street.out.gravel,
        area_street.out.motorway_elevated,
        area_street.out.other_elevated,
        area_street.out.bridge_motorway,
        area_street.out.bridge_other,
        area_street.out.tunnel,
        area_rail.out.shinkansen,
        area_rail.out.railway,
        area_rail.out.tram,
        //area_rail.out.other,
        area_rail.out.exclude,
        area_rail.out.subway_elevated,
        area_rail.out.subway_surface,
        area_rail.out.bridge,
        area_rail.out.tunnel,
        area_other.out.airport,
        area_other.out.parking)

    // building properties
    property_building(
        collection.out.height,
        collection.out.impervious,
        collection.out.type)

    // area of remaining impervious infrastructure
    area_impervious(
        collection.out.impervious,
        area_aboveground_infrastructure.out.total,
        property_building.out.height,
        collection.out.zone)

    // area of building types
    area_building(
        area_impervious.out.building,
        property_building.out.type,
        collection.out.zone)

    // volume of building types
    volume_building(
        area_building.out.hard_lr,
        area_building.out.hard_mr,
        area_building.out.wood_lr,
        area_building.out.wood_mr,
        area_building.out.high,
        area_building.out.sky,
        property_building.out.height,
        collection.out.zone)


    // mass of streets
    mass_street(
        area_street.out.motorway,
        area_street.out.primary,
        area_street.out.secondary,
        area_street.out.tertiary,
        area_street.out.local,
        area_street.out.gravel,
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
        area_rail.out.shinkansen,
        area_rail.out.railway,
        area_rail.out.tram,
        area_rail.out.subway,
        area_rail.out.subway_elevated,
        area_rail.out.subway_surface,
        //area_rail.out.other,
        area_rail.out.bridge,
        area_rail.out.tunnel,
        collection.out.zone,
        mi.out.rail
    )


    // mass of other infrastructure
    mass_other(
        area_other.out.airport,
        area_other.out.parking,
        area_impervious.out.remaining,
        collection.out.zone,
        mi.out.other
    )


    // mass of buildings
    mass_building(
        volume_building.out.hard_lr,
        volume_building.out.hard_mr,
        volume_building.out.wood_lr,
        volume_building.out.wood_mr,
        volume_building.out.high,
        volume_building.out.sky,
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
