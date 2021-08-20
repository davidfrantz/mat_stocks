/** building volume per building type
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'

include { volume as volume_building_sdr_lr }   from './volume.nf'
include { volume as volume_building_sdr_mr }  from './volume.nf'
include { volume as volume_building_dcmix_lr }   from './volume.nf'
include { volume as volume_building_irh }   from './volume.nf'
include { volume as volume_building_dcmix_mr } from './volume.nf'
include { volume as volume_building_high }  from './volume.nf'
include { volume as volume_building_sky }   from './volume.nf'
include { volume as volume_building_light } from './volume.nf'


workflow volume_building {

    take:
    area_sdr_lr
    area_sdr_mr
    area_dcmix_lr
    area_dcmix_mr
    area_irh
    area_light
    area_high
    area_sky
    height
    zone

    main:
    volume_building_sdr_lr(
        multijoin([area_sdr_lr, height], [0,1]))
    volume_building_sdr_mr(
        multijoin([area_sdr_mr, height], [0,1]))
    volume_building_dcmix_lr(
        multijoin([area_dcmix_lr, height], [0,1]))
    volume_building_dcmix_mr(
        multijoin([area_dcmix_mr, height], [0,1]))
    volume_building_irh(
        multijoin([area_irh, height], [0,1]))
    volume_building_light(
        multijoin([area_light, height], [0,1]))
    volume_building_high(
        multijoin([area_high, height], [0,1]))
    volume_building_sky(
        multijoin([area_sky, height], [0,1]))

    all_published = 
        volume_building_sdr_lr.out
        .mix(   volume_building_sdr_mr.out,
                volume_building_dcmix_lr.out,
                volume_building_dcmix_mr.out,
                volume_building_irh.out,
                volume_building_light.out,
                volume_building_high.out,
                volume_building_sky.out)
        .map{
            [ it[0], it[1], "building", "volume", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    sdr_lr   = volume_building_sdr_lr.out
    sdr_mr   = volume_building_sdr_mr.out
    dcmix_lr = volume_building_dcmix_lr.out
    dcmix_mr = volume_building_dcmix_mr.out
    irh      = volume_building_irh.out
    light    = volume_building_light.out
    high     = volume_building_high.out
    sky      = volume_building_sky.out   

}

