/** building properties
-----------------------------------------------------------------------**/

include { multijoin } from './defs.nf'


workflow property_building {

    take:
    height; impervious; type

    main:
    height_building(height)
    type_building(multijoin([type, height_building.out], [0,1]))

    emit:
    height = height_building.out
    type   = type_building.out

}


// building height
// scale to m
process height_building {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(height)

    output:
    tuple val(tile), val(state), file('height_building.tif')

    """
    gdal_calc.py \
        -A $height \
        --calc='(single(A)/$params.scale.height)' \
        --outfile=height_building.tif \
        $params.gdal.calc_opt_float
    """

}


// building type
// add building classes based on height thresholds
process type_building {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(type), file(height)

    output:
    tuple val(tile), val(state), file('type_building.tif')

    """
    gdal_calc.py \
        -A $type \
        -B $height \
        --calc="                                                                                                              \
            maximum(                                                                                                          \
                A,                                                                                                            \
                maximum(                                                                                                      \
                    ( (A == $params.class.hard_lr) * (B >= $params.threshold.height_midrise) * $params.class.hard_mr ),       \
                    maximum(                                                                                                  \
                        ( (A == $params.class.wood_lr) * (B >= $params.threshold.height_midrise) * $params.class.wood_mr ),   \
                        maximum(                                                                                              \
                            ( (B >= $params.threshold.height_high) * $params.class.high ),                                    \
                            ( (B >= $params.threshold.height_sky)  * $params.class.sky  )                                     \
                        )                                                                                                     \
                    )                                                                                                         \
                )                                                                                                             \
            )                                                                                                                 \
        "                                                                                                                     \
        --outfile=type_building.tif \
        $params.gdal.calc_opt_byte
    """

}

