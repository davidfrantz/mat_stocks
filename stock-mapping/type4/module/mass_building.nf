/** building stock
-----------------------------------------------------------------------**/

include { multijoin; remove } from './defs.nf'
include { mass_2comp }        from './mass.nf'
include { finalize }          from './finalize.nf'


workflow mass_building {

    take:
    sdr_lr_area;   sdr_lr_volume;
    sdr_mr_area;   sdr_mr_volume;
    dcmix_lr_area; dcmix_lr_volume;
    dcmix_mr_area; dcmix_mr_volume;
    irh_area;      irh_volume;
    light_area;    light_volume;
    high_area;     high_volume;
    sky_area;      sky_volume;
    zone; 
    mi


    main:

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    sdr_lr = multijoin([sdr_lr_area, sdr_lr_volume], [0,1] )
    .combine( Channel.from("sdr_lr") )
    .combine( mi.map{ tab -> [tab.material, tab.sdr_lr_area, tab.sdr_lr_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    sdr_mr = multijoin([sdr_mr_area, sdr_mr_volume], [0,1] )
    .combine( Channel.from("sdr_mr") )
    .combine( mi.map{ tab -> [tab.material, tab.sdr_mr_area, tab.sdr_mr_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    dcmix_lr = multijoin([dcmix_lr_area, dcmix_lr_volume], [0,1] )
    .combine( Channel.from("dcmix_lr") )
    .combine( mi.map{ tab -> [tab.material, tab.dcmix_lr_area, tab.dcmix_lr_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    dcmix_mr = multijoin([dcmix_mr_area, dcmix_mr_volume], [0,1] )
    .combine( Channel.from("dcmix_mr") )
    .combine( mi.map{ tab -> [tab.material, tab.dcmix_mr_area, tab.dcmix_mr_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    irh = multijoin([irh_area, irh_volume], [0,1] )
    .combine( Channel.from("irh") )
    .combine( mi.map{ tab -> [tab.material, tab.irh_area, tab.irh_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    light = multijoin([light_area, light_volume], [0,1] )
    .combine( Channel.from("light") )
    .combine( mi.map{ tab -> [tab.material, tab.light_area, tab.light_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    high = multijoin([high_area, high_volume], [0,1] )
    .combine( Channel.from("high") )
    .combine( mi.map{ tab -> [tab.material, tab.high_area, tab.high_volume] } )

    // tile, state, file_area, file_volume, type, material, mi_area, mi_volume
    sky = multijoin([sky_area, sky_volume], [0,1] )
    .combine( Channel.from("sky") )
    .combine( mi.map{ tab -> [tab.material, tab.sky_area, tab.sky_volume] } )


    // tile, state, file, type, material, mi, pubdir -> mass
    sdr_lr
    .mix(sdr_mr,
         dcmix_lr,
         dcmix_mr,
         irh,
         light,
         high,
         sky)
    .map{ it[0..-1]
          .plus("$params.dir.pub/" + it[1,0].join("/") + "/mass/building/" + it[5]) } \
    | mass_2comp


    // tile, state, material, 8 x files, pubdir -> mass_building_total
    multijoin([ 
        mass_2comp.out.filter{ it[2].equals('sdr_lr')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('sdr_mr')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('dcmix_lr')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('dcmix_mr')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('irh')}.map{ remove(it, 2) },
        mass_2comp.out.filter{ it[2].equals('light')}.map{ remove(it, 2) },
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
        file(sdr_lr), file(sdr_mr), file(dcmix_lr),
        file(dcmix_mr), file(irh), file(light),
        file(high), file(sky), val(pubdir)

    output:
    tuple val(tile), val(state), val("total"), val(material), file('mass_building_total.tif')

    publishDir "$pubdir", mode: 'copy'

    """
    gdal_calc.py \
        -A $sdr_lr \
        -B $sdr_mr \
        -C $dcmix_lr \
        -D $dcmix_mr \
        -E $irh \
        -F $light \
        -G $high \
        -H $sky \
        --calc="(A+B+C+D+E+F+G+H)" \
        --outfile=mass_building_total.tif \
        $params.gdal.calc_opt_float
    """

}


