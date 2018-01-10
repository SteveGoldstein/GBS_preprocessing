#!/bin/bash

## Usage:
#      executable = bin/readsToSamples.sh
#      args       = <FastQ File>  <RESULTSDIR>  

## Remove adapters from the FastQ file from one lane of sequencing
##  and demultiplex.
## Write the output to the local disk on the execute node and then
##  copy the output to the gluster shared file system

#######################################
## Set up the environment
tar zxf python277.withCutadapt.tar.gz
rm python277.withCutadapt.tar.gz

### Envar needed for cutadapt
export PATH=$(pwd)/python277/bin:$PATH:.
######################################
cluster=$1
shift

process=$1
shift

sampleFQ=$1
shift

resultDir=$1
mkdir results

cp $sampleFQ .
sampleFQ=$(basename $sampleFQ)
renameScript=${sampleFQ/\.fastq.gz/.rename.sh}
resultsTarFile=${sampleFQ/\.fastq.gz/.$cluster.$process.tgz}
samplesTarFile=${sampleFQ/\.fastq.gz/.samples.$cluster.$process.tgz}

gunzip -c $sampleFQ > reads.fastq
rm $sampleFQ

nohup ./cutadapt -a GCWGAGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGATCTCGTATGCCGTCTTCTGCTTG -O 4 -o results/cutadaptOut.fastq reads.fastq > results/cutadapt.log

rm reads.fastq

BASEDIR=$(pwd)
INPUT=$BASEDIR/results/cutadaptOut.fastq
SAMPLEDIR=$BASEDIR/results/samples
mkdir $SAMPLEDIR

for i in 8 7 6 5 4;
	 
do
    echo "doing barcodes$i"
    OUTDIR=$(pwd)/results/barcode$i
    mkdir $OUTDIR
    process_radtags -f $INPUT -o $OUTDIR -b apeKI_barcode$i.txt  -c -q -e apeKI -D >&  $OUTDIR/process_radtags.err

    mv $OUTDIR/$(basename $INPUT).discards $OUTDIR/barcode$i.discards.fq
    rm $INPUT
    INPUT=$OUTDIR/barcode$i.discards.fq
    gzip $OUTDIR/sample*.fq
    mv $OUTDIR/sample*.fq.gz $SAMPLEDIR
done
rm $INPUT

cd $SAMPLEDIR
$BASEDIR/$renameScript
cd ..
tar zcf $samplesTarFile samples/
mv $samplesTarFile $resultsDir
cd $BASEDIR

#tar zcf $resultsTarFile results/
#mv $resultsTarFile $resultDir


