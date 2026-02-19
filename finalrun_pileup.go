package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func main() {
	if len(os.Args) != 4 {
		log.Fatalf("Usage: %s <fastq directory> <AMR-reference> <threads>", os.Args[0])
	}

	fastqDir := os.Args[1]
	amrReference := os.Args[2]
	threads := os.Args[3]

	files, err := ioutil.ReadDir(fastqDir)
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
			pileupOutputFile := fmt.Sprintf("%s-pileup-output.txt", baseName)

			// Execute bwa mem with specified number of threads
			cmd := exec.Command("bwa", "mem", "-t", threads, amrReference, r1File, r2File)
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
			cmd = exec.Command("pileup.sh", fmt.Sprintf("in=%s", samFile), fmt.Sprintf("out=%s", txtFile))
			var stdout, stderr bytes.Buffer
			cmd.Stdout = &stdout
			cmd.Stderr = &stderr
			err = cmd.Run()
			if err != nil {
				log.Printf("Error running pileup.sh: %v", err)
				continue
			}

			// Save both stdout and stderr to a file
			combinedOutput := append(stdout.Bytes(), stderr.Bytes()...)
			err = ioutil.WriteFile(pileupOutputFile, combinedOutput, 0644)
			if err != nil {
				log.Printf("Error writing pileup output to file: %v", err)
			}
		}
	}
}