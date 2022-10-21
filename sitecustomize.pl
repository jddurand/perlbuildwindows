#!env perl
use strict;
use diagnostics;
use Encode;
use Errno qw/ERROR_INSUFFICIENT_BUFFER/;
use File::Spec;
use Win32::API qw/SafeReadWideCString/;
use Config;

#
# Perl is smart enough to not use the installation path
# to find sitecustomize.pl. This is how we make our perl
# portable.

#
# Paranoid protection
#
return if defined($ENV{PERL_DISABLE_SIZECUSTOMIZE});

#
# Get current perl full path
#
my $executable = WideStringToPerlString(_GetExecutableFullPathW());
print "\$executable : " . ($executable // '<undef>') . "\n" if ($ENV{PERL_SIZECUSTOMIZE_DEBUG});

#
# Make our perl "portable" by modifying %Config
#
{
	no warnings 'redefine';
	
	my $origStore = \&Config::STORE;
	*Config::STORE = sub {
		my ($self, $this, $value) = @_;
		$self->{$this} = $value,
	};
	# $Config{lddlflags} = 'x';
	*Config::STORE = $origStore;
}

sub _GetExecutableFullPathW {
	my $executableFullPathW;

	my $moduleFileNameW = _GetModuleFileNameW();
	print "\$moduleFileNameW : " . (WideStringToPerlString($moduleFileNameW) // '<undef>') . "\n" if ($ENV{PERL_SIZECUSTOMIZE_DEBUG});
	return unless defined($moduleFileNameW);

	my $fullPathNameW = _GetFullPathNameW($moduleFileNameW);
	print "\$fullPathNameW : " . (WideStringToPerlString($fullPathNameW) // '<undef>') . "\n" if ($ENV{PERL_SIZECUSTOMIZE_DEBUG});
	return unless defined($fullPathNameW);

	my ($supported, $longPathNameW) = _GetLongPathNameW($fullPathNameW);
	if ($supported) {
		print "\$longPathNameW : " . (WideStringToPerlString($longPathNameW) // '<undef>') . "\n" if ($ENV{PERL_SIZECUSTOMIZE_DEBUG});
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

	return SafeReadWideCString(unpack('J',pack('p', $source)));
}

sub _GetModuleFileNameW {
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

sub _GetFullPathNameW {
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

sub _GetLongPathNameW {
	my ($lpszShortPath) = @_;

	# LPCWSTR is const LPWSTR
	my $function = Win32::API::More->new(
		'kernel32', 'DWORD GetLongPathNameW(LPWSTR lpszShortPath, LPWSTR lpszLongPath, DWORD cchBuffer)' # LPCWSTR is a const LPWSTR, unknown to Win32::API
	);
	if (! defined($function)) {
		print "GetLongPathNameW is not supported\n" if ($ENV{PERL_SIZECUSTOMIZE_DEBUG});
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
