// building volume

process volume {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(area)

    output:
    tuple val(tile), val(state), file('volume_*.tif')

    publishDir "$params.dir.pub/$state/$tile/volume/building", mode: 'copy'

    """
    base=$area
    base=\$(basename \$base)
    base=\${base/area/volume}
    gdal_calc.py \
        -A $area \
        --calc="( A *  $params.height )" \
        --outfile=\$base \
        $params.gdal.calc_opt_float
    """

}

