#!env perl
use strict;
use diagnostics;
use Config;
use File::Spec;
use POSIX qw/EXIT_SUCCESS/;
use PkgConfig;

#
# This script is doing "corrections". It is targetting:
# - All .pc files

# Our CMakeLists.txt made sure that all .pc files are in $ENV{PKG_CONFIG_PATH}.
# We are always executed via command-with-this-perl.bat that is setting this
# environment variable

#   Some packages think it is a good idea to put an
#   absolute path to prefix, expec_prefix, libddir, include_dir... No
#   it always has to be relative and all the values are fixed.
#   Unlisted variables will be signaled with a fatal error
my %PC = (
	'prefix' => q|${pcfiledir}/../..|,
	'exec_prefix' => q|${prefix}|,
	'bindir' => q|${exec_prefix}/bin|,
	'sbindir' => q|${exec_prefix}/sbin|,
	'libexecdir' => q|${exec_prefix}/libexec|,
	'datarootdir' => q|${prefix}/share|,
	'datadir' => q|${datarootdir}|,
	'sysconfdir' => q|${prefix}/etc|,
	'sharedstatedir' => q|${prefix}/com|,
	'localstatedir' => q|${prefix}/var|,
	'runstatedir' => q|${localstatedir}/run|,
	'includedir' => q|${prefix}/include|,
	'docdir' => sub { q|${datarootdir}/doc/| . shift },
	'infodir' => q|${datarootdir}/info|,
	'libdir' => q|${exec_prefix}/lib|,
	'localedir' => q|${datarootdir}/locale|,
	'mandir' => q|${datarootdir}/man|,
	'man1dir' => q|${mandir}/man1|,
	'man2dir' => q|${mandir}/man2|,
	);

post_install_pkgconfig();

sub post_install_pkgconfig {
    my $o = PkgConfig->find([]);
    my @list = $o->get_list();
 
	process_pkgconfig($_->[0]) for @list;
}

sub process_pkgconfig {
	my ($package) = @_;
	
	my $o = PkgConfig->find($package);
	if (! $o ->pkg_exists) {
		print STDERR "PkgConfig failure on package $package, " . ($o->errmsg // 'no error message');
		return;
	}

	my $file_path = File::Spec->catfile($ENV{PKG_CONFIG_PATH}, "$package.pc");
	if (! open(PC, '<', $file_path)) {
		print STDERR "Cannot open $file_path, $!";
		return;
	}
	my $oldcontent = do { local $/; <PC> };
	close(PC) || print STDERR "Cannot close $file_path, $!";

	my @old = split(/\R/, $oldcontent);
	my @new;

    my $status = 1;	
	foreach my $old (@old) {
		my $new = $old;
		
		if ($old =~ /^(\s*)(\w+)(\s*=\s*)(.+)$/) {
			#
			# We do not want to use $o->get_var() because we want what is coded,
			# not the interpretation.
			#
			my ($beforevar, $var, $aftervar, $oldvalue) = ($1, $2, $3, $4);

			my $newvalue;
			if (exists($PC{$var})) {
				if (ref($PC{$var}) eq 'CODE') {
					$newvalue = $PC{$var}->($package);
				} else {
					$newvalue = $PC{$var};
				}
			} else {
				$newvalue = $oldvalue;
			}
		
			if ($newvalue ne $oldvalue) {
				$status = 0;
				$new  = "# Was: $old\n";
				$new .= "$beforevar$var$aftervar$newvalue";
			}
		}
			
		push(@new, $new);
	}

	#
	# Check libraries. Some packages like png like to not follow convention, for example
	# putting -lpng as a dependency but force the library name to be libpng.lib and libpng.dll.
	# And everybody has to write special code... to find out that -lpng on Windows do NOT mean
	# png.dll/png.lib but libpng.dll/libpng.lib. Those who do not hack are likely to fail if
	# they base their logic on pkg-config and trust pkg-config... But well, guys, if we cannot
	# trust pkg-config when will the hell stop !?!?
	#
	# We hope that nobody exposed -R, this is not supported on Windows, seems it is the case.
	#
	{
		my @Ldirs = ();
		my @ldflags = $o->get_ldflags;
		foreach my $ldflag (@ldflags) {
			if ($ldflag =~ /^-L(.+)/) {
				push(@Ldirs, $1);
				next;
			}
			if ($ldflag =~ /-l(.+)/) {
				my $lib = $1;
				#
				# Check if this library really exist...
				#
				my $found = 0;
				foreach my $Ldir (@Ldirs) {
					my $lib_path = File::Spec->catfile($Ldir, "$lib$Config{lib_ext}");
					if (-r $lib_path) {
						$found = 1;
						last;
					}
				}
				if (! $found) {
					#
					# Check if library exist with the lib prefix
					#
					my $libprefix_found = 0;
					my $libprefix_dir;
					foreach my $Ldir (@Ldirs) {
						my $lib_path = File::Spec->catfile($Ldir, "lib$lib$Config{lib_ext}");
						if (-r $lib_path) {
							$libprefix_found = 1;
							$libprefix_dir = $Ldir;
							last;
						}
					}
					if ($libprefix_found) {
						#
						# Check this is coherent with a dll name that should be in the directory upper (this is our convention)
						#
						my $bindir = File::Spec->catdir($libprefix_dir, File::Spec->updir(), 'bin');
						my $bin_path = File::Spec->catfile($libprefix_dir, , File::Spec->updir(), 'bin', "lib$lib.$Config{dlext}");
						my $binprefix_found = 0;
						if (-r $bin_path) {
							$binprefix_found = 1;
						}
						if (! $binprefix_found) {
							print STDERR "[$package] $ldflag suggests the library is $lib$Config{lib_ext} but we found lib$lib$Config{lib_ext} but NO lib$lib.$Config{dlext} !?\n";
						} else {
							#
							# Ok, this mean we can change -l$lib to -llib$lib
							#
							foreach my $indice (0..$#new) {
								my $prev_at_indice = $new[$indice];
								my $new_at_indice = $new[$indice];

								$new_at_indice =~ s/\-l$lib/-llib$lib/g;

								if ($new_at_indice ne $prev_at_indice) {
									$new[$indice]  = "# Was: $prev_at_indice\n";
									$new[$indice] .= $new_at_indice;
								}
							}
						}
					}
				}
			}
		}
	}
			
	if (! $status) {
		# In case .pc was using \r\n, revisit the content
		$oldcontent = join("\n", @old) . "\n";
		my $newcontent = join("\n", @new) . "\n";

		my $warnline = "Changing $file_path !!";
		my $pretty = '-' x length($warnline);
		print "$pretty\n$warnline\n$pretty\n$newcontent\n";

		if (! open(PC, '>', $file_path)) {
			print STDERR "Cannot open $file_path, $!";
			return;
		}
		print PC $newcontent;
		close(PC) || print STDERR "Cannot close $file_path, $!";
	}
}
