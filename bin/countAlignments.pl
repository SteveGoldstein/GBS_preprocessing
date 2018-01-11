#!/usr/bin/perl -w

## Align sample reads to rbcl reference and print summary table.

## Steps: 
##  1. Extract the sample FastQ files from a collection of tar files;
##  2. Align each to the rbcl reference;
##  3. Parse the alignments;
##  4. Print a table with counts of hits to each reference for each sample.

use strict;
use Carp;
use English;
use Getopt::Long;
use File::Basename;

##############################################
#### Set up for CHTC
## if this is CHTC, cp the file from gluster and use the local bwa and samtools and add /bin to $PATH
my $isCHTC = 0;
my $host = `hostname -A`;
if ($host =~ /chtc\.wisc.edu/) {
    $isCHTC = 1;
    $ENV{PATH} .= ':/bin:./';
}
##############################################

my @tarFile;
my $referenceFastA = '/home/sgoldstein/Projects/IdentifyGBSSamples/rbcl/ApeKI/rbcl.fasta';

GetOptions (
    'tarFile=s'         => \@tarFile,
    'referenceFastA=s'  => \$referenceFastA,
          );


## allow for comma-separated or redundant list
@tarFile = split(/,/, join(",", @tarFile));
## add any addition args on the cmd line to the tar file list;
push @tarFile, @ARGV;

my %alignments;
foreach my $tarFile (@tarFile) {
    my $localTar = $tarFile;
    if ($isCHTC) {
	$localTar = basename($localTar);
	`cp $tarFile $localTar`;
    }

    `tar zxf $localTar`;
    if ($localTar ne $tarFile) {
	`rm $localTar`;
    }
    my $sampleDir;
    if (-d 'samples') {
	$sampleDir = 'samples';
    }
    elsif (-d 'results/samples') {
	$sampleDir = 'results/samples';
    }
    else {
	croak "Can't find sample dir";
    }
    
    opendir SAMPLEDIR, $sampleDir;
    my @fqFiles = grep { /fq.gz$/ } readdir SAMPLEDIR;
    closedir SAMPLEDIR;
    @fqFiles = map{"$sampleDir/$_"} @fqFiles;

    foreach my $fqFile (@fqFiles) {
	my $alignmentCounts = alignAndParse($fqFile);
	my $sampleName = basename($fqFile, '.fq.gz');
	$alignments{$sampleName} = $alignmentCounts;
	unlink $fqFile;
    } ## foreach fqFile
    `rm -rf $sampleDir`;
} ## foreach tarFile

my @table = formatAlignments(\%alignments);
foreach my $row (@table) {
    print join("\t", @$row), "\n";
}
#######################
## format alignments
sub formatAlignments {
    my $alignments = shift;

    ## Make a list of all the reference sequences with at least one alignment;
    my %referenceSeqs;
    foreach my $sample (keys %$alignments) {
	my $alignmentCounts = $alignments->{$sample};
	map {$referenceSeqs{$_} = 1} (keys %$alignmentCounts);
    } ## foreach sample
    my @referenceSeqs = sort keys %referenceSeqs;

    ### Now compile a list of alignments
    my @alignmentTable = (["sample", @referenceSeqs]);
    foreach my $sample (sort
			{lc $a cmp lc $b || $a cmp $b}
			keys %$alignments) {

	my @sampleAlignmentCounts = ($sample);
	foreach my $ref (@referenceSeqs) {
	    push @sampleAlignmentCounts, $alignments->{$sample}->{$ref}//0;
	} ## foreach ref
	push @alignmentTable, \@sampleAlignmentCounts;
    } ## foreach sample
    return @alignmentTable;
} ## sub formatAlignments

############################################
sub alignAndParse {
    my $file = shift;

    my $bwaSamtoolsPipe = join(' | ', 
			       "bwa mem $referenceFastA -",
			       "samtools view -h -bT $referenceFastA -F 4 -o -",
			       'samtools view',
	);

    open ALIGN, "zcat -f $file | $bwaSamtoolsPipe |";
    my %counts;
    while(<ALIGN>) {
	chomp;
	my @F = split;
	$counts{$F[2]} ++;
    }
    close ALIGN;
    return \%counts;
} ## sub alignAndParse
 
__END__

(bwa mem ApeKI/rbcl.fasta $sample | samtools view -h -bT ApeKI/rbcl.fasta -F 4 -o - |samtools view |perl -nale '$h{$F[2]}++; END{map{push @a, [$_, $h{$_}]} keys %h; @a = sort {$b->[1] <=> $a->[1] || $a->[0] cmp $b->[0]} @a; map{print "@$_"} @a;}')  2> err |less -S


files for test:
/mnt/gluster/sgoldstein/Projects/IdentifyGBSSamples/samples/run313.Givnish-ApeKI-test_NoIndex_L006_R2.samples.104669372.1.tgz
/mnt/gluster/sgoldstein/Projects/IdentifyGBSSamples/test/samples/run505.RHCA-ALPE_NoIndex_L003_R1.100kReads.104551527.0.tgz


