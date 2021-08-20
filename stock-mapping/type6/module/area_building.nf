/** building area per building type
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'


workflow area_building {

    take:
    area; type; zone

    main:
    area_building_hard_lr(multijoin([area, type], [0,1]))
    area_building_hard_mr(multijoin([area, type], [0,1]))
    area_building_wood_lr(multijoin([area, type], [0,1]))
    area_building_wood_mr(multijoin([area, type], [0,1]))
    area_building_high(multijoin([area, type], [0,1]))
    area_building_sky(multijoin([area, type], [0,1]))
     
    all_published = 
        area_building_hard_lr.out
        .mix(   area_building_hard_mr.out,
                area_building_wood_lr.out,
                area_building_wood_mr.out,
                area_building_high.out,
                area_building_sky.out)
        .map{
            [ it[0], it[1], "building", "area", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    hard_lr   = area_building_hard_lr.out
    hard_mr  = area_building_hard_mr.out
    wood_lr   = area_building_wood_lr.out
    wood_mr   = area_building_wood_mr.out
    high  = area_building_high.out
    sky   = area_building_sky.out

}


// building area of hard_lr
process area_building_hard_lr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_hard_lr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.hard_lr) )" \
        --outfile=area_building_hard_lr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of hard_mr
process area_building_hard_mr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_hard_mr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.hard_mr) )" \
        --outfile=area_building_hard_mr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of wood_lr
process area_building_wood_lr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_wood_lr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.wood_lr) )" \
        --outfile=area_building_wood_lr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of commercial/industrial
process area_building_wood_mr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_wood_mr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.wood_mr) )" \
        --outfile=area_building_wood_mr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of high buildings
process area_building_high {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_high.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.high) )" \
        --outfile=area_building_high.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of skys
process area_building_sky {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_sky.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.sky) )" \
        --outfile=area_building_sky.tif \
        $params.gdal.calc_opt_byte
    """

}


