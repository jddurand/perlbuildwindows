#!env perl
use strict;
use Config qw//;
use File::Basename qw/dirname/;
use File::Spec qw//;
use Win32::API qw/SafeReadWideCString/;

#
# Paranoid protection
#
return if $ENV{PERL_DISABLE_SIZECUSTOMIZE};

#
# Perl is smart enough to not use the installation path
# to find sitecustomize.pl. This is how we make our perl
# portable.
eval {
	#
	# This can fail if e.g. we find to get current executable name
	#
	_sitecustomize_change_config();
};
print "[sitecustomize] $@\n" if $@ && $ENV{PERL_SIZECUSTOMIZE_DEBUG};

_sitecustomize_setup_env();

#
# Cleanup the namespace
#
map { undef $main::{$_} } qw/_sitecustomize_change_config
                              _sitecustomize_setup_env
                              _sitecustomize_GetExecutableFullPathW
							  _sitecustomize_WideStringToPerlString
							  _sitecustomize_GetModuleFileNameW
							  _sitecustomize_GetFullPathNameW
							  _sitecustomize_GetLongPathNameW
							  /;

sub _sitecustomize_change_config {
	#
	# Get current perl full path
	#
	my $executable = _sitecustomize_WideStringToPerlString(_sitecustomize_GetExecutableFullPathW());
	print "[sitecustomize] \$executable : " . ($executable // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};

	#
	# We are by definition there: XXX\bin\perl.exe
	#
	my $newinstallprefix = dirname(dirname($executable));
	print "[sitecustomize] \$newinstallprefix : " . ($newinstallprefix // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};

	#
	# Recuperate the old install prefix
	#
	my $oldinstallprefix = $Config{installprefix};
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
		# We inspect all values of $Config and rewrite $oldinstallprefix to $newinstallprefix
		# No need for a regex here, values all start with $oldinstallprefix or not.
		#
		foreach my $key (keys %Config) {
			my $value = $Config{$key} // '';
			if (index($value, $oldinstallprefix) == 0) {
				substr($value, 0, $oldinstallprefix_length, $newinstallprefix);
				print "[sitecustomize] \$Config{$key} = $Config{$key} -> $value\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
				$Config{$key} = $value;
			}
		}

		*Config::STORE = $origStore;
	}
}

sub _sitecustomize_setup_env {
	#
	# Always set PKG_CONFIG_PATH to $Config{installprefix}/c/lib/pkgconfig
	# Note that this is a bit vicious but the test suite of PkgConfig requires
	# that this is variable is not set ;)
	#
	$ENV{PKG_CONFIG_PATH} = File::Spec->catdir($Config{installprefix}, 'c', 'lib', 'pkgconfig') unless defined $ENV{PERL_PKGCONFIG_BOOTSTRAP};
}

sub _sitecustomize_GetExecutableFullPathW {
	my $executableFullPathW;

	my $moduleFileNameW = _sitecustomize_GetModuleFileNameW();
	print "[sitecustomize] \$moduleFileNameW : " . (_sitecustomize_WideStringToPerlString($moduleFileNameW) // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	return unless defined($moduleFileNameW);

	my $fullPathNameW = _sitecustomize_GetFullPathNameW($moduleFileNameW);
	print "[sitecustomize] \$fullPathNameW : " . (_sitecustomize_WideStringToPerlString($fullPathNameW) // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
	return unless defined($fullPathNameW);

	my ($supported, $longPathNameW) = _sitecustomize_GetLongPathNameW($fullPathNameW);
	if ($supported) {
		print "[sitecustomize] \$longPathNameW : " . (_sitecustomize_WideStringToPerlString($longPathNameW) // '<undef>') . "\n" if $ENV{PERL_SIZECUSTOMIZE_DEBUG};
		return unless defined($longPathNameW);
		$executableFullPathW = $longPathNameW;
	} else {
		$executableFullPathW = $fullPathNameW;
	}
	
	return $executableFullPathW;
}

sub _sitecustomize_WideStringToPerlString {
	my ($source) = @_;
	
	return undef unless defined($source);

	return SafeReadWideCString(unpack('J',pack('p', $source)));
}

sub _sitecustomize_GetModuleFileNameW {
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
	
	$lpFilename = bytes::substr($lpFilename, 0, ($rc + 1) * 2); # $rc is the number of TCHAR minus the null character that is in the buffer
	
	return $lpFilename;
}

sub _sitecustomize_GetFullPathNameW {
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
	
	$lpBuffer = bytes::substr($lpBuffer, 0, ($rc + 1) * 2); # $rc is the number of TCHAR minus the null character that is in the buffer
	
	return $lpBuffer;
}

sub _sitecustomize_GetLongPathNameW {
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
	
	$lpszLongPath = bytes::substr($lpszLongPath, 0, ($rc + 1) * 2); # $rc is the number of TCHAR minus the null character that is in the buffer
	
	return (1, $lpszLongPath);
}
