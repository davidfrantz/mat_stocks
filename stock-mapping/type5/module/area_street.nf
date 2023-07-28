/** area for street types
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'


workflow area_street {

    take:
    street; street_brdtun; zone

    main:
    area_street_motorway(street)
    area_street_primary(street)
    area_street_secondary(street)
    area_street_tertiary(street)
    area_street_local(street)
    area_street_gravel(street)
    area_street_motorway_elevated(street)
    area_street_other_elevated(street)
    area_street_bridge_motorway(street_brdtun)
    area_street_bridge_other(street_brdtun)
    area_street_tunnel(street_brdtun)

    // tile, state, category, dimension, material, basename, filename -> 1st channel of finalize
    all_published = 
        area_street_motorway.out
        .mix(   area_street_primary.out,
                area_street_secondary.out,
                area_street_tertiary.out,
                area_street_local.out,
                area_street_gravel.out,
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
    primary           = area_street_primary.out
    secondary         = area_street_secondary.out
    tertiary          = area_street_tertiary.out
    local             = area_street_local.out
    gravel            = area_street_gravel.out
    motorway_elevated = area_street_motorway_elevated.out
    other_elevated    = area_street_other_elevated.out
    bridge_motorway   = area_street_bridge_motorway.out
    bridge_other      = area_street_bridge_other.out
    tunnel            = area_street_tunnel.out

}


// rasterized OSM street layer (area [m²])
/** 35 bands
 1  motorway                         -> motorway
 2  motorway_link                    -> motorway
 3  primary                          -> secondary
 4  primary_link                     -> secondary
 5  trunk                            -> primary
 6  trunk_link                       -> primary
 7  secondary                        -> tertiary
 8  secondary_link                   -> tertiary
 9  tertiary                         -> local
10  tertiary_link                    -> local
11  unclassified                     -> local
12  residential                      -> local
13  living_street                    -> local
14  service                          -> local
15  track_1                          -> gravel
16  track_2                          -> gravel
17  track_3                          -> gravel
18  track_4                          -> gravel
19  track_5                          -> gravel
20  track_na                         -> gravel
21  path                             -> gravel
22  footway                          -> local
23  cycleway                         -> local
24  bridleway                        -> local
25  steps                            -> local
26  pedestrian                       -> local
27  construction                     -> local
28  raceway                          -> motorway
29  rest_area                        -> local
30  road                             -> local
31  services                         -> local
32  platform                         -> local
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
    label 'mem_3'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_motorway.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """
    gdal_calc.py \
        -A $street --A_band=1 \
        -B $street --B_band=2 \
        -C $street --C_band=28 \
        --calc='minimum((A+B+C),100)' \
        --outfile=area_street_motorway.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of primary roads
process area_street_primary {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_primary.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=5 \
        -B $street --B_band=6 \
        --calc='minimum((A+B),100)' \
        --outfile=area_street_primary.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of secondary roads
process area_street_secondary {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_secondary.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=3 \
        -B $street --B_band=4 \
        --calc='minimum((A+B),100)' \
        --outfile=area_street_secondary.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of tertiary roads
process area_street_tertiary {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_tertiary.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=7 \
        -B $street --B_band=8 \
        --calc='minimum((A+B),100)' \
        --outfile=area_street_tertiary.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of local streets
process area_street_local {

    label 'gdal'
    label 'mem_16'

    input:
    tuple val(tile), val(state), file(street)

    output:
    tuple val(tile), val(state), file('area_street_living_street.tif')

    publishDir "$params.dir.pub/$state/$tile/area/street", mode: 'copy'

    """    
    gdal_calc.py \
        -A $street --A_band=9 \
        -B $street --B_band=10 \
        -C $street --C_band=11 \
        -D $street --D_band=12 \
        -E $street --E_band=13 \
        -F $street --F_band=14 \
        -G $street --G_band=22 \
        -H $street --H_band=23 \
        -I $street --I_band=24 \
        -J $street --J_band=25 \
        -K $street --K_band=26 \
        -L $street --L_band=27 \
        -M $street --M_band=29 \
        -N $street --N_band=30 \
        -O $street --O_band=31 \
        -P $street --P_band=32 \
        --calc='minimum((A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P),100)' \
        --outfile=area_street_living_street.tif \
        $params.gdal.calc_opt_byte
    """

}


// area [m²] of track roads (unpaved, gravel)
process area_street_gravel {

    label 'gdal'
    label 'mem_7'

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
        -G $street --G_band=21 \
        --calc='minimum((A+B+C+D+E+F+G),100)' \
        --outfile=area_street_gravel.tif \
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

