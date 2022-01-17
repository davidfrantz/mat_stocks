# Mapping of material stocks

- ``stock-mapping_jpn.nf``: stock mapping script as used for JPN (Fishman et al. in prep).

- run like this: 

```
#export _JAVA_OPTIONS="-Xmx500G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
cd /data/Jakku/mat_stocks/stock/JPN
nextflow -Dnxf.pool.type=sync run -resume /data/Jakku/mat_stocks/git/mat_stocks/stock-mapping/type5/stock-mapping_jpn.nf -w /data/Alderaan/stock -with-dag flowchart.html -with-report report.html
```

Note: only used one MI for airport infrastructure. Given the small mass, it was not worth to change the workflow

Note: for parking and impervious: used MI of tertiary road

Note: trunk roads were put in motorway category

Note: MI for trains was also used for other rails
