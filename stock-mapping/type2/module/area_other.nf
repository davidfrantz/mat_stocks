/** area of other impervious surfaces
-----------------------------------------------------------------------**/

include { multijoin } from './defs.nf'
include { pyramid }   from './pyramid.nf'
include { sum }       from './sum.nf'


workflow area_other {

    take:
    apron; taxi; runway; parking

    main: 
    area_airport(multijoin([runway, taxi, apron], [0,1]))
    area_parking(parking)

    all_published = 
        area_airport.out
        .mix(   area_parking.out)
        .map{
            [ it[2], "$params.dir.pub/" + it[1] + "/" + it[0] + "/area/building" ] }

    pyramid(all_published)
    sum(all_published)

    emit:
    airport = area_airport.out
    parking = area_parking.out

}


// area [m²] of airport roads/aprons (aprons, taxiways and runways)
process area_airport{

    label 'mem_3'

    input:
    tuple val(tile), val(state), file(runway), file(taxi), file(apron)

    output:
    tuple val(tile), val(state), file('area_other_airport.tif')

    publishDir "$params.dir.pub/$state/$tile/area/other", mode: 'copy'

    """
    gdal_calc.py \
        -A $runway \
        -B $taxi \
        -C $apron \
        --calc='minimum((A+B+C),100)' \
        --outfile=area_other_airport.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of parking lots (as mapped in OSM)
process area_parking {

    input:
    tuple val(tile), val(state), file(parking)

    output:
    tuple val(tile), val(state), file('area_other_parking.tif')

    publishDir "$params.dir.pub/$state/$tile/area/other", mode: 'copy'

    """
    gdal_calc.py \
        -A $parking \
        --calc='minimum(A,100)' \
        --outfile=area_other_parking.tif \
        $params.gdal.calc_opt_byte
    """

}

