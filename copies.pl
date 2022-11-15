#!/usr/bin/env perl
# Generates a Makefile that copies the source files read from stdin to site
# usage: build/copies.pl site/ < build/copies.txt > copies.mk

use strict;
use warnings;

if ($#ARGV != 0) {
	printf STDERR "usage: build/copies.pl <SITEDIR>\n";
	exit 1;
}

# The first target in a makefile specifies all the targets to be built by
# default. We won't know all of the target names until we are finished reading
# from stdin, so all refers to a target that we are able to write at the
# end of the output.
print "all: _all\n\n";
my $_all = "_all:";

while (my $prereq = <STDIN>) {
	chomp $prereq;
	my $target = $prereq;
	$target =~ s/^src/$ARGV[0]/;
	print "$target: $prereq\n\tcp \$< \$@\n\n";
	$_all .= " $target";
}

print "$_all\n";
