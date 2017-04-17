#!/usr/bin/perl
use warnings;
use strict;

# Script for adding fast storage for a user
# Last modified 9 Jan 2007, werdz@redbrick.dcu.ie

#############################
# Default settings
#############################
my $softlimit = 300000;
my $hardlimit = 330000;
my $softblocks = 800000;
my $hardblocks = 1000000;
#############################

# General configuration
my $faststorage_location = "/fast-storage/users";
my $faststorage_device = "/dev/sda7";

# Check for command line arguments
usage() unless $ARGV[0];

my $username = $ARGV[0];

if($ARGV[1]) {
	$softlimit = $ARGV[1];
	$hardlimit = int($softlimit * 1.10);
}

if($ARGV[2]) {
	$softblocks = $ARGV[2];
	$hardblocks = int($softblocks * 1.25);
}

# Determine any extra information we'll need

my $user_letter = lc(substr($username,0,1));
my $groups_output = `id $username`;
#print $groups_output;
$groups_output =~ m/uid=\d*\(.*?\) gid=\d*\((.*?)\).*$/;
my $usergroup = $1;

# Check if the user already has fast storage space

if( -e $faststorage_location . "/" . $user_letter . "/" . $username) {
	print "User " . $username . " already appears have a fast storage account at:\n";
	print $faststorage_location . "/" . $user_letter . "/" . $username . "\n\n";
	exit(1); # Unsuccessful error code
}

# Build commands

my $mkdir_cmd = "mkdir -p " . $faststorage_location . "/" . $user_letter . "/" . $username;
my $chmod_cmd = "chmod 700 " . $faststorage_location . "/" . $user_letter . "/" . $username;
my $chown_cmd = "chown $username:$usergroup $faststorage_location/$user_letter/$username";
my $quota_cmd = "setquota -u " . $username . " " . $softlimit . " " . $hardlimit . " " . $softblocks . " " . $hardblocks . " " . $faststorage_device;

# Print out a summary of what will be done.
print "User does not appear to have fast storage space.\n";
print "Summary of what will be done:\n\n";

print $mkdir_cmd . "\n" . $chmod_cmd . "\n" . $chown_cmd . "\n" . $quota_cmd . "\n\n";

# Ask the user if this is acceptable.
my $valid_answer = 0;
my $user_answer;
while(!$valid_answer) {
	print "Is this alright? (Y/N): ";
	$user_answer = lc(<STDIN>);
	chomp $user_answer;
	if($user_answer eq 'y' || $user_answer eq 'n') {
		$valid_answer = 1;
	}
}

# User says no.
if($user_answer eq 'n') {
	print "Aborted by user.\n";
	exit(1);
}

# Approved by user.. continue.

print "Creating directory...\n";
`$mkdir_cmd`;
print "Setting permissions...\n";
`$chmod_cmd`;
print "Setting ownership...\n";
`$chown_cmd`;
print "Setting quota...\n";
`$quota_cmd`;
print "Done.\n";
exit(0);

#####################################################
#####################################################

sub usage {
	my $usage = "Fast storage script\n";
	$usage .= "Usage: faststorage_add.pl username [custom quota size] [custom block limit]\n";
	print $usage;
	exit(1); # Unsuccessful error code
}
