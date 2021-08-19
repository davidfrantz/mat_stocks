/** area for street types
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'


workflow area_street {

    take:
    street; street_brdtun; zone

    main:
    area_street_motorway(street)
    area_street_motorway_link(street)
    area_street_trunk(street)
    area_street_trunk_link(street)
    area_street_primary(street)
    area_street_primary_link(street)
    area_street_secondary(street)
    area_street_secondary_link(street)
    area_street_tertiary(street)
    area_street_tertiary_link(street)
    area_street_residential(street)
    area_street_living_street(street)
    area_street_pedestrian(street)
    area_street_footway(street)
    area_street_cycleway(street)
    area_street_other(street)
    area_street_gravel(street)
    area_street_exclude(street)
    area_street_motorway_elevated(street)
    area_street_other_elevated(street)
    area_street_bridge_motorway(street_brdtun)
    area_street_bridge_other(street_brdtun)
    area_street_tunnel(street_brdtun)

    // tile, state, category, dimension, material, basename, filename -> 1st channel of finalize
    all_published = 
        area_street_motorway.out
        .mix(   area_street_motorway_link.out,
                area_street_trunk.out,
                area_street_trunk_link.out,
                area_street_primary.out,
                area_street_primary_link.out,
                area_street_secondary.out,
                area_street_secondary_link.out,
                area_street_tertiary.out,
                area_street_tertiary_link.out,
                area_street_residential.out,
                area_street_living_street.out,
                area_street_pedestrian.out,
                area_street_footway.out,
                area_street_cycleway.out,
                area_street_other.out,
                area_street_gravel.out,
                area_street_exclude.out,
                area_street_motorway_elevated.out,
                area_street_other_elevated.out,
                area_street_bridge_motorway.out,
                area_street_bridge_other.out,
                area_street_tunnel.out)
        .map{
            [ it[0], it[1], "street", "area", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    motorway          = area_street_motorway.out
    motorway_link     = area_street_motorway_link.out
    trunk             = area_street_trunk.out
    trunk_link        = area_street_trunk_link.out
    primary           = area_street_primary.out
    primary_link      = area_street_primary_link.out
    secondary         = area_street_secondary.out
    secondary_link    = area_street_secondary_link.out
    tertiary          = area_street_tertiary.out
    tertiary_link     = area_street_tertiary_link.out
    residential       = area_street_residential.out
    living_street     = area_street_living_street.out
    pedestrian        = area_street_pedestrian.out
    footway           = area_street_footway.out
    cycleway          = area_street_cycleway.out
    other             = area_street_other.out
    gravel            = area_street_gravel.out
    exclude           = area_street_exclude.out
    motorway_elevated = area_street_motorway_elevated.out
    other_elevated    = area_street_other_elevated.out
    bridge_motorway   = area_street_bridge_motorway.out
    bridge_other      = area_street_bridge_other.out
    tunnel            = area_street_tunnel.out

}


// rasterized OSM street layer (area [m²])
/** 35 bands
 1  motorway                         -> motorway
 2  motorway_link                    -> motorway_link
 3  primary                          -> primary
 4  primary_link                     -> primary_link
 5  trunk                            -> trunk
 6  trunk_link                       -> trunk_link
 7  secondary                        -> secondary
 8  secondary_link                   -> secondary_link
 9  tertiary                         -> tertiary
10  tertiary_link                    -> tertiary_link
11  unclassified                     -> other
12  residential                      -> residential
13  living_street                    -> living_street
14  service                          -> other
15  track_1                          -> gravel
16  track_2                          -> gravel
17  track_3                          -> gravel
18  track_4                          -> gravel
19  track_5                          -> gravel
20  track_na                         -> gravel
21  path                             -> exclude
22  footway                          -> footway
23  cycleway                         -> cycleway
24  bridleway                        -> exclude
25  steps                            -> other
26  pedestrian                       -> pedestrian
27  construction                     -> exclude
28  raceway                          -> motorway
29  rest_area                        -> other
30  road                             -> other
31  services                         -> other
32  platform                         -> other
33  motorway on bridge               -> motorway_elevated
34  motorway_link on bridge          -> motorway_elevated
35  road on bridge (except motorway) -> other_elevated
**/


// rasterized OSM street bridge/tunnel layer (area [m²])
/** 3 bands
1  road bridge      -> bridge_other
2  road tunnel      -> tunnel
3  motorway bridge  -> bridge_motorway
**/


