/** rail stock
-----------------------------------------------------------------------**/


include { multijoin } from './defs.nf'
include { pyramid }   from './pyramid.nf'

include { mass as mass_railway }         from './mass.nf'
include { mass as mass_tram }            from './mass.nf'
include { mass as mass_subway }          from './mass.nf'
include { mass as mass_subway_elevated } from './mass.nf'
include { mass as mass_subway_surface }  from './mass.nf'
include { mass as mass_other }           from './mass.nf'
include { mass as mass_bridge }          from './mass.nf'
include { mass as mass_tunnel }          from './mass.nf'


workflow mass_rail {

    take:
    railway; tram; subway; 
    subway_elevated; subway_surface; 
    other; bridge; tunnel


    main:
    mass_railway(railway)
    mass_tram(tram)
    mass_subway(subway)
    mass_subway_elevated(subway_elevated)
    mass_subway_surface(subway_surface)
    mass_other(other)
    mass_bridge(bridge)
    mass_tunnel(tunnel)


    mass_rail_total(
        multijoin(
           [mass_railway.out,
            mass_tram.out,
            mass_subway.out,
            mass_subway_elevated.out,
            mass_subway_surface.out,
            mass_other.out,
            mass_bridge.out,
            mass_tunnel.out], [0,1,2]
        )
        .filter{ it[2].equals('total')}
    )

    all_published = 
        mass_rail_total.out
        .mix(   mass_railway.out,
                mass_tram.out,
                mass_subway.out,
                mass_subway_elevated.out,
                mass_subway_surface.out,
                mass_other.out,
                mass_bridge.out,
                mass_tunnel.out)
        .map{
            [ it[3], "$params.dir.pub/" + it[1] + "/" + it[0] + "/mass/" + it[2] ] }

    pyramid(all_published)

    emit:
    total = mass_rail_total.out

}


process mass_rail_total {

    label 'mem_8'

    input:
    tuple val(tile), val(state), val(material), 
        file(railway), file(tram), file(subway), 
        file(subway_elevated), file(subway_surface), 
        file(other), file(bridge), file(tunnel)

    output:
    tuple val(tile), val(state), val(material), file('mass_rail_total.tif')

    publishDir "$params.dir.pub/$state/$tile/mass/$material", mode: 'copy'

    """
    gdal_calc.py \
        -A $railway \
        -B $tram \
        -C $subway \
        -D $subway_elevated \
        -E $subway_surface \
        -F $other \
        -G $bridge \
        -H $tunnel \
        --calc="(A+B+C+D+E+F+G+H)" \
        --outfile=mass_rail_total.tif \
        $params.gdal.calc_opt_float
    """

}

