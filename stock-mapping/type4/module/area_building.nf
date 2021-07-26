/** building area per building type
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'


workflow area_building {

    take:
    area; type; zone

    main:
    area_building_sdr(multijoin([area, type], [0,1]))
    area_building_arco(multijoin([area, type], [0,1]))
    area_building_mlr(multijoin([area, type], [0,1]))
    area_building_irh(multijoin([area, type], [0,1]))
    area_building_dcmix(multijoin([area, type], [0,1]))
    area_building_high(multijoin([area, type], [0,1]))
    area_building_sky(multijoin([area, type], [0,1]))
    area_building_light(multijoin([area, type], [0,1]))
    
    all_published = 
        area_building_light.out
        .mix(   area_building_sdr.out,
                area_building_arco.out,
                area_building_mlr.out,
                area_building_irh.out,
                area_building_dcmix.out,
                area_building_high.out,
                area_building_sky.out)
        .map{
            [ it[0], it[1], "building", "area", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    sdr   = area_building_sdr.out
    arco  = area_building_arco.out
    mlr   = area_building_mlr.out
    irh   = area_building_irh.out
    dcmix = area_building_dcmix.out
    light = area_building_light.out
    high  = area_building_high.out
    sky   = area_building_sky.out

}


// building area of sdr (excl. garages)
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
        --calc="( (A * (B == $params.class.sdr)) -                     \
                  (A * (B == $params.class.sdr) * $params.threshold.percent_garage) )" \
        --outfile=area_building_sdr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of light (incl. garages)
process area_building_light {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_light.tif')

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( (A * (B == $params.class.light)) +                     \
                  (A * (B == $params.class.sdr) * $params.threshold.percent_garage) )" \
        --outfile=area_building_light.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of arco
process area_building_arco {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_arco.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.arco) )" \
        --outfile=area_building_arco.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of mlr
process area_building_mlr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_mlr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.mlr) )" \
        --outfile=area_building_mlr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of commercial/industrial
process area_building_irh {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_irh.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.irh) )" \
        --outfile=area_building_irh.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of commercial/innercity
process area_building_dcmix {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_dcmix.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.dcmix) )" \
        --outfile=area_building_dcmix.tif \
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


