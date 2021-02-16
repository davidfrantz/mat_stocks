/** building area per building type
-----------------------------------------------------------------------**/

include { multijoin } from './defs.nf'


workflow area_building {

    take:
    area; type

    main:
    area_building_singlefamily(multijoin([area, type], [0,1]))
    area_building_multifamily(multijoin([area, type], [0,1]))
    area_building_commercial_industrial(multijoin([area, type], [0,1]))
    area_building_commercial_innercity(multijoin([area, type], [0,1]))
    area_building_highrise(multijoin([area, type], [0,1]))
    area_building_skyscraper(multijoin([area, type], [0,1]))
    area_building_garages(multijoin([area, type], [0,1]))
    area_building_mobilehomes(multijoin([area, type], [0,1]))
    area_building_lightweight(multijoin([area_building_garages.out, area_building_mobilehomes.out], [0,1]))

    emit:
    lightweight           = area_building_lightweight.out
    singlefamily          = area_building_singlefamily.out
    multifamily           = area_building_multifamily.out
    commercial_industrial = area_building_commercial_industrial.out
    commercial_innercity  = area_building_commercial_innercity.out
    highrise              = area_building_highrise.out
    skyscraper            = area_building_skyscraper.out

}

// building area of singlefamily (excl. garages)
process area_building_singlefamily {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_singlefamily.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( (A * (B == $params.class.res_sf)) -                     \
                  (A * (B == $params.class.res_sf) * $params.threshold.percent_garage) )" \
        --outfile=area_building_singlefamily.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of garages
process area_building_garages {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_garages.tif')

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.res_sf) * $params.threshold.percent_garage )" \
        --outfile=area_building_garages.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of mobilehomes
process area_building_mobilehomes {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_mobilehomes.tif')

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.mobile) )" \
        --outfile=area_building_mobilehomes.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of lightweight
process area_building_lightweight {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(garage), file(mobile)

    output:
    tuple val(tile), val(state), file('area_building_lightweight.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $garage \
        -B $mobile \
        --calc="( A + B )" \
        --outfile=area_building_lightweight.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of multifamily
process area_building_multifamily {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_multifamily.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.res_mf) )" \
        --outfile=area_building_multifamily.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of commercial/industrial
process area_building_commercial_industrial {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_commercial_industrial.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.comm_ind) )" \
        --outfile=area_building_commercial_industrial.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of commercial/innercity
process area_building_commercial_innercity {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_commercial_innercity.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.comm_cbd) )" \
        --outfile=area_building_commercial_innercity.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of highrise buildings
process area_building_highrise {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_highrise.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.highrise) )" \
        --outfile=area_building_highrise.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area of skyscrapers
process area_building_skyscraper {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(area), file(type)

    output:
    tuple val(tile), val(state), file('area_building_skyscraper.tif')

    publishDir "$params.dir.pub/$state/$tile/area/building", mode: 'copy'

    """
    gdal_calc.py \
        -A $area \
        -B $type \
        --calc="( A * (B == $params.class.skyscraper) )" \
        --outfile=area_building_skyscraper.tif \
        $params.gdal.calc_opt_byte
    """

}


