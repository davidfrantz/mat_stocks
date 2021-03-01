// image sum
process image_sum {

    input:
    tuple val(tile), val(state), val(material), file(input), val(pubdir)

    output:
    tuple val(tile), val(state), val(material), file('*.txt')

    publishDir "$pubdir", mode: 'copy'

    """
    nodata=\$(gdalinfo $input | grep NoData | head -n 1 |  sed 's/ //g' | cut -d '=' -f 2)
    imgsum $input \$nodata > $input".txt"
    """

}


process text_sum {

    input:
    tuple val(state), val(basename), file('?.txt'), val(pubdir)

    output:
    tuple val(state), val(basename), file('*.txt')

    publishDir "$pubdir", mode: 'copy'

    """
    cat *.txt > tmp
    LC_NUMERIC="C" awk '{sum+=\$1} END{print sum}' tmp > $basename
    """

}

