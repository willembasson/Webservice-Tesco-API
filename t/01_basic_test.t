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

#is($tesco->customer_forename, "David", "first name");
#is($tesco->customer_name,     "Mr Hodgkinson", "full name");

my $args = 1 ;

my $products = $tesco->search_product
  ({
    searchtext => 'Turnip',
    extendedinfo => 'Y'
   }) ;

is( $products->{StatusCode},0,'Correct status code for product_search');
is( $products->{StatusInfo},'Command Processed OK',"Command OK");
is( $products->{TotalPageCount},1, "1 page");
is( $products->{PageNumber},0, "zeroth page") ;

# shouldnt rely on these
#is( $products->{TotalProductCount},5, "5 products");
#is( $products->{PageProductCount' => 5,

my $p = $products->{Products}->[0];

for my $p (qw/ImagePath RDA_Fat_Grammes MaximumPurchaseQuantity CookingAndUsage
IngredientsCount RDA_Calories_Percent RDA_Fat_Percent UnitType
RDA_Saturates_Percent RDA_Salt_Grammes HealthierAlternativeProductId
RDA_Calories_Count UnitPrice StorageInfo RDA_Salt_Percent
ExtendedDescription RDA_Saturates_Grammes ProductId RDA_Sugar_Percent
NutrientsCount PriceDescription Price EANBarcode Rating
RDA_Sugar_Grammes CheaperAlternativeProductId ShelfCategory
OfferPromotion BaseProductId Name OfferValidity OfferLabelImagePath
ProductType ShelfCategoryName/) {
  ok(exists $products->{Products}->[0]->{$p}, $p);
}

my $categories =  $tesco->list_product_categories;
ok($categories,"categories");

# could go through all the categories here, but that's probably fragile!

#
#warn $tesco->get_session;


my $slots = $tesco->list_delivery_slots;
ok($slots->{DeliverySlots}->[0],"slot 0");

my $slot = $tesco->choose_delivery_slot({ deliveryslotid => $slots->{DeliverySlots}->[0]->{DeliverySlotId}});
ok($slot,"slot");
ok($slot->{StatusCode},"code");
ok($slot->{StatusInfo},"info");
ok($slot->{ReservedUntil},"reserved");
done_testing;
