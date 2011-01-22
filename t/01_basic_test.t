#!perl

BEGIN {
  unless ($ENV{'TESCO_APP_KEY'} && $ENV{'TESCO_DEVELOPER_KEY'} && $ENV{'TESCO_EMAIL'} && $ENV{'TESCO_PASSWORD'}) {
    require Test::More;
    Test::More::plan(skip_all => 'Set the following environment variables or these tests are skipped: '
            ."\n". q/ $ENV{'TESCO_APP_KEY'} $ENV{'TESCO_DEVELOPER_KEY'} $ENV{'TESCO_EMAIL'} $ENV{'TESCO_PASSWORD'} /);
  }
}

use strict;
use warnings;

use Test::More qw( no_plan );

use_ok('WebService:Tesco::API');


my $tesco = WebService::Tesco::API->new(
        app_key         => $ENV{'TESCO_APP_KEY'},
        developer_key   => $ENV{'TESCO_DEVELOPER_KEY'},
    );

is_a($tesco,'WebService:Tesco::API','Create a new instance');

my $result = $tesco->login({
        email       => $ENV{'TESCO_EMAIL'},
        password    => $ENV{'TESCO_PASSWORD'},
    });
