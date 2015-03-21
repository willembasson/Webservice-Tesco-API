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
use Data::Dumper;
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
    qw ( new get login search_product )
);

my $result = $tesco->login
  ({
    email    => $ENV{'TESCO_EMAIL'} || undef,
    password => $ENV{'TESCO_PASSWORD'} || undef,
   });

is($tesco->customer_forename, "David", "first name");
is($tesco->customer_name,     "Mr Hodgkinson", "full name");

my $args = 1 ;

my $products = $tesco->search_product
  ({
    searchtext => 'Turnip',
    extendedinfo => 'Y'
   }) ;

is( $products->{StatusCode},0,'Correct status code for product_search');

exit;

my $categories =  $tesco->list_product_categories;
ok($categories);

done_testing;
