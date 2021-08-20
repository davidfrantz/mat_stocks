/** building stock
-----------------------------------------------------------------------**/

include { multijoin; remove } from './defs.nf'
include { mass_2comp }        from './mass.nf'
include { finalize }          from './finalize.nf'


workflow mass_building {

    take:
    hard_lr_area;   hard_lr_volume;
    hard_mr_area;  hard_mr_volume;
    wood_lr_area;   wood_lr_volume;
    wood_mr_area;   wood_mr_volume;
    high_area;  high_volume;
    sky_area;   sky_volume;
    zone; 
    mi


    main:

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    hard_lr = multijoin([hard_lr_area, hard_lr_volume], [0,1] )
    .combine( Channel.from("hard_lr") )
    .combine( mi.map{ tab -> [tab.material, tab.hard_lr_area, tab.hard_lr_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    hard_mr = multijoin([hard_mr_area, hard_mr_volume], [0,1] )
    .combine( Channel.from("hard_mr") )
    .combine( mi.map{ tab -> [tab.material, tab.hard_mr_area, tab.hard_mr_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    wood_lr = multijoin([wood_lr_area, wood_lr_volume], [0,1] )
    .combine( Channel.from("wood_lr") )
    .combine( mi.map{ tab -> [tab.material, tab.wood_lr_area, tab.wood_lr_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    wood_mr = multijoin([wood_mr_area, wood_mr_volume], [0,1] )
    .combine( Channel.from("wood_mr") )
    .combine( mi.map{ tab -> [tab.material, tab.wood_mr_area, tab.wood_mr_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    high = multijoin([high_area, high_volume], [0,1] )
    .combine( Channel.from("high") )
    .combine( mi.map{ tab -> [tab.material, tab.high_area, tab.high_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    sky = multijoin([sky_area, sky_volume], [0,1] )
    .combine( Channel.from("sky") )
    .combine( mi.map{ tab -> [tab.material, tab.sky_area, tab.sky_volume] } )


    // tile, state, file, type, material, mi, pubdir -> mass
    hard_lr
    .mix(hard_mr,
         wood_lr,
         wood_mr,
         high,
         sky)
    .map{ it[0..-1]
          .plus("$params.dir.pub/" + it[1,0].join("/") + "/mass/building/" + it[5]) } \
    | mass_2comp


    // tile, state, material, 8 x files, pubdir -> mass_building_total
    multijoin([ 
        mass_2comp.out.filter{ it[2].equals('hard_lr')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('hard_mr')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('wood_lr')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('wood_mr')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('high')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('sky')}.map{ remove(it, 2) }], 
        [0,1,2] )
    .filter{ it[2].equals('total')} \
    .map{ it[0..-1]
          .plus("$params.dir.pub/" + it[1,0].join("/") + "/mass/building/" + it[2]) } \
    | mass_building_total


    // tile, state, category, dimension, material, basename, filename -> 1st channel of finalize
    all_published = mass_building_total.out
    .mix(mass_2comp.out)
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


