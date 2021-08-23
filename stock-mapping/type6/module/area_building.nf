/** building area per building type
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'


workflow area_building {

    take:
    area; type; zone

    main:
    area_building_sdr(multijoin([area, type], [0,1]))
    area_building_dlr(multijoin([area, type], [0,1]))
    area_building_ci(multijoin([area, type], [0,1]))
    area_building_mixed(multijoin([area, type], [0,1]))
    area_building_traditional(multijoin([area, type], [0,1]))

    all_published = 
        area_building_sdr.out
        .mix(   area_building_dlr.out,
                area_building_ci.out,
                area_building_mixed.out,
                area_building_traditional.out)
        .map{
            [ it[0], it[1], "building", "area", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    sdr         = area_building_sdr.out
    dlr         = area_building_dlr.out
    ci          = area_building_ci.out
    mixed       = area_building_mixed.out
    traditional = area_building_traditional.out

}


// building area of sdr
process area_building_sdr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_sdr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.sdr) )" \
        --outfile=area_building_sdr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of dlr
process area_building_dlr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_dlr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.dlr) )" \
        --outfile=area_building_dlr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of commercial/industrial
process area_building_ci {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_ci.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.ci) )" \
        --outfile=area_building_ci.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of mixed
process area_building_mixed {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_mixed.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.mixed) )" \
        --outfile=area_building_mixed.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of traditional buildings
process area_building_traditional {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_traditional.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.traditional) )" \
        --outfile=area_building_traditional.tif \
        $params.gdal.calc_opt_byte
    """

}
