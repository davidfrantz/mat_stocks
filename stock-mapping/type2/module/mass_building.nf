/** building stock
-----------------------------------------------------------------------**/

include { multijoin } from './defs.nf'

include { mass          as mass_lightweight }           from './mass.nf'
include { mass_climate5 as mass_singlefamily }          from './mass.nf'
include { mass          as mass_multifamily }           from './mass.nf'
include { mass          as mass_commercial_industrial } from './mass.nf'
include { mass          as mass_commercial_innercity }  from './mass.nf'
include { mass          as mass_highrise }              from './mass.nf'
include { mass          as mass_skyscraper }            from './mass.nf'


workflow mass_building {

    take:
    lightweight; singlefamily; multifamily; 
    commercial_industrial; commercial_innercity; 
    highrise; skyscraper


    main:
    mass_lightweight(lightweight)
    mass_singlefamily(singlefamily)
    mass_multifamily(multifamily)
    mass_commercial_industrial(commercial_industrial)
    mass_commercial_innercity(commercial_innercity)
    mass_highrise(highrise)
    mass_skyscraper(skyscraper)

    mass_building_total(
        multijoin(
           [mass_lightweight.out,
            mass_singlefamily.out,
            mass_multifamily.out,
            mass_commercial_industrial.out,
            mass_commercial_innercity.out,
            mass_highrise.out,
            mass_skyscraper.out], [0,1,2]
        )
        .filter{ it[2].equals('total')}
    )

    emit:
    total = mass_building_total.out

}


process mass_building_total {

    label 'mem_7'

    input:
    tuple val(tile), val(state), val(material), 
        file(lightweight), file(singlefamily), file(multifamily), 
        file(commercial_industrial), file(commercial_innercity), 
        file(highrise), file(skyscraper)

    output:
    tuple val(tile), val(state), file('mass_building_total.tif')

    publishDir "$params.dir.pub/$state/$tile/mass/$material", mode: 'copy'

    """
    gdal_calc.py \
        -A $lightweight \
        -B $singlefamily \
        -C $multifamily \
        -D $commercial_industrial \
        -E $commercial_innercity \
        -F $highrise \
        -G $skyscraper \
        --calc="(A+B+C+D+E+F+G)" \
        --outfile=mass_building_total.tif \
        $params.gdal.calc_opt_float
    """

}


