# Mapping of material stocks

- ``stock-mapping_var2.nf``: stock mapping script as used for GBR (Wiedenhofer et al. in prep).

**Important:**
Input data for Northern Ireland are different. This is why Northern Ireland was not included in the GBR run, but added to the IRL run. (building factor = 0.43)

- run like this: 

```
#export _JAVA_OPTIONS="-Xmx500G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
cd /data/Jakku/mat_stocks/stock/GBR
nextflow -Dnxf.pool.type=sync run -resume /data/Jakku/mat_stocks/git/mat_stocks/stock-mapping/type3/stock-mapping_gbr.nf -w /data/Alderaan/stock -with-dag flowchart.html -with-report report.html
```
