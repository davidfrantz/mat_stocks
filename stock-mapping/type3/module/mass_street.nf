/** street stock
-----------------------------------------------------------------------**/

include { multijoin; remove } from './defs.nf'
include { mass }              from './mass.nf'
include { finalize }          from './finalize.nf'


workflow mass_street {

    take:
    motorway; motorway_link; trunk; trunk_link; 
    primary; primary_link; secondary; secondary_link; 
    tertiary; tertiary_link; residential; living_street;
    pedestrian; footway; cycleway; other; gravel;
    motorway_elevated; other_elevated;
    bridge_motorway; bridge_other; tunnel;
    zone; mi


    main:

    // tile, state, file, type, material, mi
    motorway = motorway
    .combine( Channel.from("motorway") )
    .combine( mi.map{ tab -> [tab.material, tab.motorway]} )

    // tile, state, file, type, material, mi
    motorway_link = motorway_link
    .combine( Channel.from("motorway_link") )
    .combine( mi.map{ tab -> [tab.material, tab.motorway_link]} )

    // tile, state, file, type, material, mi
    trunk = trunk
    .combine( Channel.from("trunk") )
    .combine( mi.map{ tab -> [tab.material, tab.trunk]} )

    // tile, state, file, type, material, mi
    trunk_link = trunk_link
    .combine( Channel.from("trunk_link") )
    .combine( mi.map{ tab -> [tab.material, tab.trunk_link]} )

    // tile, state, file, type, material, mi
    primary = primary
    .combine( Channel.from("primary") )
    .combine( mi.map{ tab -> [tab.material, tab.primary]} )

    // tile, state, file, type, material, mi
    primary_link = primary_link
    .combine( Channel.from("primary_link") )
    .combine( mi.map{ tab -> [tab.material, tab.primary_link]} )

    // tile, state, file, type, material, mi
    secondary = secondary
    .combine( Channel.from("secondary") )
    .combine( mi.map{ tab -> [tab.material, tab.secondary]} )

    // tile, state, file, type, material, mi
    secondary_link = secondary_link
    .combine( Channel.from("secondary_link") )
    .combine( mi.map{ tab -> [tab.material, tab.secondary_link]} )

    // tile, state, file, type, material, mi
    tertiary = tertiary
    .combine( Channel.from("tertiary") )
    .combine( mi.map{ tab -> [tab.material, tab.tertiary]} )

    // tile, state, file, type, material, mi
    tertiary_link = tertiary_link
    .combine( Channel.from("tertiary_link") )
    .combine( mi.map{ tab -> [tab.material, tab.tertiary_link]} )

    // tile, state, file, type, material, mi
    residential = residential
    .combine( Channel.from("residential") )
    .combine( mi.map{ tab -> [tab.material, tab.residential]} )

    // tile, state, file, type, material, mi
    living_street = living_street
    .combine( Channel.from("living_street") )
    .combine( mi.map{ tab -> [tab.material, tab.living_street]} )

    // tile, state, file, type, material, mi
    pedestrian = pedestrian
    .combine( Channel.from("pedestrian") )
    .combine( mi.map{ tab -> [tab.material, tab.pedestrian]} )

    // tile, state, file, type, material, mi
    footway = footway
    .combine( Channel.from("footway") )
    .combine( mi.map{ tab -> [tab.material, tab.footway]} )

    // tile, state, file, type, material, mi
    cycleway = cycleway
    .combine( Channel.from("cycleway") )
    .combine( mi.map{ tab -> [tab.material, tab.cycleway]} )

    // tile, state, file, type, material, mi
    other = other
    .combine( Channel.from("other") )
    .combine( mi.map{ tab -> [tab.material, tab.other]} )

    // tile, state, file, type, material, mi
    gravel = gravel
    .combine( Channel.from("gravel") )
    .combine( mi.map{ tab -> [tab.material, tab.gravel]} )

    // tile, state, file, type, material, mi
    motorway_elevated = motorway_elevated
    .combine( Channel.from("motorway_elevated") )
    .combine( mi.map{ tab -> [tab.material, tab.motorway_elevated]} )

    // tile, state, file, type, material, mi
    other_elevated = other_elevated
    .combine( Channel.from("other_elevated") )
    .combine( mi.map{ tab -> [tab.material, tab.other_elevated]} )

    // tile, state, file, type, material, mi
    bridge_motorway = bridge_motorway
    .combine( Channel.from("bridge_motorway") )
    .combine( mi.map{ tab -> [tab.material, tab.bridge_motorway]} )

    // tile, state, file, type, material, mi
    bridge_other = bridge_other
    .combine( Channel.from("bridge_other") )
    .combine( mi.map{ tab -> [tab.material, tab.bridge_other]} )

    // tile, state, file, type, material, mi
    tunnel = tunnel
    .combine( Channel.from("tunnel") )
    .combine( mi.map{ tab -> [tab.material, tab.tunnel]} )


    // tile, state, file, type, material, mi, pubdir -> mass
    motorway
    .mix(motorway_link,
         trunk,
         trunk_link,
         primary,
         primary_link,
         secondary,
         secondary_link,
         tertiary,
         tertiary_link,
         residential,
         living_street,
         pedestrian,
         footway,
         cycleway,
         other,
         gravel,
         motorway_elevated,
         other_elevated,
         bridge_motorway,
         bridge_other,
         tunnel)
    .map{ it[0..-1]
          .plus("$params.dir.pub/" + it[1,0].join("/") + "/mass/street/" + it[4]) } \
    | mass


    // tile, state, type, material, 11 x files, pubdir -> mass_building_total
    multijoin([ 
        mass.out.filter{ it[2].equals('motorway')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('motorway_link')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('trunk')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('trunk_link')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('primary')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('primary_link')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('secondary')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('secondary_link')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('tertiary')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('tertiary_link')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('residential')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('living_street')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('pedestrian')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('footway')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('cycleway')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('other')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('gravel')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('motorway_elevated')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('other_elevated')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('bridge_motorway')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('bridge_other')}.map{ remove(it, 2) },
        mass.out.filter{ it[2].equals('tunnel')}.map{ remove(it, 2) }],
        [0,1,2] )
    .filter{ it[2].equals('total')} \
    .map{ it[0..-1]
          .plus("$params.dir.pub/" + it[1,0].join("/") + "/mass/street/" + it[2]) } \
    | mass_street_total


    // tile, state, category, dimension, material, basename, filename -> 1st channel of finalize
    all_published = mass_street_total.out
    .mix(mass.out)
    .map{
        [ it[0], it[1], "street", "mass", it[3], it[4].name, it[4] ] }

    finalize(all_published, zone)


    emit:
    total = mass_street_total.out

}


