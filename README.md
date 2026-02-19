# AMR Mapping & Pileup Workflow

A lightweight workflow for aligning paired-end FASTQ reads against an AMR reference using **BWA-MEM** and generating pileup statistics using **BBTools (pileup.sh)**.

This pipeline can be executed either:

- ✅ Using a Bash script  
- ✅ Using a Go program  

---

## 📌 Features

- Paired-end FASTQ processing
- Multi-threaded alignment using `bwa mem`
- Automated detection of `_R1_001.fastq.gz` files
- Automatic matching of R2 pairs
- Pileup generation using `pileup.sh`
- Per-sample logging of pileup output
- Simple and minimal dependencies

---

## 📂 Expected Input Structure

Your FASTQ directory should look like:

```
fastq_directory/
├── Sample1_R1_001.fastq.gz
├── Sample1_R2_001.fastq.gz
├── Sample2_R1_001.fastq.gz
├── Sample2_R2_001.fastq.gz
```

---

## 🔧 Requirements

Install dependencies using Conda:

```bash
conda install -c bioconda bwa
conda install -c agbiome bbtools
```

Ensure `go` is installed if running the Go version.

---

## 🧬 Reference Preparation

Index your AMR reference FASTA file before running the workflow:

```bash
bwa index AMR-reference.fasta
```

---

# ▶️ Running the Workflow

---

## Option 1: Using the Bash Script

Make the script executable:

```bash
chmod +x run_pipeline_threads.sh
```

Run the workflow:

```bash
./run_pipeline_threads.sh <fastq_directory> AMR-reference.fasta <threads>
```

### Example

```bash
./run_pipeline_threads.sh ./fastq_files AMR-reference.fasta 16
```

---

## Option 2: Using the Go Program

Run directly:

```bash
go run finalrun_pileup.go <fastq_directory> AMR-reference.fasta <threads>
```

### Example

```bash
go run finalrun_pileup.go ./fastq_files AMR-reference.fasta 16
```

---

# 📦 Output Files

For each sample, the following files are generated:

| File | Description |
|------|-------------|
| `<sample>.sam` | BWA alignment output |
| `<sample>.txt` | Pileup results |
| `<sample>-pileup-output.txt` | Combined stdout and stderr logs from `pileup.sh` |

---

# ⚙️ Parameters

| Argument | Description |
|----------|-------------|
| `<fastq_directory>` | Path to directory containing paired FASTQ files |
| `AMR-reference.fasta` | Indexed reference FASTA file |
| `<threads>` | Number of CPU threads for BWA |

---

# ⚠️ Notes

- FASTQ files must follow Illumina naming convention:
  ```
  *_R1_001.fastq.gz
  *_R2_001.fastq.gz
  ```
- The script automatically skips samples if R2 is missing.
- Ensure sufficient disk space — `.sam` files can be large.
- For large datasets, consider converting SAM to BAM to reduce storage usage.

---

# 🚀 Recommended Optimization (Optional)

Instead of generating `.sam` files, you may directly pipe to BAM:

```bash
bwa mem -t 16 AMR-reference.fasta R1.fastq.gz R2.fastq.gz | samtools view -Sb - > sample.bam
```

This reduces disk usage significantly.

---
