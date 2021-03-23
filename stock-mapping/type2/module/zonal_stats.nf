/** zonal statistics
-----------------------------------------------------------------------**/

include { multijoin }           from './defs.nf'


workflow zonal_stats {

    take:
    street; rail; other; building; zone


    main:
    street = 
        street
        .map{ 
            [ it[0], it[1], "street", it[2], it[3] ] }

    rail   = 
        rail
        .map{ 
            [ it[0], it[1], "rail", it[2], it[3] ] }

    other  = 
        other
        .map{ 
            [ it[0], it[1], "other", it[2], it[3] ] }

    building = 
        building
        .map{ 
            [ it[0], it[1], "building", it[2], it[3] ] }

    zonal(
        multijoin(
            [street.mix(rail, other, building), 
             zone], [0,1]))

    zone_per_state = 
        zonal.out
        .map{ [ it[1], it[2], it[3], it[4].name, it[4],
                "$params.dir.pub/" + it[1] + "/mosaic/zonal" ] }

    zone_all = 
        zonal.out
        .map{ [ "ALL", it[2], it[3], it[4].name, it[4],
                "$params.dir.pub/" + "/ALL/zonal" ] }

    zone_per_state.mix(zone_all)
    .groupTuple(by: [0,1,2,3,5]) \
    | zonal_merge

}


process zonal {

    label 'mem_2'

    input:
    tuple val(tile), val(state), val(category), val(material), 
        file(values), file(zones)

    output:
    tuple val(tile), val(state), val(category), val(material), file('*.txt')

    """
    zonal_stats_from_tiles.py $values".txt" $values $zones
    """

}


process zonal_merge {

    input:
    tuple val(state), val(category), val(material), val(basename), file('?.txt'), val(pubdir)

    output:
    tuple val(state), val(category), val(material), val(basename), file('*.txt')

    publishDir "$pubdir", mode: 'copy'

    """
    raster_sum_stats.py $basename *.txt
    """

}
