# Mapping of material stocks

- ``stock-mapping_jpn.nf``: stock mapping script as used for JPN (Fishman et al. in prep).

- run like this: 

```
#export _JAVA_OPTIONS="-Xmx500G -XX:+UnlockExperimentalVMOptions -XX:+UseZGC"
cd /data/Jakku/mat_stocks/stock/JPN
nextflow -Dnxf.pool.type=sync run -resume /data/Jakku/mat_stocks/git/mat_stocks/stock-mapping/type5/stock-mapping_jpn.nf -w /data/Alderaan/stock -with-dag flowchart.html -with-report report.html
```

TODO: how many wooden buildings are >10m? @FS

TODO: height classes and class catalogue
      wooden buildings
        0-10
      hard buildings
        0-10
        10-30
        30-75
        >75

      Two Options:
      just use wooden buildings with original height
      wooden buildings >10m or 15m --> hard buildings

TODO: new micro-zones
      delivered by Tomer
      zones done by Franz? (check)
      put in config

___________________________________________
TODO: enable mass again
TODO: scale building mass with volume only!
