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

while(<>) {
    chomp;
    my @F=split;
    if (/^sample/) {
	## new file; redo header;
	@header = @F;
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

## print header;
@header = ('sample', sort keys %columnsSeen);
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
