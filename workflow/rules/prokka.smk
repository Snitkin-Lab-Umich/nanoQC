# This is the prokka rule to annotate the medaka assembly
rule prokka:
    input:
        medaka_wo_circ = "results/{prefix}/medaka/{barcode}/{barcode}_medaka_wo_circ.fasta", # Note: medaka_wo_circ is used to generate the prokka annotation without circularization
        # medaka = "results/{prefix}/medaka/{barcode}/{barcode}_medaka.fasta" # Note: medaka is used to generate the prokka annotation with circularization
    output:
        medaka_annotation = "results/{prefix}/prokka/{barcode}/{barcode}_medaka.gff",
    params:
        threads = config["ncores"],
        prefix = "{barcode}",
        #options = config["prokka_options"],
        prokka_dir = directory("results/{prefix}/prokka/{barcode}"),
    log:
        "logs/{prefix}/prokka/{barcode}/{barcode}.log"
    singularity:
        "docker://staphb/prokka:1.14.6"
    #envmodules:
    #    "Bioinformatics",
    #    "prokka"
    shell:
        "prokka --force --kingdom Bacteria --rfam --strain {params.prefix} -outdir {params.prokka_dir} -prefix {params.prefix}_medaka {input.medaka_wo_circ} &>{log}"
