/** building volume per building type
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'

include { volume as volume_building_sdr         } from './volume.nf'
include { volume as volume_building_dlr         } from './volume.nf'
include { volume as volume_building_ci          } from './volume.nf'
include { volume as volume_building_mixed       } from './volume.nf'
include { volume as volume_building_traditional } from './volume.nf'


workflow volume_building {

    take:
    area_sdr
    area_dlr
    area_ci
    area_mixed
    area_traditional
    zone

    main:
    volume_building_sdr(area_sdr)
    volume_building_dlr(area_dlr)
    volume_building_ci(area_ci)
    volume_building_mixed(area_mixed)
    volume_building_traditional(area_traditional)

    all_published = 
        volume_building_sdr.out
        .mix(   volume_building_dlr.out,
                volume_building_ci.out,
                volume_building_mixed.out,
                volume_building_traditional.out)
        .map{
            [ it[0], it[1], "building", "volume", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    sdr         = volume_building_sdr.out
    dlr         = volume_building_dlr.out
    ci          = volume_building_ci.out
    mixed       = volume_building_mixed.out
    traditional = volume_building_traditional.out

}

