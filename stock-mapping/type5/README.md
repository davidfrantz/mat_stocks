# Mapping of material stocks

- ``stock-mapping_jpn.nf``: stock mapping script as used for JPN (Fishman et al. in prep).

- run like this: 

```
#export _JAVA_OPTIONS="-Xmx500G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
cd /data/Jakku/mat_stocks/stock/JPN
nextflow -Dnxf.pool.type=sync run -resume /data/Jakku/mat_stocks/git/mat_stocks/stock-mapping/type5/stock-mapping_jpn.nf -w /data/Alderaan/stock -with-dag flowchart.html -with-report report.html
```

TODO:

in area_rail: 

different aggregation here, new shinkansen category, and narrow_gauges go to the railway category
 1  rail                         -> shinkansen
 7  narrow_gauge                 -> railway
 