package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func main() {
	if len(os.Args) != 4 {
		log.Fatalf("Usage: %s <fastq directory> <AMR-reference> <ref fasta file>", os.Args[0])
	}

	fastqDir := os.Args[1]
	amrReference := os.Args[2]
	refFasta := os.Args[3]

	files, err := os.ReadDir(fastqDir)
	if err != nil {
		log.Fatal(err)
	}

	for _, file := range files {
		if strings.Contains(file.Name(), "_R1_") && strings.HasSuffix(file.Name(), ".fastq.gz") {
			baseName := strings.TrimSuffix(file.Name(), "_R1_001.fastq.gz")
			r1File := filepath.Join(fastqDir, file.Name())
			r2File := filepath.Join(fastqDir, fmt.Sprintf("%s_R2_001.fastq.gz", baseName))
			samFile := fmt.Sprintf("%s.sam", baseName)
			txtFile := fmt.Sprintf("%s.txt", baseName)

			// Execute bwa mem
			cmd := exec.Command("bwa", "mem", amrReference, r1File, r2File)
			sam, err := os.Create(samFile)
			if err != nil {
				log.Printf("Error creating SAM file: %v", err)
				continue
			}
			cmd.Stdout = sam
			err = cmd.Run()
			if err != nil {
				log.Printf("Error running bwa mem: %v", err)
				continue
			}

			// Execute pileup.sh
			cmd = exec.Command("pileup.sh", fmt.Sprintf("in=%s", samFile), fmt.Sprintf("out=%s", txtFile), fmt.Sprintf("ref=%s", refFasta))
			err = cmd.Run()
			if err != nil {
				log.Printf("Error running pileup.sh: %v", err)
				continue
			}
		}
	}
}

