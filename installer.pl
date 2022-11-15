#!env perl
use strict;
use diagnostics;
use CPAN;
use CPAN::Version;
use POSIX qw/EXIT_SUCCESS EXIT_FAILURE/;

my $ok = 1;
foreach (@ARGV) {
	if (! do_one($_)) {
		$ok = 0;
		last;
	}
}

exit($ok ? EXIT_SUCCESS : EXIT_FAILURE);

# ========================================================================
# do_one returns  0 in case of fatal error
#                 1 in case of success
#                -1 in case of non fatal error, cases are:
#                   + Nothing like this in CPAN
#                   + Cannot get a module from found distribution in CPAN
# ========================================================================
sub do_one {
	my $name = shift;

	#
	# Lookup $name in CPAN
	#
	my $any = CPAN::Shell->expandany($name);
	if (! $any) {
		print "Nothing like $name in CPAN\n";
		return -1;
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
		return -1;
	}

	my $id           = eval { $mod->id() }           || die "Failed to get module id for $name ?";
	my $inst_version = eval { $mod->inst_version() } || '';
	my $cpan_version = eval { $mod->cpan_version() } || die "Failed to get cpan version for $name ?";
	if ($inst_version) {
		print "... Processing module $id, CPAN version $cpan_version, wanted version $modulewantedversion, installed version $inst_version\n";
	} else {
		print "... Processing module $id, CPAN version $cpan_version, wanted version $modulewantedversion, no installed version\n";
	}

	my $ok;
	if (!$inst_version || !$modulewantedversion || CPAN::Version->vcmp($inst_version, $modulewantedversion) < 0) {
		system('cpan', $name);
		if ($? == -1) {
			print "failed to execute: $!\n";
			$ok = 0;
		} elsif ($? & 127) {
			printf "child died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without';
			$ok = 0;
		} else {
			my $childstatus = $? >> 8;
			printf "child exited with value %d\n", $childstatus;
			$ok = $childstatus == 0 ? 1 : 0;
		}
	} else {
		$ok = 1;
	}
	
	return $ok;
}
