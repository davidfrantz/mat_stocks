/** all other impervious surfaces
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'


workflow area_impervious {

    take:
    impervious; area_aboveground_infrastructure; height; zone

    main:
    area_all_impervious(impervious)
    area_impervious_without_ag(
        multijoin(
           [area_all_impervious.out, 
            area_aboveground_infrastructure], [0,1]))

    area_building(
        multijoin(
           [area_impervious_without_ag.out, 
            height], [0,1]))
    area_remaining_impervious(
        multijoin(
           [area_impervious_without_ag.out, 
            area_building.out], [0,1]))

    all_published = 
        area_remaining_impervious.out
        .map{
            [ it[0], it[1], "other", "area", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    remaining = area_remaining_impervious.out
    building  = area_building.out

}

// area [m²] of all impervious surfaces
// we clean this at the lower end (25%) to reduce commission and sliver artefacts
process area_all_impervious {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(impervious)

    output:
    tuple val(tile), val(state), file('area_other_all_impervious.tif')

    """
    gdal_calc.py \
        -A $impervious --A_band=1 \
        --calc="(A*(A>$params.threshold.area_impervious))" \
        --outfile=area_other_all_impervious.tif \
        $params.gdal.calc_opt_byte
    """

}


process area_impervious_without_ag {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(impervious), file(infrastructure)

    output:
    tuple val(tile), val(state), file('area_impervious_without_ag.tif')

    publishDir "$params.dir.pub/$state/$tile/area/other", mode: 'copy'

    """
    gdal_calc.py \
        -A $infrastructure \
        -B $impervious \
        --calc='maximum((single(B)-A),0)' \
        --outfile=area_impervious_without_ag.tif \
        $params.gdal.calc_opt_byte
    """

}


process area_remaining_impervious {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(impervious), file(building)

    output:
    tuple val(tile), val(state), file('area_other_remaining_impervious.tif')

    publishDir "$params.dir.pub/$state/$tile/area/other", mode: 'copy'

    """
    gdal_calc.py \
        -A $building \
        -B $impervious \
        --calc='maximum((single(B)-A),0)' \
        --outfile=area_other_remaining_impervious.tif \
        $params.gdal.calc_opt_byte
    """

}


// building area
// remove buildings < 2m
process area_building {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(impervious), file(height)

    output:
    tuple val(tile), val(state), file('area_building.tif')

    """
    gdal_calc.py \
        -A $impervious \
        -B $height \
        --calc="(A*$params.scale.building * (B>=$params.threshold.height_building))" \
        --outfile=area_building.tif \
        $params.gdal.calc_opt_byte
    """

}
