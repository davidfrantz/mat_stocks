# Mapping of material stocks

- ``stock-mapping_var2.nf``: stock mapping script as used for USA (Frantz et al. in prep).

- run like this: 

```
nextflow -Dnxf.pool.type=sync run -resume /home/frantzda/mat_stocks/stock-mapping/nextflow_dsl_2/stock-mapping_usa.nf -w /data/Alderaan/stock -with-dag flowchart.html -with-report report.html -with-timeline timeline.html
```
