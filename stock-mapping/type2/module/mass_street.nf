/** street stock
-----------------------------------------------------------------------**/

include { multijoin } from './defs.nf'
include { pyramid }   from './pyramid.nf'

include { mass          as mass_motorway }          from './mass.nf'
include { mass          as mass_primary }           from './mass.nf'
include { mass          as mass_secondary }         from './mass.nf'
include { mass          as mass_tertiary }          from './mass.nf'
include { mass_climate6 as mass_local }             from './mass.nf'
include { mass_climate6 as mass_track }             from './mass.nf'
include { mass          as mass_motorway_elevated } from './mass.nf'
include { mass          as mass_other_elevated }    from './mass.nf'
include { mass          as mass_bridge_motorway }   from './mass.nf'
include { mass          as mass_bridge_other }      from './mass.nf'
include { mass          as mass_tunnel }            from './mass.nf'


workflow mass_street {

    take:
    motorway; primary; secondary; tertiary;
    local; track; motorway_elevated; other_elevated
    bridge_motorway; bridge_other; tunnel


    main:
    mass_motorway(motorway)
    mass_primary(primary)
    mass_secondary(secondary)
    mass_tertiary(tertiary)
    mass_local(local)
    mass_track(track)
    mass_motorway_elevated(motorway_elevated)
    mass_other_elevated(other_elevated)
    mass_bridge_motorway(bridge_motorway)
    mass_bridge_other(bridge_other)
    mass_tunnel(tunnel)

    mass_street_total(
        multijoin(
           [mass_motorway.out,
            mass_primary.out,
            mass_secondary.out,
            mass_tertiary.out,
            mass_local.out,
            mass_track.out,
            mass_motorway_elevated.out,
            mass_other_elevated.out,
            mass_bridge_motorway.out,
            mass_bridge_other.out,
            mass_tunnel.out], [0,1,2]
        )
        .filter{ it[2].equals('total')}
    )

    all_published = 
        mass_street_total.out
        .mix(   mass_motorway.out,
                mass_primary.out,
                mass_secondary.out,
                mass_tertiary.out,
                mass_local.out,
                mass_track.out,
                mass_motorway_elevated.out,
                mass_other_elevated.out,
                mass_bridge_motorway.out,
                mass_bridge_other.out,
                mass_tunnel.out)
        .map{
            [ it[3], "$params.dir.pub/" + it[1] + "/" + it[0] + "/mass/" + it[2] ] }

    pyramid(all_published)

    emit:
    total = mass_street_total.out

}


process mass_street_total {

    label 'mem_11'

    input:
    tuple val(tile), val(state), val(material), 
        file(motorway), file(primary), file(secondary), file(tertiary), 
        file(local), file(track), file(motorway_elevated), 
        file(other_elevated), file(bridge_motorway), 
        file(bridge_other), file(tunnel)

    output:
    tuple val(tile), val(state), val(material), file('mass_street_total.tif')

    publishDir "$params.dir.pub/$state/$tile/mass/$material", mode: 'copy'

    """
    gdal_calc.py \
        -A $motorway \
        -B $primary \
        -C $secondary \
        -D $tertiary \
        -E $local \
        -F $track \
        -G $motorway_elevated \
        -H $other_elevated \
        -I $bridge_motorway \
        -J $bridge_other \
        -K $tunnel \
        --calc="(A+B+C+D+E+F+G+H+I+J+K)" \
        --outfile=mass_street_total.tif \
        $params.gdal.calc_opt_float
    """

}

