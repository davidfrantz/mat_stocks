# Mapping of material stocks

- ``stock-mapping_irl.nf``: stock mapping script as used for IRL (Wiedenhofer et al. in prep).

**Important:**
Input data for Northern Ireland are different. This is why Northern Ireland was not included in the GBR run, but added to the IRL run. (building factor = 0.49)

- run like this: 

```
#export _JAVA_OPTIONS="-Xmx500G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
cd /data/ahsoka/gi-sds/hub/mat_stocks/stock/IRL
nextflow -Dnxf.pool.type=sync run -resume /data/ahsoka/gi-sds/hub/mat_stocks/git/mat_stocks/stock-mapping/type4/stock-mapping_irl.nf -w /data/eocps010/gi-sds/nxf_irl-mass -with-dag flowchart.html -with-report report.html
```
