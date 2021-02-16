/** other stock
-----------------------------------------------------------------------**/

include { multijoin } from './defs.nf'

include { mass as mass_airport }   from './mass.nf'
include { mass as mass_parking }   from './mass.nf'
include { mass as mass_remaining } from './mass.nf'


workflow mass_other {

    take:
    airport; parking; remaining


    main:
    mass_airport(airport)
    mass_parking(parking)
    mass_remaining(remaining)

    mass_other_total(
        multijoin(
           [mass_airport.out,
            mass_parking.out,
            mass_remaining.out], [0,1,2]
        )
        .filter{ it[2].equals('total')}
    )

    emit:
    total = mass_other_total.out

}


process mass_other_total {

    label 'mem_3'

    input:
    tuple val(tile), val(state), val(material), 
        file(airport), file(parking), file(remaining)

    output:
    tuple val(tile), val(state), file('mass_other_total.tif')

    publishDir "$params.dir.pub/$state/$tile/mass/$material", mode: 'copy'

    """
    gdal_calc.py \
        -A $airport \
        -B $parking \
        -C $remaining \
        --calc="(A+B+C)" \
        --outfile=mass_other_total.tif \
        $params.gdal.calc_opt_float
    """

}

