/** building stock
-----------------------------------------------------------------------**/

include { multijoin; remove } from './defs.nf'
include { mass }              from './mass.nf'
include { finalize }          from './finalize.nf'


workflow mass_building {

    take:
    sdr; dlr; 
    ci; mixed; 
    traditional;
    zone; mi


    main:

    // tile, state, file, type, material, mi
    sdr = sdr
    .combine( Channel.from("sdr") )
    .combine( mi.map{ tab -> [tab.material, tab.sdr] } )

    // tile, state, file, type, material, mi
    dlr = dlr
    .combine( Channel.from("dlr") )
    .combine( mi.map{ tab -> [tab.material, tab.dlr] } )

    // tile, state, file, type, material, mi
    ci = ci
    .combine( Channel.from("ci") )
    .combine( mi.map{ tab -> [tab.material, tab.ci] } )

    // tile, state, file, type, material, mi
    mixed = mixed
    .combine( Channel.from("mixed") )
    .combine( mi.map{ tab -> [tab.material, tab.mixed] } )

    // tile, state, file, type, material, mi
    traditional = traditional
    .combine( Channel.from("traditional") )
    .combine( mi.map{ tab -> [tab.material, tab.traditional] } )


    // tile, state, file, type, material, mi, pubdir -> mass
    sdr
    .mix(dlr,
         ci,
         mixed,
         traditional)
    .map{ it[0..-1]
          .plus("$params.dir.pub/" + it[1,0].join("/") + "/mass/building/" + it[4]) } \
    | mass


    // tile, state, type, material, 7 x files, pubdir -> mass_building_total
    multijoin([ 
        mass.out.filter{ it[2].equals('sdr')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('dlr')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('ci')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('mixed')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('traditional')}.map{ remove(it, 2) }], 
        [0,1,2] )
    .filter{ it[2].equals('total')} \
    .map{ it[0..-1]
          .plus("$params.dir.pub/" + it[1,0].join("/") + "/mass/building/" + it[2]) } \
    | mass_building_total


    // tile, state, category, dimension, material, basename, filename -> 1st channel of finalize
    all_published = mass_building_total.out
    .mix(mass.out)
    .map{
        [ it[0], it[1], "building", "mass", it[3], it[4].name, it[4] ] }

    finalize(all_published, zone)


    emit:
    total = mass_building_total.out

}


process mass_building_total {

    label 'gdal'
    label 'mem_7'

    input:
    tuple val(tile), val(state), val(material), 
        file(sdr), file(dlr), 
        file(ci), file(mixed), 
        file(traditional), 
        val(pubdir)

    output:
    tuple val(tile), val(state), val("total"), val(material), file('mass_building_total.tif')

    publishDir "$pubdir", mode: 'copy'

    """
    gdal_calc.py \
        -A $sdr \
        -B $dlr \
        -C $ci \
        -D $mixed \
        -E $traditional \
        --calc="(A+B+C+D+E)" \
        --outfile=mass_building_total.tif \
        $params.gdal.calc_opt_float
    """

}


