#!env perl
use strict;
use diagnostics;
use CPAN;
use CPAN::Version;
use POSIX qw/EXIT_SUCCESS EXIT_FAILURE/;

my $name = shift;

#
# Lookup $name in CPAN
#
my $any = CPAN::Shell->expandany($name);
if (! $any) {
    print "Nothing like $name in CPAN\n";
	exit(0);
}

#
# We want to have a CPAN::Module from $any
#
my $mod;
my $modulewantedversion;

if ($any->isa('CPAN::Distribution')) {
	#
	# Guess an id
	#
	my $dist_base_id = $any->base_id();
	if ($dist_base_id =~ /^(.+)\-([0-9._]+)$/) {
		my $modulename = $1;
		$modulewantedversion = $2;

		$modulename =~ s/\-/::/g;
		#
		# Guess module from distribution
		#
		#
		# Look if there is a module with this specific version
		#
		my $modulecpanversion;
		my $moduleinstversion;
        foreach (CPAN::Shell->expand("Module", $modulename)) {
			next unless $_->id eq $modulename;

			$mod = $_;
			$modulecpanversion = $_->cpan_version || '';
			$moduleinstversion = $_->inst_version || '';
			
			# MakeMaker convention for undefined $VERSION:
			$modulecpanversion = '' if $modulecpanversion eq 'undef';
			$moduleinstversion = '' if $moduleinstversion eq 'undef';
			
			last;
		}
		if (0) {
			#
			# Debug statements
			#
			if (! $mod) {
				print "... Got distribution $dist_base_id, but module $modulename at version $modulewantedversion not found\n";
			} else {
				if ($moduleinstversion) {
					print "... Got distribution $dist_base_id and module $modulename at version $modulewantedversion, installed version is $moduleinstversion\n";
				} else {
					print "... Got distribution $dist_base_id and module $modulename at version $modulewantedversion, no installed version\n";
				}
			}
		}
	} else {
	    print "... Got distribution base_id=$dist_base_id but failed to get module name and version\n";
	}
} elsif ($any->isa('CPAN::Module')) {
	$mod = $any;
	$modulewantedversion = $mod->cpan_version || '';
	$modulewantedversion = '' if $modulewantedversion eq 'undef';
}

if (! $mod) {
	print "Failed to get a module from $name\n";
	exit(1);
}

my $id           = eval { $mod->id() }           || die "Failed to get module id ?";
my $inst_version = eval { $mod->inst_version() } || '';
my $cpan_version = eval { $mod->cpan_version() } || die "Failed to get cpan version ?";
if ($inst_version) {
    print "... Processing module $id, CPAN version $cpan_version, wanted version $modulewantedversion, installed version $inst_version\n";
} else {
    print "... Processing module $id, CPAN version $cpan_version, wanted version $modulewantedversion, no installed version\n";
}

my $ok;
if (!$inst_version || !$modulewantedversion || CPAN::Version->vcmp($inst_version, $modulewantedversion) < 0) {
	$ok = CPAN::Shell->install($name);
} else {
	$ok = 1;
}

exit($ok ? EXIT_SUCCESS : EXIT_FAILURE);
