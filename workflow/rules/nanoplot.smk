# This rule runs nanoplot on both the raw long reads and the trimmed reads     
rule nanoplot:
    input:
        longreads = config["long_reads"] + "/{barcode}.fastq.gz",
        trimmed = "results/{prefix}/filtlong/{barcode}/{barcode}.trimmed.fastq.gz",
    output:
        nanoplot_preqc = "results/{prefix}/nanoplot/{barcode}/{barcode}_preqcNanoPlot-report.html"
    #log:
    #    "logs/{prefix}/nanoplot/{barcode}/{barcode}.log"
    params:
        outdir="results/{prefix}/nanoplot/{barcode}",
        prefix="{barcode}",
    singularity:
        "docker://staphb/nanoplot:1.42.0"
    #envmodules:
    #    "Bioinformatics",
    #    "nanoplot"
    shell:
        """
        cat {input.longreads} > /tmp/{params.prefix}.gz && 
        NanoPlot -o {params.outdir} -p {params.prefix}_preqc --tsv_stats --info_in_report --N50 --title {params.prefix}_preqc --fastq /tmp/{params.prefix}.gz && 
        NanoPlot -o {params.outdir} -p {params.prefix}_postqc --tsv_stats --info_in_report --N50 --title {params.prefix}_postqc --fastq {input.trimmed} && rm /tmp/{params.prefix}.gz 
        """
 