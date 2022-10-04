#!env perl
use strict;
use diagnostics;
use Text::Patch qw/patch/;

my $srcpath = shift;
my $diffpath = shift;
my $dstpath = shift;

my $fh; 

open($fh, '<', $srcpath) or die "Cannot open $srcpath, $!";
my $source = do { local $/; <$fh> };
close($fh) or warn "Cannot close $srcpath, $!";

open($fh, '<', $diffpath) or die "Cannot open $diffpath, $!";
my $diff = do { local $/; <$fh> };
close($fh) or warn "Cannot close $diffpath, $!";

my $output = patch($source, $diff, STYLE => "Unified" );

open($fh, '>', $dstpath) or die "Cannot open $dstpath, $!";
print $fh $output;
close($fh) or warn "Cannot close $dstpath, $!";

exit(0);
