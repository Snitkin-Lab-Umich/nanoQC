# This rule runs mlst on the medaka polished assembly to determine the sequence type.  
rule mlst:
    input:
        medaka_out = "results/{prefix}/medaka/{barcode}/{barcode}_medaka.fasta"
    output:
        mlst_report = "results/{prefix}/mlst/{barcode}/report.tsv",
    log:
        "logs/{prefix}/mlst/{barcode}/{barcode}.log"
    singularity:
        "docker://staphb/mlst:2.23.0-2024-12-31"
    #envmodules:
    #    "Bioinformatics",
    #    "mlst"
    shell:
        "mlst {input.medaka_out} > {output.mlst_report} 2>{log}"
  