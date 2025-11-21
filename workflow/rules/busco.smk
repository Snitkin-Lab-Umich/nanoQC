# This rule runs BUSCO on both medaka and flye assemblies with retries and saves the outputs
rule busco:
    input:
        medaka_assembly = "results/{prefix}/medaka/{barcode}/{barcode}_medaka.fasta",
        flye_assembly = "results/{prefix}/flye/{barcode}/{barcode}_flye_circ.fasta",
    output:
        busco_flye_medaka_out = f"results/{{prefix}}/busco/{{barcode}}/{{barcode}}.medaka/busco_medaka.txt", 
        busco_flye_assembly_out = f"results/{{prefix}}/busco/{{barcode}}/{{barcode}}.flye_assembly/busco_flye_assembly.txt",     
    params:
        busco_outpath = f"results/{{prefix}}/busco/{{barcode}}/{{barcode}}",
        medaka_busco_out = f"short_summary.specific.bacteria_odb12.{{barcode}}.medaka.txt",
        flye_assembly_busco_out = f"short_summary.specific.bacteria_odb12.{{barcode}}.flye_assembly.txt",
        threads = config["ncores"],
    #log:
    #    "logs/{prefix}/busco/{barcode}/{barcode}.log" # BUSCO has it own logs folder
    singularity:
        "docker://staphb/busco:5.8.2-prok-bacteria_odb12_2024-11-14"
    #envmodules:
    #    "Bioinformatics",
    #    "busco"
    shell:
        """
        set -e

        # Run BUSCO on medaka assembly with retry
        for i in {{1..2}}; do
            echo "Attempt $i: Running BUSCO on medaka assembly"
            busco -f -i {input.medaka_assembly} -m genome -l bacteria_odb12 -o {params.busco_outpath}.medaka && break || echo "BUSCO medaka attempt $i failed"
            sleep 10
        done

        # Check if BUSCO medaka succeeded
        if [ ! -f {params.busco_outpath}.medaka/{params.medaka_busco_out} ]; then
            echo "BUSCO medaka failed after 2 attempts" >&2
            exit 1
        fi

        cp {params.busco_outpath}.medaka/{params.medaka_busco_out} {params.busco_outpath}.medaka/busco_medaka.txt

        # Run BUSCO on flye assembly with retry
        for i in {{1..2}}; do
            echo "Attempt $i: Running BUSCO on flye assembly"
            busco -f -i {input.flye_assembly} -m genome -l bacteria_odb12 -o {params.busco_outpath}.flye_assembly && break || echo "BUSCO flye attempt $i failed"
            sleep 10
        done

        # Check if BUSCO flye succeeded
        if [ ! -f {params.busco_outpath}.flye_assembly/{params.flye_assembly_busco_out} ]; then
            echo "BUSCO flye failed after 2 attempts" >&2
            exit 1
        fi

        cp {params.busco_outpath}.flye_assembly/{params.flye_assembly_busco_out} {params.busco_outpath}.flye_assembly/busco_flye_assembly.txt
        """
