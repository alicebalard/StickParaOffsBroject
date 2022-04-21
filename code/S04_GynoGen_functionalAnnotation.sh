#!/bin/bash
# Functional annotation of gynogen genome
#$ -pe smp 1
#$ -l h_vmem=5G
#$ -l h_rt=1:0:0
#$ -o /data/SBCS-EizaguirreLab/Alice/StickParaBroOff/GIT_StickParaOffsBroject/code/run_gynofuncal.stdout
#$ -e /data/SBCS-EizaguirreLab/Alice/StickParaBroOff/GIT_StickParaOffsBroject/code/run_gynofuncal.stderr
#$ -V

## We assigned functional annotation to genes by searching homology against uniprot database (http://www.uniprot.org) using BLASTp alignments. uniprot_sprot.fasta.gz was retrieved on the 02-Mar-2022 at 18:23

module load blast+
module load anaconda3/2020.02
conda activate agat
module load maker/2.31.9-mpi

DIR=/data/SBCS-EizaguirreLab/Alice/StickParaBroOff/Data/06GynoGen_functionalAnnotation
GFF1=$DIR/Gy_allnoM_rd3.maker_apocrita.noseq_corrected.gff
GYNOGENOME1=$DIR/Gynogen_pchrom_assembly_all.fasta
UNIPROTDB=$DIR/uniprot_sprot.fasta

cd $DIR

## Extract proteins from new genome with AGAT. 

## the GFF output from Maker2 needed to be filtered first. Parsing the gff output from maker2 was extremely slow (took >53 hours), but then it took only 3 minutes on a filtered gff. I needed to remove unnecessary gff entries that maker2 had included (match, expressed_sequence_match, protein_match, contig) (Source: https://www.biostars.org/p/9477640/):
grep -Pv "\tmatch_part\t" $GFF1 | grep -Pv "\tprotein_match\t" | grep -Pv "\texpressed_sequence_match\t" | grep -Pv "\tmatch\t" | grep -Pv "\tcontig\t" > $GFF1.streamlined_for_AGAT.gff

### To extract and translate the coding regions:
agat_sp_extract_sequences.pl -g $GFF1.streamlined_for_AGAT.gff -f $GYNOGENOME1 -p -o $DIR/Gynogen_pchrom_assembly_all_PROTEINS.faa

## Add functional annotations and meta-data
# Run blastp command:

makeblastdb -in $UNIPROTDB -dbtype prot
blastp -query $DIR/Gynogen_pchrom_assembly_all_PROTEINS.faa -db $UNIPROTDB -num_threads 8 -evalue 1e-6 -max_hsps 1 -max_target_seqs 1 -outfmt 6 -out $DIR/output_onlyuniprot.blastp

## Integrate functional annotations into structural annotations. 
maker_functional_gff $UNIPROTDB $DIR/output_onlyuniprot.blastp $GFF1 > $DIR/Gy_allnoM_rd3.maker_apocrita.noseq_corrected_CURATED.gff
