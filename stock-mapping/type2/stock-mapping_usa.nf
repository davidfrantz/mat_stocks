#!/usr/bin/env nextflow

// enable modules
nextflow.enable.dsl=2


/**-----------------------------------------------------------------------
--- PARAMETERS, PATHS, OPTIONS AND THRESHOLDS ----------------------------
-----------------------------------------------------------------------**/

// country
params.country      = "USA"
params.country_code = "US"

// project directory
params.dir_project = "/data/Jakku/mat_stocks"

// directories
params.dir = [
    "tiles":      params.dir_project + "/tiles/"    + params.country,
    "mask":       params.dir_project + "/mask/"     + params.country,
    "osm":        params.dir_project + "/osm/"      + params.country,
    "type":       params.dir_project + "/type/"     + params.country,
    "impervious": params.dir_project + "/fraction/" + params.country,
    "footprint":  params.dir_project + "/building/" + params.country,
    "height":     params.dir_project + "/height/"   + params.country,
    "climate":    params.dir_project + "/climate/"  + params.country,
    "pub":        params.dir_project + "/stock/"    + params.country,
    "mi":         params.dir_project + "/mi/"       + params.country
]

// raster collections
params.raster = [
    "mask":           [params.dir.mask,       "5km.tif"],
    "street":         [params.dir.osm,        "streets.tif"],
    "street_brdtun":  [params.dir.osm,        "road-brdtun.tif"],
    "rail":           [params.dir.osm,        "railway.tif"],
    "rail_brdtun":    [params.dir.osm,        "rail-brdtun.tif"],
    "apron":          [params.dir.osm,        "apron.tif"],
    "taxi":           [params.dir.osm,        "taxiway.tif"],
    "runway":         [params.dir.osm,        "runway.tif"],
    "parking":        [params.dir.osm,        "parking.tif"],
    "impervious":     [params.dir.impervious, "NLCD_2016_Impervious_L48_20190405_canada-cleaned.tif"],
    "footprint":      [params.dir.footprint,  "building.tif"],
    "height":         [params.dir.height,     "BUILDING-HEIGHT_HL_ML_MLP.tif"],
    "type":           [params.dir.type,       "BUILDING-TYPE_HL_ML_MLP.tif" ],
    "street_climate": [params.dir.climate,    "road_climate.tif"]
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
    "res":        1,
    "comm_ind":   3,
    "comm_cbd":   5,
    "mobile":     6,

    // additional bulding type classes (set within workflow)
    "res_sf":     1,
    "res_mf":     2,
    "highrise":   8,
    "skyscraper": 9
]

params.threshold = [
    // height thresholds
    "height_building":   2,
    "height_mf":         10,
    "height_highrise":   30,
    "height_skyscraper": 150,

    // area thresholds
    "area_impervious":   50,
    "percent_garage":    0.1
]

// scaling factors
params.scale = [
    "height": 10
]

