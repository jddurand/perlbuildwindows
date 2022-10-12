#!env perl
use strict;
use HTTP::Tiny;

my $url = shift || die "No URL\n";

my $response = HTTP::Tiny->new->get($url);
 
die "Failed!\n" unless $response->{success};
 
print $response->{content} // '';

exit 0;
