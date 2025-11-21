# This rule runs skani to identify the closest reference genome       
rule skani:
    input:
        medaka_out = "results/{prefix}/medaka/{barcode}/{barcode}_medaka.fasta"
    output:
        skani_output = "results/{prefix}/skani/{barcode}/{barcode}_skani_output.txt"
    params:
        skani_ani_db = config["skani_db"],
        threads = 4
    log:
        "logs/{prefix}/skani/{barcode}/{barcode}.log"
    singularity:
        "docker://staphb/skani:0.2.2"
    shell:
        "skani search {input.medaka_out} -d {params.skani_ani_db} -o {output.skani_output} -t {params.threads} 2>{log}"
       