// options for gdal
params.gdal = [
    "calc_opt_byte":  '--NoDataValue=255   --type=Byte    --format=GTiff --creation-option=COMPRESS=LZW --creation-option=PREDICTOR=2 --creation-option=BIGTIFF=YES --creation-option=TILED=YES',
    "calc_opt_int16": '--NoDataValue=-9999 --type=Int16   --format=GTiff --creation-option=COMPRESS=LZW --creation-option=PREDICTOR=2 --creation-option=BIGTIFF=YES --creation-option=TILED=YES',
    "calc_opt_float": '--NoDataValue=-9999 --type=Float32 --format=GTiff --creation-option=COMPRESS=LZW --creation-option=PREDICTOR=2 --creation-option=BIGTIFF=YES --creation-option=TILED=YES',
    "tran_opt_float": '-a_nodata -9999 -ot Float32 -of GTiff -co COMPRESS=LZW -co PREDICTOR=2 -co BIGTIFF=YES -co TILED=YES'
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
        collection.out.street_brdtun)

    // area of rail types
    area_rail(
        collection.out.rail, 
        collection.out.rail_brdtun)
 
    // area of other infrastructure types
    area_other(
        collection.out.apron, 
        collection.out.taxi,
        collection.out.runway, 
        collection.out.parking)

    // area of aboveground infrastructure
    area_aboveground_infrastructure(
        area_street.out.motorway,
        area_street.out.primary,
        area_street.out.secondary,
        area_street.out.tertiary,
        area_street.out.local,
        area_street.out.track,
        area_street.out.exclude,
        area_street.out.motorway_elevated,
        area_street.out.other_elevated,
        area_street.out.bridge_motorway,
        area_street.out.bridge_other,
        area_street.out.tunnel,
        area_rail.out.railway,
        area_rail.out.tram,
        area_rail.out.other,
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
        collection.out.footprint, 
        collection.out.type)

    // area of building types
    area_building(
        property_building.out.area,
        property_building.out.type)

    // volume of building types
    volume_building(
        area_building.out.lightweight,
        area_building.out.singlefamily,
        area_building.out.multifamily,
        area_building.out.commercial_industrial,
        area_building.out.commercial_innercity,
        area_building.out.highrise,
        area_building.out.skyscraper,
        property_building.out.height)

    // area of remaining impervious infrastructure
    area_impervious(
        collection.out.impervious,
        property_building.out.area,
        area_aboveground_infrastructure.out.total)


    // mass of streets
    mass_street(
        area_street.out.motorway
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.motorway]}
            ),
        area_street.out.primary
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.primary]}
            ),
        area_street.out.secondary
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.secondary]}
            ),
        area_street.out.tertiary
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.tertiary]}
            ),
        multijoin([area_street.out.local, collection.out.street_climate], [0,1])
            .combine(
                mi.out.street.map{ tab -> [tab.material, 
                    tab.local_climate1, tab.local_climate2, tab.local_climate3, 
                    tab.local_climate4, tab.local_climate5, tab.local_climate6]}
            ),
        multijoin([area_street.out.track, collection.out.street_climate], [0,1])
            .combine(
                mi.out.street.map{ tab -> [tab.material, 
                    tab.track_climate1, tab.track_climate2, tab.track_climate3, 
                    tab.track_climate4, tab.track_climate5, tab.track_climate6]}
            ),
        area_street.out.motorway_elevated
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.motorway_elevated]}
            ),
        area_street.out.other_elevated
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.other_elevated]}
            ),
        area_street.out.bridge_motorway
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.bridge_motorway]}
            ),
        area_street.out.bridge_other
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.bridge_other]}
            ),
        area_street.out.tunnel
            .combine(
                mi.out.street.map{ tab -> [tab.material, tab.tunnel]}
            )
    )


    // mass of rails
    mass_rail(
        area_rail.out.railway
            .combine(
                mi.out.rail.map{ tab -> [tab.material, tab.railway]}
            ),
        area_rail.out.tram
            .combine(
                mi.out.rail.map{ tab -> [tab.material, tab.tram]}
            ),
        area_rail.out.subway
            .combine(
                mi.out.rail.map{ tab -> [tab.material, tab.subway]}
            ),
        area_rail.out.subway_elevated
            .combine(
                mi.out.rail.map{ tab -> [tab.material, tab.subway_elevated]}
            ),
        area_rail.out.subway_surface
            .combine(
                mi.out.rail.map{ tab -> [tab.material, tab.subway_surface]}
            ),
        area_rail.out.other
            .combine(
                mi.out.rail.map{ tab -> [tab.material, tab.other]}
            ),
        area_rail.out.bridge
            .combine(
                mi.out.rail.map{ tab -> [tab.material, tab.bridge]}
            ),
        area_rail.out.tunnel
            .combine(
                mi.out.rail.map{ tab -> [tab.material, tab.tunnel]}
            )
    )


    // mass of other infrastructure
    mass_other(
        area_other.out.airport
            .combine(
                mi.out.other.map{ tab -> [tab.material, tab.airport]}
            ),
        area_other.out.parking
            .combine(
                mi.out.other.map{ tab -> [tab.material, tab.parking]}
            ),
        area_impervious.out.remaining
            .combine(
                mi.out.other.map{ tab -> [tab.material, tab.impervious]}
            )
    )


    // mass of buildings
    mass_building(
        volume_building.out.lightweight
            .combine(
                mi.out.building.map{ tab -> [tab.material, tab.lightweight]}
            ),
        volume_building.out.singlefamily
            .combine(
                mi.out.building.map{ tab -> [tab.material, tab.singlefamily]}
            ),
        volume_building.out.multifamily
            .combine(
                mi.out.building.map{ tab -> [tab.material, tab.multifamily]}
            ),
        volume_building.out.commercial_industrial
            .combine(
                mi.out.building.map{ tab -> [tab.material, tab.commercial_industrial]}
            ),
        volume_building.out.commercial_innercity
            .combine(
                mi.out.building.map{ tab -> [tab.material, tab.commercial_innercity]}
            ),
        volume_building.out.highrise
            .combine(
                mi.out.building.map{ tab -> [tab.material, tab.highrise]}
            ),
        volume_building.out.skyscraper
            .combine(
                mi.out.building.map{ tab -> [tab.material, tab.skyscraper]}
            )
    )


    // total techno-mass
    mass_grand_total(
        mass_street.out.total,
        mass_rail.out.total,
        mass_other.out.total,
        mass_building.out.total
    )

}