// area [m²] of motorways
process area_street_motorway {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_motorway.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=1 \
        -B $street --B_band=28 \
        --calc='minimum((A+B),100)' \
        --outfile=area_street_motorway.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of motorway links
process area_street_motorway_link {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_motorway_link.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=2 \
        --calc='A' \
        --outfile=area_street_motorway_link.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of trunk roads
process area_street_trunk {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_trunk.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=5 \
        --calc='A' \
        --outfile=area_street_trunk.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of trunk links
process area_street_trunk_link {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_trunk_link.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=6 \
        --calc='A' \
        --outfile=area_street_trunk_link.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of primary roads
process area_street_primary {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_primary.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=3 \
        --calc='A' \
        --outfile=area_street_primary.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of primary links
process area_street_primary_link {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_primary_link.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=4 \
        --calc='A' \
        --outfile=area_street_primary_link.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of secondary roads
process area_street_secondary {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_secondary.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=7 \
        --calc='A' \
        --outfile=area_street_secondary.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of secondary links
process area_street_secondary_link {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_secondary_link.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=8 \
        --calc='A' \
        --outfile=area_street_secondary_link.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of tertiary roads
process area_street_tertiary {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_tertiary.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=9 \
        --calc='A' \
        --outfile=area_street_tertiary.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of tertiary links
process area_street_tertiary_link {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_tertiary_link.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=10 \
        --calc='A' \
        --outfile=area_street_tertiary_link.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of residential roads
process area_street_residential {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_residential.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=12 \
        --calc='A' \
        --outfile=area_street_residential.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of living streets
process area_street_living_street {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_living_street.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=13 \
        --calc='A' \
        --outfile=area_street_living_street.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of pedestrian streets
process area_street_pedestrian {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_pedestrian.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=26 \
        --calc='A' \
        --outfile=area_street_pedestrian.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of footways
process area_street_footway {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_footway.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=22 \
        --calc='A' \
        --outfile=area_street_footway.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of cycleways
process area_street_cycleway {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_cycleway.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=23 \
        --calc='A' \
        --outfile=area_street_cycleway.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of other local road types
process area_street_other {

    label 'gdal'
    label 'mem_7'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_other.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=11 \
        -B $street --B_band=14 \
        -C $street --C_band=25 \
        -D $street --D_band=29 \
        -E $street --E_band=30 \
        -F $street --F_band=31 \
        -G $street --G_band=32 \
        --calc='minimum((A+B+C+D+E+F+G),100)' \
        --outfile=area_street_other.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of track roads (unpaved, gravel)
process area_street_gravel {

    label 'gdal'
    label 'mem_6'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_gravel.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=15 \
        -B $street --B_band=16 \
        -C $street --C_band=17 \
        -D $street --D_band=18 \
        -E $street --E_band=19 \
        -F $street --F_band=20 \
        --calc='minimum((A+B+C+D+E+F),100)' \
        --outfile=area_street_gravel.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of streets with no man-made material (dirt roads)
// - should be subtracted from impervious surfaces,
// - but should not be assigned with a mass
process area_street_exclude {

    label 'gdal'
    label 'mem_3'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_exclude.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=21 \
        -B $street --B_band=24 \
        -C $street --C_band=27 \
        --calc='minimum((A+B+C),100)' \
        --outfile=area_street_exclude.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of motorways on bridges (excluding the bridge)
process area_street_motorway_elevated {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_motorway_elevated.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=33 \
        -B $street --B_band=34 \
        --calc='minimum((A+B),100)' \
        --outfile=area_street_motorway_elevated.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of other roads on bridges (excluding the bridge)
process area_street_other_elevated {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_other_elevated.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=35 \
        --calc='minimum((A),100)' \
        --outfile=area_street_other_elevated.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of motorway bridges (excluding the road)
process area_street_bridge_motorway {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(brdtun)

    output:
    tuple val(tile), val(state), file('area_street_bridge_motorway.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $brdtun --A_band=3 \
        --calc='minimum((A),100)' \
        --outfile=area_street_bridge_motorway.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of other bridges (excluding the road)
process area_street_bridge_other {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(brdtun)

    output:
    tuple val(tile), val(state), file('area_street_bridge_other.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $brdtun --A_band=1 \
        --calc='minimum((A),100)' \
        --outfile=area_street_bridge_other.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of road tunnels (excluding the road)
process area_street_tunnel {

    label 'gdal'
    
    input:
    tuple val(tile), val(state), file(brdtun)

    output:
    tuple val(tile), val(state), file('area_street_tunnel.tif')
    
    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $brdtun --A_band=2 \
        --calc='minimum((A),100)' \
        --outfile=area_street_tunnel.tif \
        $params.gdal.calc_opt_byte
    """

}