process mass_street_total {

    label 'gdal'
    label 'mem_23'

    input:
    tuple val(tile), val(state), val(material), 
        file(motorway), file(motorway_link), 
        file(trunk), file(trunk_link), 
        file(primary), file(primary_link), 
        file(secondary), file(secondary_link), 
        file(tertiary), file(tertiary_link), 
        file(residential), file(living_street), 
        file(pedestrian), file(footway), 
        file(cycleway), file(other), 
        file(gravel), file(motorway_elevated), 
        file(other_elevated), file(bridge_motorway), 
        file(bridge_other), file(tunnel), val(pubdir)

    output:
    tuple val(tile), val(state), val("total"), val(material), file('mass_street_total.tif')

    publishDir "$pubdir", mode: 'copy'

    """
    gdal_calc.py \
        -A $motorway \
        -B $motorway_link \
        -C $trunk \
        -D $trunk_link \
        -E $primary \
        -F $primary_link \
        -G $secondary \
        -H $secondary_link \
        -I $tertiary \
        -J $tertiary_link \
        -K $residential \
        -L $living_street \
        -M $pedestrian \
        -N $footway \
        -O $cycleway \
        -P $other \
        -Q $gravel \
        -R $motorway_elevated \
        -S $other_elevated \
        -T $bridge_motorway \
        -U $bridge_other \
        -V $tunnel \
        --calc="(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T+U+V)" \
        --outfile=mass_street_total.tif \
        $params.gdal.calc_opt_float
    """

}

