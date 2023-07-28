# Mapping of material stocks

- ``stock-mapping_uga.nf``: stock mapping script as used for UGA (TBD et al. in early prep).

- run like this: 

```
#export _JAVA_OPTIONS="-Xmx500G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
cd /data/Jakku/mat_stocks/stock/UGA
nextflow -Dnxf.pool.type=sync run -resume /data/Jakku/mat_stocks/git/mat_stocks/stock-mapping/type6/stock-mapping_uga.nf -w /data/Alderaan/stock -with-dag flowchart.html -with-report report.html
```

TODO:

probably substitute MS building footprints with fractional cover
if so, use area threshold to clean at lower end
