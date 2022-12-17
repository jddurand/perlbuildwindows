#!env perl
#
# Site customization.
#
# Disable this script by setting the environment PERL_DISABLE_SIZECUSTOMIZE to any value.
# Setting the environment variable PERL_SIZECUSTOMIZE_DEBUG will print debug statements.
#
#
# We try to put all our stuff in a single package
#
package __SiteCustomize__;
sub customize {
	#
	# Set the environment variable to PERL_DISABLE_SIZECUSTOMIZE to stop this script
	#
	return if $ENV{PERL_DISABLE_SIZECUSTOMIZE};
	#
	# Check if we can proceed
	#
	my $have_Config        = eval { require 'Config.pm';        1 }; print "[sitecustomize] $@\n" if $@ && $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	my $have_File_Basename = eval { require 'File/Basename.pm'; 1 }; print "[sitecustomize] $@\n" if $@ && $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	my $have_File_Spec     = eval { require 'File/Spec.pm';     1 }; print "[sitecustomize] $@\n" if $@ && $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	my $have_WiN32_API     = eval { require 'Win32/API.pm';     1 }; print "[sitecustomize] $@\n" if $@ && $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	#
	# Paranoid protection
	#
	return unless $have_Config && $have_File_Basename && $have_File_Spec && $have_WiN32_API;
	#
	# Perl is smart enough to not use the installation path
	# to find sitecustomize.pl. This is how we make our perl
	# portable.
	#
	eval {
		#
		# This can fail if e.g. we fail to get current executable name
		#
		change_config();
	};
	print "[sitecustomize] $@\n" if $@ && $ENV{PERL_SIZECUSTOMIZE_DEBUG};

	setup_env();
}

