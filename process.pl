#!/usr/bin/env perl

use File::Path;
use strict;
use warnings;

my $PGDATA = 'postgres/pgdata';

rmtree($PGDATA)
    if -d $PGDATA;
mkdir($PGDATA);

$ENV{'TODO_SECRET'} = "secretSECRETsecretSECRETsecretSECRET";
$ENV{'PGRST_OPENAPI_SERVER_PROXY_URI'} = 'http://localhost:3001/';

my @args = ('docker-compose');

if (scalar(@ARGV) == 0) {
    push(@args, 'up', '--build', '--force-recreate');
} else {
    push(@args, @ARGV);
}

warn "Command: '@args'";

exec { $args[0] } @args;

die "Failed to launch '@args'";
