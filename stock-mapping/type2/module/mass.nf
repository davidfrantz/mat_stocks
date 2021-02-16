// material stock

process mass {

    input:
    tuple val(tile), val(state), file(dimension), val(material), val(mi)

    output:
    tuple val(tile), val(state), val(material), file('mass*.tif')

    publishDir "$params.dir.pub/$state/$tile/mass/$material", mode: 'copy'

    """
    base=$dimension
    base=\$(basename \$base)
    base=\${base/area/mass}
    base=\${base/volume/mass}
    base=\${base%%.tif}
    gdal_calc.py \
        -A $dimension \
        --calc="( A * $mi )" \
        --outfile=\$base"_"$material".tif" \
        $params.gdal.calc_opt_float
    """

}


process mass_climate6 {

    label 'mem_2'

    input:
    tuple val(tile), val(state), file(dimension), file(climate), val(material), 
        val(mi1), val(mi2), val(mi3), val(mi4), val(mi5), val(mi6)

    output:
    tuple val(tile), val(state), val(material), file('mass*.tif')

    publishDir "$params.dir.pub/$state/$tile/mass/$material", mode: 'copy'

    """
    base=$dimension
    base=\$(basename \$base)
    base=\${base/area/mass}
    base=\${base/volume/mass}
    base=\${base%%.tif}
    gdal_calc.py \
        -A $dimension \
        -B $climate \
        --calc="( \
            ( A * (B == 1) * $mi1 ) + \
            ( A * (B == 2) * $mi2 ) + \
            ( A * (B == 3) * $mi3 ) + \
            ( A * (B == 4) * $mi4 ) + \
            ( A * (B == 5) * $mi5 ) + \
            ( A * (B == 6) * $mi6 ) )" \
        --outfile=\$base"_"$material".tif" \
        $params.gdal.calc_opt_float
    """

}

