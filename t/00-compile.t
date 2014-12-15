#!perl

use strict;
use warnings;

use Test::More;


use File::Find;
use File::Temp qw{ tempdir };

use lib qw/lib/;

use_ok("WebService::Tesco::API");

done_testing;

