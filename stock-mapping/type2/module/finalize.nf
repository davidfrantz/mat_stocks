include { multijoin }                          from './defs.nf'
include { pyramid }                            from './pyramid.nf'
include { zonal }                              from './zonal.nf'
include { zonal_merge as zonal_merge_state   } from './zonal.nf'
include { zonal_merge as zonal_merge_country } from './zonal.nf'


workflow finalize {

    take:
    input; zone
    /**      0    1     2        3         4        5        6
    input: tile state category dimension material basename filename
    zone:  tile state filename
    **/

    main:
    // pyramid takes filename and pubdir
    input
    .map{ [ it[6], 
            "$params.dir.pub/" + it[1,0,3,2,4].join("/") ] } \
    | pyramid

    // zonal takes tile, state, category, dimension, material, basename, filename, zones, pubdir
    multijoin([input, zone], [0,1])
    .map{ it[0..7]
          .plus("$params.dir.pub/" + it[1,0,3,2,4].join("/") ) } \
    | zonal

    // zonal_merge takes state, category, dimension, material, basename, filename, zones, pubdir
    zonal.out
    .map{ it[1..6]
          .plus("$params.dir.pub/" + it[1] + "/mosaic/" + it[3,2,4].join("/") ) }
    .groupTuple(by: [0,1,2,3,4,6]) \
    | zonal_merge_state

    // zonal_merge takes state, category, dimension, material, basename, filename, zones, pubdir
    zonal_merge_state.out
    .map{ it[0..5]
          .plus("$params.dir.pub/ALL" + it[3,2,4].join("/") ) }
    .groupTuple(by: [1,2,3,4,6]) \
    | zonal_merge_country

}