sub change_config {
	#
	# Get current perl full path
	#
	my $executable = WideStringToPerlString(GetExecutableFullPathW());
	print "[sitecustomize] \$executable : " . ($executable // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};

	#
	# We are by definition there: XXX\bin\perl.exe
	#
	my $newinstallprefix = File::Basename::dirname(File::Basename::dirname($executable));
	print "[sitecustomize] \$newinstallprefix : " . ($newinstallprefix // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};

	#
	# Recuperate the old install prefix
	#
	my $oldinstallprefix = $Config::Config{installprefix};
	print "[sitecustomize] \$oldinstallprefix : " . ($oldinstallprefix // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};

	#
	# We are not going to play with case insitivity - if strings are the same find, else do the replace
	#
	return if $newinstallprefix eq $oldinstallprefix;

	#
	# Make our perl "portable" by modifying %Config
	#
	{
		no warnings 'redefine';

		my $oldinstallprefix_length = length($oldinstallprefix);
		my $origStore = \&Config::STORE;
		*Config::STORE = sub {
			my ($self, $this, $value) = @_;
			$self->{$this} = $value,
		};
		#
		# We inspect all values of %Config and rewrite $oldinstallprefix to $newinstallprefix
		# No need for a regex here, values all start with $oldinstallprefix or not.
		#
		foreach my $key (keys %Config::Config) {
			my $value = $Config::Config{$key} // '';
			if (index($value, $oldinstallprefix) == 0) {
				substr($value, 0, $oldinstallprefix_length, $newinstallprefix);
				print "[sitecustomize] \$Config::Config{$key} = $Config::Config{$key} -> $value\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
				$Config::Config{$key} = $value;
			}
		}

		*Config::STORE = $origStore;
	}
}

sub setup_env {
	#
	# Always set PKG_CONFIG_PATH to $Config{installprefix}/c/lib/pkgconfig
	# Note that this is a bit vicious but the test suite of PkgConfig requires
	# that this variable is not set ;)
	#
	if (! defined($ENV{PERL_PKGCONFIG_BOOTSTRAP})) {
		my $perl_pkgconfig_path = File::Spec->catdir($Config::Config{installprefix}, 'c', 'lib', 'pkgconfig');
		if (defined($ENV{PKG_CONFIG_PATH})) {
			#
			# We preprend our PKG_CONFIG_PATH unless it already start with the same thing
			#
			my $first = File::Spec->canonpath((split(';', $ENV{PKG_CONFIG_PATH}))[0]);
			my $want = File::Spec->canonpath($perl_pkgconfig_path);
			if (File::Spec->case_tolerant()) {
				$first = lc($first);
				$want = lc($want);
			}
			#
			# Just me sure directory separator is the same
			#
			$first =~ s/\\/\//g;
			$want =~ s/\\/\//g;
			if ($first ne $want) {
				$ENV{PKG_CONFIG_PATH} = join(';', $perl_pkgconfig_path, $ENV{PKG_CONFIG_PATH});
			}
		} else {
			$ENV{PKG_CONFIG_PATH} = $perl_pkgconfig_path;
		}
	}
	#
	# Prepend our bin and c/bin to PATH
	#
	my $perl_bin_path = File::Spec->catdir($Config::Config{installprefix}, 'bin');
	my $perl_c_bin_path = File::Spec->catdir($Config::Config{installprefix}, 'c', 'bin');
	#
	# This will go directly to Windows path resolving, so be Windows compliant
	#
	$perl_bin_path =~ s/\//\\/g;
	$perl_c_bin_path =~ s/\//\\/g;
	if ($ENV{PATH}) {
		$ENV{PATH} = join(';', $perl_bin_path, $perl_c_bin_path, $ENV{PATH});
	} else {
		#
		# Should never happen
		#
		$ENV{PATH} = join(';', $perl_bin_path, $perl_c_bin_path);
	}
}

sub GetExecutableFullPathW {
	my $executableFullPathW;

	my $moduleFileNameW = GetModuleFileNameW();
	print "[sitecustomize] \$moduleFileNameW : " . (WideStringToPerlString($moduleFileNameW) // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	return unless defined($moduleFileNameW);

	my $fullPathNameW = GetFullPathNameW($moduleFileNameW);
	print "[sitecustomize] \$fullPathNameW : " . (WideStringToPerlString($fullPathNameW) // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	return unless defined($fullPathNameW);

	my ($supported, $longPathNameW) = GetLongPathNameW($fullPathNameW);
	if ($supported) {
		print "[sitecustomize] \$longPathNameW : " . (WideStringToPerlString($longPathNameW) // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
		return unless defined($longPathNameW);
		$executableFullPathW = $longPathNameW;
	} else {
		$executableFullPathW = $fullPathNameW;
	}
	
	return $executableFullPathW;
}

sub WideStringToPerlString {
	my ($source) = @_;
	
	return undef unless defined($source);

	return Win32::API::SafeReadWideCString(unpack('J',pack('p', $source)));
}

sub GetModuleFileNameW {
	my $function = Win32::API::More->new(
		'kernel32', 'DWORD GetModuleFileNameW(HMODULE hModule, LPWSTR lpFilename, DWORD nSize)'
	);
	return undef unless defined($function);

	# First iteration is using 260 TCHARs
	my $nSize = 260;
	my $lpFilename;
	my $rc;

	do {
		$nSize *= 2;
		$lpFilename = ' ' x ($nSize * 2);
		$rc = $function->Call(0, $lpFilename, $nSize);
		# Failure ?
		return undef if !$rc;
		# Truncation ?
	} while ($rc == $nSize);
	
	{
		use bytes;
		$lpFilename = bytes::substr($lpFilename, 0, ($rc + 1) * 2); # $rc is the number of TCHAR minus the null character that is in the buffer
	}
	
	return $lpFilename;
}

sub GetFullPathNameW {
	my ($lpFileName) = @_;

	my $function = Win32::API::More->new(
		'kernel32', 'DWORD GetFullPathNameW(LPWSTR lpFileName, DWORD nBufferLength, LPWSTR lpBuffer, LPVOID lpFilePart)' # LPWSTR* is unknown to Win32::API, fortunately we do not use lpFilePart
	);
	return undef unless defined($function);

	# First iteration is using 32767 TCHARs
	my $nSize = 32767;
	my $lpBuffer;
	my $rc;

	do {
		$nSize *= 2;
		$lpBuffer = ' ' x ($nSize * 2);
		$rc = $function->Call($lpFileName, $nSize, $lpBuffer, undef);
		# Failure ?
		return undef if !$rc;
		# Not enough room ?
	} while ($rc > $nSize);
	
	{
		use bytes;
		$lpBuffer = bytes::substr($lpBuffer, 0, ($rc + 1) * 2); # $rc is the number of TCHAR minus the null character that is in the buffer
	}
	
	return $lpBuffer;
}

sub GetLongPathNameW {
	my ($lpszShortPath) = @_;

	# LPCWSTR is const LPWSTR
	my $function = Win32::API::More->new(
		'kernel32', 'DWORD GetLongPathNameW(LPWSTR lpszShortPath, LPWSTR lpszLongPath, DWORD cchBuffer)' # LPCWSTR is a const LPWSTR, unknown to Win32::API
	);
	if (! defined($function)) {
		print "[sitecustomize] GetLongPathNameW is not supported\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
		return (0, undef);
	}

	# First iteration is using 32767 TCHARs
	my $cchBuffer = 32767;
	my $lpszLongPath;
	my $rc;

	do {
		$cchBuffer *= 2;
		$lpszLongPath = ' ' x ($cchBuffer * 2);
		$rc = $function->Call($lpszShortPath, $lpszLongPath, $cchBuffer);
		# Failure ?
		return (1, undef) if !$rc;
		# Not enough room ?
	} while ($rc > $cchBuffer);
	
	{
		use bytes;
		$lpszLongPath = bytes::substr($lpszLongPath, 0, ($rc + 1) * 2); # $rc is the number of TCHAR minus the null character that is in the buffer
	}
	
	return (1, $lpszLongPath);
}

package main;
__SiteCustomize__::customize();

#
# We explicitly unload modules whose behaviour is not 100% fixed (e.g. File::Spec depend on $^O that can be changed)
#
map { _ClassUnload($_) } qw/File::Basename File::Spec __SiteCustomize__/;

#
# The _ClassUnload method itself
#
map {
		print "[sitecustomize] Removing \${main}::$_\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
		my $symtab = 'main::';
		delete $symtab->{$_};
	} qw/_ClassUnload/;

#
# Nothing else but a copy of Class::Unload without the Class::Inspector or MOP thingies (not relevant in our case)
#
sub _ClassUnload {
	my ($class) = @_;

	print "[sitecustomize] Unloading $class\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};

	# Flush inheritance caches
	@{$class . '::ISA'} = ();

	my $symtab = $class.'::';
	# Delete all symbols except other namespaces
	for my $symbol (keys %$symtab) {
		next if $symbol =~ /\A[^:]+::\z/;
		print "[sitecustomize]   Symbol $symtab" . "$symbol\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
		delete $symtab->{$symbol};
	}

	my $inc_file = join( '/', split /(?:'|::)/, $class ) . '.pm';
	print "[sitecustomize]   INC $inc_file\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	delete $INC{ $inc_file };
}
