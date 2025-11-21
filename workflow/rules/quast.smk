# This rule runs QUAST to assess the quality of genome assemblies
rule quast:
    input:
        flye_assembly = "results/{prefix}/flye/{barcode}/{barcode}_flye_circ.fasta",
        medaka_out = "results/{prefix}/medaka/{barcode}/{barcode}_medaka.fasta",
    output:
        quast_out_flye = "results/{prefix}/quast/{barcode}/{barcode}_flye/report.txt",
        quast_out_medaka = "results/{prefix}/quast/{barcode}/{barcode}_medaka/report.txt",
    params:
        threads = config["ncores"],
        quast_dir = directory("results/{prefix}/quast/{barcode}/{barcode}"),
    log:
        "logs/{prefix}/quast/{barcode}/{barcode}.log"
    singularity:
        "docker://staphb/quast:5.3.0"
    #envmodules:
    #    "Bioinformatics",
    #    "quast"
    shell:
        """
        quast.py {input.flye_assembly} -o {params.quast_dir}_flye &&
        quast.py {input.medaka_out} -o {params.quast_dir}_medaka &>{log}
        """