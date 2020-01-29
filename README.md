# GBS_preprocessing
Running cutadapt and process_radtags via HTCondor on the UW Madison Center for High Throughput Computing (CHTC) pool.

Original version created for the DoB/DataCleaning Project;  
Goal:  Refactor to make it more widely applicable.

June 18, 2018
Steve Goldstein

The data/ subdirectory has 59 tar files, one for each of the 59 lanes
of sequencing. Each of the tar files contains many (often 96)
individual FastQ files; in total, there are 5495 FastQ files in the
archive, one for each well of each run, including the controls, water,
etc.

The bash script

    bin/readsToSamples.sh
    
takes as input one FastQ file from a single lane of sequences, trims
adapters, demultiplexes, and renames the demultiplexed sample FastQ
files as specified in the HTC run key files (02-metaData).  These
renamed sample files are bundled into a single tar file.

This processing was done on the CHTC pool, using the gluster file
system for staging of the large input and output files.
