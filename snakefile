# Workflow de Análise de RNA-Seq - Tambaqui (Colossoma macropomum)
# Autor: Érica Souza
# Ferramenta: Snakemake

configfile: "config.yaml"

rule all:
    input:
        "results/multiqc/multiqc_report.html"

# Passo 1: Controle de Qualidade
rule fastqc:
    input:
        "data/raw/{sample}.fastq.gz"
    output:
        html="results/fastqc/{sample}_fastqc.html",
        zip="results/fastqc/{sample}_fastqc.zip"
    threads: 4
    shell:
        "fastqc {input} -t {threads} --outdir results/fastqc/"

# Passo 2: Trimming (Limpeza)
rule trimmomatic:
    input:
        "data/raw/{sample}.fastq.gz"
    output:
        "results/trimmed/{sample}_trimmed.fastq.gz"
    shell:
        "trimmomatic SE -phred33 {input} {output} ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36"

# Passo 3: Relatório Final Agregado
rule multiqc:
    input:
        expand("results/fastqc/{sample}_fastqc.html", sample=config["samples"])
    output:
        "results/multiqc/multiqc_report.html"
    shell:
        "multiqc results/ -o results/multiqc/"
