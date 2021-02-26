/** all other impervious surfaces
-----------------------------------------------------------------------**/

include { multijoin } from './defs.nf'
include { pyramid }   from './pyramid.nf'
include { sum }       from './sum.nf'


workflow area_impervious {

    take:
    impervious; area_building; area_aboveground_infrastructure

    main:
    area_all_impervious(impervious)
    area_remaining_impervious(
        multijoin(
           [area_all_impervious.out, 
            area_building,
            area_aboveground_infrastructure], [0,1]))

    all_published = 
        area_remaining_impervious.out
        .map{
            [ it[2], "$params.dir.pub/" + it[1] + "/" + it[0] + "/area/other" ] }

    pyramid(all_published)
    sum(all_published)

    emit:
    remaining = area_remaining_impervious.out

}

// area [m²] of all impervious surfaces
// we clean this at the lower end (50%) to reduce commission and sliver artefacts
process area_all_impervious {

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


process area_remaining_impervious {

    label 'mem_3'

    input:
    tuple val(tile), val(state), file(impervious), file(building), file(infrastructure)

    output:
    tuple val(tile), val(state), file('area_other_remaining_impervious.tif')

    publishDir "$params.dir.pub/$state/$tile/area/other", mode: 'copy'

    """
    gdal_calc.py \
        -A $building \
        -B $infrastructure \
        -C $impervious \
        --calc='maximum((single(C)-minimum((A+B),100)),0)' \
        --outfile=area_other_remaining_impervious.tif \
        $params.gdal.calc_opt_byte
    """

}
