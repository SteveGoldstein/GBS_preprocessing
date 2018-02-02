#!/usr/bin/perl -w

## usage: bin/mergeAlignments <alignmentCount tables>   >  <merged file>
## Input: 2 or more output files from bin/countAlignments;
## Output:  1 file combining all the rows.

## The only tricky part:  each file may have different columns.

use strict;
use Carp;
use English;
use Getopt::Long;


GetOptions (

            );

my @header;
my @rows;
my %columnsSeen;
my $firstErrorInFile = 1;

while(<>) {
    chomp;
    my @F=split;
    if (/^sample/) {
	if (/^sample_/) {
	    if ($firstErrorInFile) {
		carp "Sample not renamed in $ARGV\n$_\n";
		$firstErrorInFile = 0;
	    }
	    next;
	}
	## new file; redo header;
	@header = @F;
	$firstErrorInFile = 1;
	map{$columnsSeen{$_} = 1} @header[1..$#header];
	next;
    }
    my $thisRow;
    croak "Parse error \n$_\n"
	unless ($#F == $#header);
    my $sample = $F[0];
    map {$thisRow->{$header[$_]} = $F[$_]} (1..$#F);
    push @rows, [$sample,$thisRow];
}

my @speciesWithAlignments = keys %columnsSeen;
@speciesWithAlignments = sort @speciesWithAlignments;
@header = ('sample', @speciesWithAlignments);
print join("\t", @header), "\n";
foreach my $row (sort {$a->[0] cmp $b->[0]} @rows) {
    my $sample = $row->[0];
    my $counts = $row->[1];
    my @out = ($sample);
    foreach my $col (@header[1..$#header]) {
	if (exists $counts->{$col}) {
	    push @out, $counts->{$col};
	}
	else {
	    push @out, 0;
	} ## if/else
    } ## foreach col
    print join ("\t",@out), "\n";
}


__END__
