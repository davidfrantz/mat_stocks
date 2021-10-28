/** building area per building type
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'


workflow area_building {

    take:
    area; type; zone

    main:
    area_building_sdr_lr(multijoin([area, type], [0,1]))
    area_building_sdr_mr(multijoin([area, type], [0,1]))
    area_building_sdr_hr(multijoin([area, type], [0,1]))
    area_building_dcmix_lr(multijoin([area, type], [0,1]))
    area_building_dcmix_mr(multijoin([area, type], [0,1]))
    area_building_dcmix_hr(multijoin([area, type], [0,1]))
    area_building_irh(multijoin([area, type], [0,1]))
    area_building_sky(multijoin([area, type], [0,1]))
    area_building_light(multijoin([area, type], [0,1]))
    
    all_published = 
        area_building_light.out
        .mix(   area_building_sdr_lr.out,
                area_building_sdr_mr.out,
                area_building_sdr_hr.out,
                area_building_dcmix_lr.out,
                area_building_dcmix_mr.out,
                area_building_dcmix_hr.out,
                area_building_irh.out,
                area_building_sky.out)
        .map{
            [ it[0], it[1], "building", "area", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    sdr_lr   = area_building_sdr_lr.out
    sdr_mr   = area_building_sdr_mr.out
    sdr_hr   = area_building_sdr_hr.out
    dcmix_lr = area_building_dcmix_lr.out
    dcmix_mr = area_building_dcmix_mr.out
    dcmix_hr = area_building_dcmix_hr.out
    irh      = area_building_irh.out
    light    = area_building_light.out
    sky      = area_building_sky.out

}


// building area of sdr_lr (excl. garages)
process area_building_sdr_lr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_sdr_lr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( (A * (B == $params.class.sdr_lr)) -                     \
                  (A * (B == $params.class.sdr_lr) * $params.threshold.percent_garage) )" \
        --outfile=area_building_sdr_lr.tif \
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
                  (A * (B == $params.class.sdr_lr) * $params.threshold.percent_garage) )" \
        --outfile=area_building_light.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of sdr_mr
process area_building_sdr_mr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_sdr_mr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.sdr_mr) )" \
        --outfile=area_building_sdr_mr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of sdr_hr
process area_building_sdr_hr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_sdr_hr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.sdr_hr) )" \
        --outfile=area_building_sdr_hr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of dcmix_lr
process area_building_dcmix_lr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_dcmix_lr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.dcmix_lr) )" \
        --outfile=area_building_dcmix_lr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of dcmix_mr
process area_building_dcmix_mr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_dcmix_mr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.dcmix_mr) )" \
        --outfile=area_building_dcmix_mr.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of dcmix_hr
process area_building_dcmix_hr {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_dcmix_hr.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.dcmix_hr) )" \
        --outfile=area_building_dcmix_hr.tif \
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


