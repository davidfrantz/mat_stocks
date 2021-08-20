// material stock

process mass {

    label 'gdal'

    input:
    tuple val(tile), val(state), file(input), val(type), val(material), val(mi), val(pubdir)

    output:
    tuple val(tile), val(state), val(type), val(material), file('mass*.tif')

    publishDir "$pubdir", mode: 'copy'

    """
    base=$input
    base=\$(basename \$base)
    base=\${base/area/mass}
    base=\${base/volume/mass}
    base=\${base%%.tif}
    gdal_calc.py \
        -A $input \
        --calc="( A * $mi )" \
        --outfile=\$base"_"$material".tif" \
        $params.gdal.calc_opt_float
    """

}


// two component mass (area & volume)
process mass_2comp {

    label 'gdal'
    label 'mem_2'

    input:
    tuple val(tile), val(state), file(input_area), file(input_volume), val(type), val(material), val(mi_area), val(mi_volume), val(pubdir)

    output:
    tuple val(tile), val(state), val(type), val(material), file('mass*.tif')

    publishDir "$pubdir", mode: 'copy'

    """
    base=$input_area
    base=\$(basename \$base)
    base=\${base/area/mass}
    base=\${base/volume/mass}
    base=\${base%%.tif}
    gdal_calc.py \
        -A $input_area \
        -B $input_volume \
        --calc="( A * $mi_area + B * $mi_volume )" \
        --outfile=\$base"_"$material".tif" \
        $params.gdal.calc_opt_float
    """

}
