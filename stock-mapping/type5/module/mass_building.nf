/** building stock
-----------------------------------------------------------------------**/

include { multijoin; remove } from './defs.nf'
include { mass }              from './mass.nf'
include { finalize }          from './finalize.nf'


workflow mass_building {

    take:
    hard_lr;
    hard_mr;
    wood_lr;
    wood_mr;
    high;
    sky;
    zone; 
    mi


    main:

    // tile, state, file_area, file, type, material, mi_area, mi
    hard_lr = hard_lr
    .combine( Channel.from("hard_lr") )
    .combine( mi.map{ tab -> [tab.material, tab.hard_lr] } )

    // tile, state, file_area, file, type, material, mi_area, mi
    hard_mr = hard_mr
    .combine( Channel.from("hard_mr") )
    .combine( mi.map{ tab -> [tab.material, tab.hard_mr] } )

    // tile, state, file_area, file, type, material, mi_area, mi
    wood_lr = wood_lr
    .combine( Channel.from("wood_lr") )
    .combine( mi.map{ tab -> [tab.material, tab.wood_lr] } )

    // tile, state, file_area, file, type, material, mi_area, mi
    wood_mr = wood_mr
    .combine( Channel.from("wood_mr") )
    .combine( mi.map{ tab -> [tab.material, tab.wood_mr] } )

    // tile, state, file_area, file, type, material, mi_area, mi
    high = high
    .combine( Channel.from("high") )
    .combine( mi.map{ tab -> [tab.material, tab.high] } )

    // tile, state, file_area, file, type, material, mi_area, mi
    sky = sky
    .combine( Channel.from("sky") )
    .combine( mi.map{ tab -> [tab.material, tab.sky] } )


    // tile, state, file, type, material, mi, pubdir -> mass
    hard_lr
    .mix(hard_mr,
         wood_lr,
         wood_mr,
         high,
         sky)
    .map{ it[0..-1]
          .plus("$params.dir.pub/" + it[1,0].join("/") + "/mass/building/" + it[5]) } \
    | mass


    // tile, state, material, 8 x files, pubdir -> mass_building_total
    multijoin([ 
        mass.out.filter{ it[2].equals('hard_lr')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('hard_mr')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('wood_lr')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('wood_mr')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('high')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('sky')}.map{ remove(it, 2) }], 
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
        file(hard_lr), file(hard_mr), file(wood_lr),
        file(wood_mr), file(high), file(sky), 
        val(pubdir)

    output:
    tuple val(tile), val(state), val("total"), val(material), file('mass_building_total.tif')

    publishDir "$pubdir", mode: 'copy'

    """
    gdal_calc.py \
        -A $hard_lr \
        -B $hard_mr \
        -C $wood_lr \
        -D $wood_mr \
        -E $high \
        -F $sky \
        --calc="(A+B+C+D+E+F)" \
        --outfile=mass_building_total.tif \
        $params.gdal.calc_opt_float
    """

}


