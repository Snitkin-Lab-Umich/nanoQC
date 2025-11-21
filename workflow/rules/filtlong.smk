# This rule performs long read filtering using filtlong to clean the input reads before further processing.
rule filtlong:
    input:
        longreads = config["long_reads"] + "/{barcode}.fastq.gz"
    output:
        trimmed = "results/{prefix}/filtlong/{barcode}/{barcode}.trimmed.fastq.gz"
    #log:
    #    "logs/{prefix}/filtlong/{barcode}/{barcode}.log"   
    singularity:
        "docker://staphb/filtlong:0.2.1"
    #envmodules:
    #    "Bioinformatics",
    #    "filtlong"
    shell:
        "filtlong --min_length 1000 --keep_percent 95 {input.longreads}  --mean_q_weight 10 --target_bases 500000000 | gzip > {output.trimmed}"
  