#!perl

use lib qw/lib/;

BEGIN {
    unless ($ENV{'TESCO_APP_KEY'}
        && $ENV{'TESCO_DEVELOPER_KEY'})
    {
        require Test::More;
        Test::More::plan(skip_all =>
              'Set the following environment variables or these tests are skipped: '
              . "\n"
              . q/ $ENV{'TESCO_APP_KEY'} $ENV{'TESCO_DEVELOPER_KEY'} /
        );
    }
}

use strict;
use warnings;

use Test::More;
use lib 'lib';

use_ok('WebService::Tesco::API');


my $tesco = WebService::Tesco::API->new
  (
   app_key       => $ENV{'TESCO_APP_KEY'},
   developer_key => $ENV{'TESCO_DEVELOPER_KEY'},
   debug         => 0,
);

isa_ok($tesco, 'WebService::Tesco::API', 'Create a new instance');

can_ok(
    $tesco,
    qw ( new get login product_search )
);

my $result = $tesco->login;

is( $tesco->product_search({searchtext => 'Turnip', extendedinfo => 'Y'})
      ->{StatusCode},
    0,
    'Correct status code for product_search'
);

done_testing;
