DataCleaning/03-sampleFastQFiles

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
=============================================================

filepaths on submit-3.chtc.wisc.edu:

  This dir structure was originally in a local git repo at
	  
  	  /home/sgoldstein/Projects/IdentifyGBSSamples/rbcl

  For this cleaned up version, the repo was cloned to

	  /home/sgoldstein/Projects/IdentifyGBSSamples/DataCleaning/03-sampleFastQFiles




	
	
