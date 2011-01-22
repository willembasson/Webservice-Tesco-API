#!perl

BEGIN {
    unless ($ENV{'TESCO_APP_KEY'}
        && $ENV{'TESCO_DEVELOPER_KEY'}
        && $ENV{'TESCO_EMAIL'}
        && $ENV{'TESCO_PASSWORD'})
    {
        require Test::More;
        Test::More::plan(skip_all =>
              'Set the following environment variables or these tests are skipped: '
              . "\n"
              . q/ $ENV{'TESCO_APP_KEY'} $ENV{'TESCO_DEVELOPER_KEY'} $ENV{'TESCO_EMAIL'} $ENV{'TESCO_PASSWORD'} /
        );
    }
}

use strict;
use warnings;

use Test::Most tests => 3;
use lib 'lib';

use_ok('WebService::Tesco::API');


my $tesco = WebService::Tesco::API->new(
    app_key       => $ENV{'TESCO_APP_KEY'},
    developer_key => $ENV{'TESCO_DEVELOPER_KEY'},
);

isa_ok($tesco, 'WebService::Tesco::API', 'Create a new instance');
can_ok($tesco,
    qw ( new get login session_get amend_order cancel_amend_order change_basket choose_delivery_slot latest_app_version list_delivery_slots list_basket list_basket_summary list_favourites list_pending_orders list_product_categories list_product_offers list_products_by_category product_search ready_for_checkout server_date_time save_amend_order )
);

my $result = $tesco->login(
    {   email    => $ENV{'TESCO_EMAIL'},
        password => $ENV{'TESCO_PASSWORD'},
    }
);
