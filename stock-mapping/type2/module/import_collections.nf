include { read_input_full_country; read_input_per_state; multijoin } from './defs.nf'

include { import_mask                                  } from './mask_collection.nf'
include { mask_collection_byte  as mask_street         } from './mask_collection.nf'
include { mask_collection_byte  as mask_street_brdtun  } from './mask_collection.nf'
include { mask_collection_byte  as mask_rail           } from './mask_collection.nf'
include { mask_collection_byte  as mask_rail_brdtun    } from './mask_collection.nf'
include { mask_collection_byte  as mask_apron          } from './mask_collection.nf'
include { mask_collection_byte  as mask_taxi           } from './mask_collection.nf'
include { mask_collection_byte  as mask_runway         } from './mask_collection.nf'
include { mask_collection_byte  as mask_parking        } from './mask_collection.nf'
include { mask_collection_byte  as mask_impervious     } from './mask_collection.nf'
include { mask_collection_byte  as mask_footprint      } from './mask_collection.nf'
include { mask_collection_int16 as mask_height         } from './mask_collection.nf'
include { mask_collection_int16 as mask_type           } from './mask_collection.nf'
include { mask_collection_byte  as mask_street_climate } from './mask_collection.nf'



def import_collection_full_country(proc_unit, file_tuple){
    collection = read_input_full_country(file_tuple)
    collection = multijoin([proc_unit, collection], by = 0)
}

def import_collection_per_state(proc_unit, file_tuple){
    collection = read_input_per_state(file_tuple)
    collection = multijoin([proc_unit, collection], by = [0,1])
}


workflow collection {

    take: 
    proc_unit

    main:

    /** ingest all rasters into tupled channels [tile, state, file]
    -----------------------------------------------------------------------**/
    mask           = import_collection_per_state(proc_unit,    params.raster.mask)
    street         = import_collection_full_country(proc_unit, params.raster.street)
    street_brdtun  = import_collection_full_country(proc_unit, params.raster.street_brdtun)
    rail           = import_collection_full_country(proc_unit, params.raster.rail)
    rail_brdtun    = import_collection_full_country(proc_unit, params.raster.rail_brdtun)
    apron          = import_collection_full_country(proc_unit, params.raster.apron)
    taxi           = import_collection_full_country(proc_unit, params.raster.taxi)
    runway         = import_collection_full_country(proc_unit, params.raster.runway)
    parking        = import_collection_full_country(proc_unit, params.raster.parking)
    impervious     = import_collection_full_country(proc_unit, params.raster.impervious)
    footprint      = import_collection_per_state(proc_unit,    params.raster.footprint)
    height         = import_collection_per_state(proc_unit,    params.raster.height)
    type           = import_collection_per_state(proc_unit,    params.raster.type)
    street_climate = import_collection_full_country(proc_unit, params.raster.street_climate)

    // import the masks
    mask = mask | import_mask

    // mask the rasters
    mask_street(multijoin([mask, street], [0,1]))
    mask_street_brdtun(multijoin([mask, street_brdtun], [0,1]))
    mask_rail(multijoin([mask, rail], [0,1]))
    mask_rail_brdtun(multijoin([mask, rail_brdtun], [0,1]))
    mask_apron(multijoin([mask, apron], [0,1]))
    mask_taxi(multijoin([mask, taxi], [0,1]))
    mask_runway(multijoin([mask, runway], [0,1]))
    mask_parking(multijoin([mask, parking], [0,1]))
    mask_impervious(multijoin([mask, impervious], [0,1]))
    mask_footprint(multijoin([mask, footprint], [0,1]))
    mask_height(multijoin([mask, height], [0,1]))
    mask_type(multijoin([mask, type], [0,1]))
    mask_street_climate(multijoin([mask, street_climate], [0,1]))

    emit:
    street         = mask_street.out
    street_brdtun  = mask_street_brdtun.out
    rail           = mask_rail.out
    rail_brdtun    = mask_rail_brdtun.out
    apron          = mask_apron.out
    taxi           = mask_taxi.out
    runway         = mask_runway.out
    parking        = mask_parking.out
    impervious     = mask_impervious.out
    footprint      = mask_footprint.out
    height         = mask_height.out
    type           = mask_type.out
    street_climate = mask_street_climate.out

}

