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

can_ok( $tesco, qw ( new get login search_product server_date_time
    list_product_categories list_delivery_slots choose_delivery_slot
    latest_app_version list_basket list_basket_summary list_favourites
    list_pending_orders list_product_offers list_products_by_category
    change_basket) );

my $result = $tesco->login
  ({
    email    => $ENV{'TESCO_EMAIL'} || undef,
    password => $ENV{'TESCO_PASSWORD'} || undef,
   });

my $products;

$products = $tesco->search_product
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


my $basket = $tesco->list_basket;

for my $f (qw/BasketID BasketTotalClubcardPoints StatusInfo
          BasketGuidePrice BasketQuantity BasketGuideMultiBuySavings
          BasketLines InAmendOrderMode StatusCode/) {
  ok(exists $basket->{$f}, $f);
}

$basket = $tesco->list_basket_summary;

for my $f (qw/StatusCode BasketID BasketLines StatusInfo InAmendOrderMode/) {
  ok(exists $basket->{$f}, $f);
}


my $favourites = $tesco->list_favourites;
ok($favourites->{TotalProductCount},"TotalProductCount");

for my $f (qw/OfferLabelImagePath Name ShelfCategoryName UnitPrice
              HealthierAlternativeProductId CheaperAlternativeProductId
              OfferPromotion Price ProductId ShelfCategory ProductType
              PriceDescription UnitType ImagePath OfferValidity
              MaximumPurchaseQuantity EANBarcode BaseProductId/) {
  ok(exists $favourites->{Products}->[0]->{$f}, $f);
}


my $orders = $tesco->list_pending_orders;
for my $f (qw/StatusInfo StatusCode PendingOrders/) {
  ok(exists $orders->{$f},$f);
}


my $offers = $tesco->list_product_offers;

for my $f (qw/TotalProductCount StatusCode PageNumber TotalPageCount /) {
  ok(exists $offers->{$f},$f);
}

for my $f (qw/ImagePath CheaperAlternativeProductId HealthierAlternativeProductId
ProductId ProductType PriceDescription ShelfCategoryName Name
EANBarcode ShelfCategory UnitType BaseProductId OfferValidity
OfferLabelImagePath MaximumPurchaseQuantity Price UnitPrice
OfferPromotion/) {
  ok(exists $offers->{Products}->[0]->{$f}, $f);
}


my $categories =  $tesco->list_product_categories;
ok($categories,"categories");


$products = $tesco->list_products_by_category({category => 18, extendedinfo => 'y'}) ;


for my $f (qw/PageProductCount StatusCode StatusInfo/) {
  ok(exists $products->{$f}, $f);
}

for my $f (qw/BaseProductId EANBarcode CheaperAlternativeProductId
HealthierAlternativeProductId ImagePath MaximumPurchaseQuantity Name
OfferPromotion OfferValidity OfferLabelImagePath ShelfCategory
ShelfCategoryName Price PriceDescription ProductId ProductType
UnitPrice UnitType/) {
  ok(exists $products->{Products}->[0]->{$f}, $f);
}

my $datetime = $tesco->server_date_time;
is($datetime->{StatusInfo}, "SUCCESS", "SUCCESS");
for my $f (qw/ServerUTCDateTime ServerLocalDateTime/) {
  # should probably parse the date time
  ok($datetime->{$f}, $f);
}


#warn Dumper($products->{Products}->[0]);
for my $i (0..4) {
  warn $products->{Products}->[$i]->{ProductId};
  my $change = $tesco->change_basket({
                         productid      => $products->{Products}->[$i]->{ProductId},
                         changequantity => 1,
                                     });
  is($change->{StatusCode},0,"status OK");
}

done_testing;
