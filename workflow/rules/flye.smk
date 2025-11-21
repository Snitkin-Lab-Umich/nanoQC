# The rules to run Flye assembler on trimmed Nanopore reads and add circularity info to contig headers       
rule flye:
    input:
        trimmed = "results/{prefix}/filtlong/{barcode}/{barcode}.trimmed.fastq.gz"
    output:
        assembly = "results/{prefix}/flye/{barcode}/{barcode}_flye.fasta",
    params:
        assembly_dir = "results/{prefix}/flye/{barcode}/",
        size = config["genome_size"],
        threads = config["threads"],
        #flye_options = config["flye_options"],
        prefix = "{barcode}",
    #log:
    #    "logs/{prefix}/flye/{barcode}/{barcode}_flye.log" # Flye has its own log
    singularity:
        "docker://staphb/flye:2.9.5"
    #envmodules:
    #    "Bioinformatics",
    #    "flye"
    shell:   
        """
        flye --nano-hq {input.trimmed} -g {params.size} -o {params.assembly_dir} -t {params.threads} --debug && 
        cp {params.assembly_dir}/assembly.fasta {params.assembly_dir}/{params.prefix}_flye.fasta 
        """
     
rule flye_add_circ:
    input:
        flye_assembly = "results/{prefix}/flye/{barcode}/{barcode}_flye.fasta",
    output:
        assembly = "results/{prefix}/flye/{barcode}/{barcode}_flye_circ.fasta",
    params:
        assembly_dir = "results/{prefix}/flye/{barcode}/",
        #size = config["genome_size"],
        #threads = config["threads"],
        #flye_options = config["flye_options"],
        prefix = "{barcode}",
    #log:
    #    "logs/{prefix}/flye/{barcode}/{barcode}_flye_add_circ.log",
    run:
        shell("cp {params.assembly_dir}/{params.prefix}_flye.fasta {params.assembly_dir}/{params.prefix}_flye_circ.fasta")
        # Load and process the assembly info
        assembly_info = pd.read_csv("%s/assembly_info.txt" % params.assembly_dir, sep='\t', header=0)
        assembly_info["circular"] = np.where(assembly_info["circ."] == "Y", "true", "false")
        # Build a replacement dictionary: {original_seq_name: new_seq_name}
        replacements = {
            row['#seq_name']: f"{params.prefix}_{row['#seq_name']};circular={row['circular']}"
            for _, row in assembly_info.iterrows()
        }
        with open(f"{params.assembly_dir}/{params.prefix}_flye.fasta", "r") as infile, open(f"{params.assembly_dir}/{params.prefix}_flye_circ.fasta", "w") as outfile:
            for line in infile:
                if line.startswith(">"):
                    seq_name = line[1:].strip()
                    new_name = replacements.get(seq_name, seq_name)
                    outfile.write(f">{new_name}\n")
                else:
                    outfile.write(line)
 