/** building volume per building type
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'

include { volume as volume_building_hard_lr }   from './volume.nf'
include { volume as volume_building_hard_mr }  from './volume.nf'
include { volume as volume_building_wood_lr }   from './volume.nf'
include { volume as volume_building_wood_mr }   from './volume.nf'
include { volume as volume_building_dcmix } from './volume.nf'
include { volume as volume_building_high }  from './volume.nf'
include { volume as volume_building_sky }   from './volume.nf'
include { volume as volume_building_light } from './volume.nf'


workflow volume_building {

    take:
    area_hard_lr
    area_hard_mr
    area_wood_lr
    area_wood_mr
    area_high
    area_sky
    height
    zone

    main:
    volume_building_hard_lr(
        multijoin([area_hard_lr, height], [0,1]))
    volume_building_hard_mr(
        multijoin([area_hard_mr, height], [0,1]))
    volume_building_wood_lr(
        multijoin([area_wood_lr, height], [0,1]))
    volume_building_wood_mr(
        multijoin([area_wood_mr, height], [0,1]))
    volume_building_high(
        multijoin([area_high, height], [0,1]))
    volume_building_sky(
        multijoin([area_sky, height], [0,1]))

    all_published = 
        volume_building_hard_lr.out
        .mix(   volume_building_hard_mr.out,
                volume_building_wood_lr.out,
                volume_building_wood_mr.out,
                volume_building_high.out,
                volume_building_sky.out)
        .map{
            [ it[0], it[1], "building", "volume", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    hard_lr   = volume_building_hard_lr.out
    hard_mr  = volume_building_hard_mr.out
    wood_lr   = volume_building_wood_lr.out
    wood_mr   = volume_building_wood_mr.out
    high  = volume_building_high.out
    sky   = volume_building_sky.out

}

