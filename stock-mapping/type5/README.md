# Mapping of material stocks

- ``stock-mapping_jpn.nf``: stock mapping script as used for JPN (Fishman et al. in prep).

- run like this: 

```
#export _JAVA_OPTIONS="-Xmx500G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
cd /data/Jakku/mat_stocks/stock/JPN
nextflow -Dnxf.pool.type=sync run -resume /data/Jakku/mat_stocks/git/mat_stocks/stock-mapping/type5/stock-mapping_jpn.nf -w /data/Alderaan/stock -with-dag flowchart.html -with-report report.html
```

Note: for parking and impervious: used MI of local road

