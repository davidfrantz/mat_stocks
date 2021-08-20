/** area of aboveground infrastructure
-----------------------------------------------------------------------**/

include { multijoin } from './defs.nf'


workflow area_aboveground_infrastructure {

    take:
    street_motorway
    street_motorway_link
    street_trunk
    street_trunk_link
    street_primary
    street_primary_link
    street_secondary
    street_secondary_link
    street_tertiary
    street_tertiary_link
    street_residential
    street_living_street
    street_pedestrian
    street_footway
    street_cycleway
    street_other
    street_gravel
    street_exclude
    street_motorway_elevated
    street_other_elevated
    street_bridge_motorway
    street_bridge_other
    street_tunnel
    rail_shinkansen
    rail_railway
    rail_tram
    rail_other
    rail_exclude
    rail_subway_elevated
    rail_subway_surface
    rail_bridge
    rail_tunnel
    other_airport
    other_parking


    main:
    area_ag_street_infrastructure(
        multijoin(
           [street_motorway, street_motorway_link,
            street_trunk, street_trunk_link,
            street_primary, street_primary_link, 
            street_secondary, street_secondary_link, 
            street_tertiary, street_tertiary_link, 
            street_residential, street_living_street,
            street_pedestrian, street_footway, 
            street_cycleway, street_other, street_gravel, 
            street_exclude, street_motorway_elevated, 
            street_other_elevated, street_bridge_motorway, 
            street_bridge_other, street_tunnel], [0,1])
    )

    area_ag_rail_infrastructure(
         multijoin(
           [rail_shinkansen,
            rail_railway, 
            rail_tram,
            rail_other, 
            rail_exclude, 
            rail_subway_elevated, 
            rail_subway_surface, 
            rail_bridge, 
            rail_tunnel], [0,1])
    )

    area_ag_other_infrastructure(
        multijoin(
            [other_airport, other_parking], [0,1])
    )

    area_ag_total_infrastructure(
        multijoin(
           [area_ag_street_infrastructure.out, 
            area_ag_rail_infrastructure.out, 
            area_ag_other_infrastructure.out], [0,1])
    )

    emit:
    total = area_ag_total_infrastructure.out

}


// area [m²] of all aboveground street infrastructure
// if streets are in tunnels, subtract the tunnel area
// bridges come on top
process area_ag_street_infrastructure {

    label 'gdal'
    label 'mem_23'

    input:
    tuple val(tile), val(state), 
          file(motorway), file(motorway_link), 
          file(trunk), file(trunk_link), 
          file(primary), file(primary_link), 
          file(secondary), file(secondary_link), 
          file(tertiary), file(tertiary_link), 
          file(residential), file(living_street), 
          file(pedestrian), file(footway), 
          file(cycleway), file(other), 
          file(gravel), file(exclude), 
          file(motorway_elevated), file(other_elevated), 
          file(bridge_motorway), file(bridge_other), file(tunnel)

    output:
    tuple val(tile), val(state), file('area_ag_street_infrastructure.tif')

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
        -R $exclude \
        -S $motorway_elevated \
        -T $other_elevated \
        -U $bridge_motorway \
        -V $bridge_other \
        -Z $tunnel \
        --calc='minimum((maximum((single(A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T+U+V)-Z),0)+(H+I+J+K)),100)' \
        --outfile=area_ag_street_infrastructure.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of all aboveground rail infrastructure
// this includes aboveground subways
// if rails are in tunnels, subtract the tunnel area
// bridges come on top
process area_ag_rail_infrastructure {

    label 'gdal'
    label 'mem_9'

    input:
    tuple val(tile), val(state), 
          file(shinkansen), file(rail), file(tram), file(other), 
          file(exclude), file(subway_elevated), 
          file(subway_surface), file(bridge), 
          file(tunnel)

    output:
    tuple val(tile), val(state), file('area_ag_rail_infrastructure.tif')

    """
    gdal_calc.py \
        -H $shinkansen \
        -A $rail \
        -B $tram \
        -C $other \
        -D $exclude \
        -E $subway_elevated \
        -F $subway_surface \
        -G $bridge \
        -Z $tunnel \
        --calc='minimum((maximum((single(H+A+B+C+D+F)-Z),0)+(E+G)),100)' \
        --outfile=area_ag_rail_infrastructure.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of other aboveground infrastructure
// other = airport and parking
process area_ag_other_infrastructure {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(airport), file(parking)

    output:
    tuple val(tile), val(state), file('area_ag_other_infrastructure.tif')

    """
    gdal_calc.py \
        -A $airport \
        -B $parking \
        --calc='minimum((A+B),100)' \
        --outfile=area_ag_other_infrastructure.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of all aboveground infrastructure
process area_ag_total_infrastructure {

    label 'gdal'
    label 'mem_3'

    input:
    tuple val(tile), val(state), file(street), file(rail), file(other)

    output:
    tuple val(tile), val(state), file('area_ag_total_infrastructure.tif')

    """
    gdal_calc.py \
        -A $street \
        -B $rail \
        -C $other \
        --calc='minimum((A+B+C),100)' \
        --outfile=area_ag_total_infrastructure.tif \
        $params.gdal.calc_opt_byte
    """

}

 