/** building volume per building type
-----------------------------------------------------------------------**/

include { multijoin }                          from './defs.nf'
include { finalize }                           from './finalize.nf'

include { volume as volume_building_sdr }   from './volume.nf'
include { volume as volume_building_arco }  from './volume.nf'
include { volume as volume_building_mlr }   from './volume.nf'
include { volume as volume_building_irh }   from './volume.nf'
include { volume as volume_building_dcmix } from './volume.nf'
include { volume as volume_building_high }  from './volume.nf'
include { volume as volume_building_sky }   from './volume.nf'
include { volume as volume_building_light } from './volume.nf'


workflow volume_building {

    take:
    area_sdr
    area_arco
    area_mlr
    area_irh
    area_dcmix
    area_light
    area_high
    area_sky
    height
    zone

    main:
    volume_building_sdr(
        multijoin([area_sdr, height], [0,1]))
    volume_building_arco(
        multijoin([area_arco, height], [0,1]))
    volume_building_mlr(
        multijoin([area_mlr, height], [0,1]))
    volume_building_irh(
        multijoin([area_irh, height], [0,1]))
    volume_building_dcmix(
        multijoin([area_dcmix, height], [0,1]))
    volume_building_light(
        multijoin([area_light, height], [0,1]))
    volume_building_high(
        multijoin([area_high, height], [0,1]))
    volume_building_sky(
        multijoin([area_sky, height], [0,1]))

    all_published = 
        volume_building_sdr.out
        .mix(   volume_building_arco.out,
                volume_building_mlr.out,
                volume_building_irh.out,
                volume_building_dcmix.out,
                volume_building_light.out,
                volume_building_high.out,
                volume_building_sky.out)
        .map{
            [ it[0], it[1], "building", "volume", "", it[2].name, it[2] ] }

    finalize(all_published, zone)


    emit:
    sdr   = volume_building_sdr.out
    arco  = volume_building_arco.out
    mlr   = volume_building_mlr.out
    irh   = volume_building_irh.out
    dcmix = volume_building_dcmix.out
    light = volume_building_light.out
    high  = volume_building_high.out
    sky   = volume_building_sky.out

}

