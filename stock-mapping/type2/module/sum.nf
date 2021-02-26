// image sum

process sum {

    input:
    tuple file(input), val(pubdir)

    output:
    file('*.txt')

    publishDir "$pubdir", mode: 'copy'

    """
    nodata=\$(gdalinfo $input | grep NoData | head -n 1 |  sed 's/ //g' | cut -d '=' -f 2)
    imgsum $input \$nodata > $input".txt"
    """

}

