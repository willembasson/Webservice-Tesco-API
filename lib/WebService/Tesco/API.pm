use strict;
use warnings;

package WebService::Tesco::API;

# ABSTRACT: Web service for the Tesco groceries API

use Any::Moose;
use Any::URI::Escape;

use LWP::Curl;
use URI;
use JSON;
use Data::Dumper;
use Carp qw(cluck longmess shortmess);

our $VERSION = '0.02';

our $SECURE_ENDPOINT =
  'https://secure.techfortesco.com/tescolabsapi/restservice.aspx?';
our $USER_AGENT = LWP::Curl->new(user_agent => __PACKAGE__ . '_' . $VERSION);


has 'app_key'       => (is => 'ro', isa => 'Str', required => 1);
has 'developer_key' => (is => 'ro', isa => 'Str', required => 1);
has 'debug'         => (is => 'ro', isa => 'Bool', default => 0);
has 'session_key'   => (is => 'rw', isa => 'Str');

has 'customer_name'     => (is => 'rw', isa => 'Str');
has 'customer_forename' => (is => 'rw', isa => 'Str');

has 'secure_url'    =>
  (
   is       => 'ro',
   isa      => 'Str',
   required => 1,
   default  => $SECURE_ENDPOINT,
  );



sub get {
    my ($self, $args) = @_;
    my $urlstring = $self->secure_url ;

    warn "get args: ", Dumper($args) if $self->debug();
    
    while (my ($key, $value) = each %{$args}) {
      if ($value) {
        $urlstring .= "$key=" . uri_escape($value) . '&' ;
      } else {
        $urlstring .= "$key=&";
      }       
    }
    chop $urlstring;
    warn $urlstring if $self->debug();

    my $url = URI->new($urlstring);
    my $res = $USER_AGENT->get($url);
    unless ($res) {
        die $res;
    }
    #warn $res if $self->debug();

    return JSON->new->utf8->decode($res);
}


sub login {
  my $self = shift;
  my $args = shift;

  my $params = {
                command        => 'LOGIN',
                applicationkey => $self->app_key(),
                developerkey   => $self->developer_key(),
                secure         => 1,
               } ;

  $params = { %$params, %$args } ;
  
  my $result = $self->get($params);
  
  $self->session_key($result->{SessionKey});
  $self->customer_name($result->{CustomerName});
  $self->customer_forename($result->{CustomerForename});

  return $result;
}


sub search_product {
  my $self = shift;
  my $args = shift;

  $args->{sessionkey} = $self->session_key;
  $args->{command} = 'PRODUCTSEARCH';

  return $self->get($args);
}


sub server_date_time {
  return shift->get({command => 'SERVERDATETIME'});
}


sub list_product_categories {
    my $self = shift;
    return $self->get
      ({
        command => 'LISTPRODUCTCATEGORIES',
        sessionkey => $self->session_key
       });
}

#not entirely sure what this is supposed
#sub get_session {
#  my $self = shift;
#  my $command = shift;
#  my $args = shift || {};
#  die 'You need to log in first' unless $self->session_key();
#  return $self->get({
#                     %{$args},
#                     command => $command,
#                     sessionkey => $self->session_key()
#                    });
#}

sub list_delivery_slots {
  my $self = shift;
  return $self->get({ command => 'LISTDELIVERYSLOTS',
                    sessionkey => $self->session_key});
}

sub choose_delivery_slot {
  my $self = shift;
  my $args = shift;
  die 'You need to supply a delivery slot id (deliveryslotid)'
    unless $args->{deliveryslotid};

  my $params = {command => 'CHOOSEDELIVERYSLOT',sessionkey => $self->session_key};
  $args = { %$args, %$params };
  return $self->get($args);
}



# docs say:
# LATESTAPPVERSION 	Returns your appʼs latest version (set by you in the developer portal).
# this does not appear to be true
sub latest_app_version {
  my $self = shift;
  return $self->get({command => 'LATESTAPPVERSION', sessionkey => $self->session_key});
}


sub list_basket {
  my $self = shift;
  return $self->get({command => 'LISTBASKET', sessionkey => $self->session_key});
}

sub list_basket_summary {
  my $self = shift;
  return $self->get({command => 'LISTBASKETSUMMARY', sessionkey => $self->session_key});
}

sub list_favourites {
  my $self = shift;
  return $self->get({command => 'LISTFAVOURITES', sessionkey => $self->session_key});
}

sub list_pending_orders {
  my $self = shift;
  return $self->get({command => 'LISTPENDINGORDERS', sessionkey => $self->session_key});
}

sub list_product_offers {
  my $self = shift;
  return $self->get({command => 'LISTPRODUCTOFFERS',  sessionkey => $self->session_key});
}

sub list_products_by_category {
  my $self = shift;
  my $args = shift;
  my $params = {command => 'LISTPRODUCTSBYCATEGORY',  sessionkey => $self->session_key} ;
  $args = { %$args, %$params };
  return $self->get($args);
}


sub change_basket {
  my $self = shift;
  my $args = shift;
  die 'You need to supply a product id (productid)' unless $args->{productid};
  die 'You need to supply changequantity'           unless $args->{changequantity};

  # not yet implemented
  #$args->{substitution} ||= 'YES';
  #$args->{notesforshopper} ||= '';


  my $params = {command => 'CHANGEBASKET' ,  sessionkey => $self->session_key} ;

  $args = { %$args, %$params };
  return $self->get($args);
}

#sub amend_order {
#  my $self = shift;
#  my $args = shift;
#  die 'You need to supply an order number (ordernumber)'
#    unless $args->{ordernumber};
#
#  my $params = {command => 'AMENDORDER',  sessionkey => $self->session_key} ;
#  $args = { %$args, %$params };
#  return $self->get($params);
#}
#
#sub cancel_amend_order {
#  return shift->get({command => 'CANCELAMENDORDER'});
#}
#
#sub ready_for_checkout {
#  return shift->get({command =>'READYFORCHECKOUT'});
#}
#
#sub save_amend_order {
#  return shift->get({command =>'SAVEAMENDORDER'});
#}

1;


=pod

=head1 NAME

WebService::Tesco::API - Web service for the Tesco groceries API as announced:

http://www.tescolabs.com/?p=7171

=head1 SYNOPSIS

use WebService::Tesco::API;

my $tesco = WebService::Tesco::API->new(
            app_key         => 'xxxxxx',
            developer_key   => 'yyyyyy',
            debug           => 1,
    );

my $result = $tesco->login({
            email       => 'test@test.com',
            password    => 'password',
    });

=head1 DESCRIPTION

Web service for the Tesco groceries API, currently in beta.
Register at: L<https://secure.techfortesco.com/tescoapiweb/>
Terms of use: L<http://www.techfortesco.com/tescoapiweb/terms.htm>

=head1 NAME

WebService::Tesco::API - Web service for the Tesco groceries API

=head1 VERSION

Version 0.01

=head1 Constructor

=head2 new()

Creates and returns a new WebService::Tesco::API object

    my $tesco = WebService::Tesco::API->new(
            app_key         => 'xxxxxx',
            developer_key   => 'yyyyyy',
        );

=over 4

=item * C<< app_key => 'xxxxx' >>

Set the application key. This can be set up at:
https://secure.techfortesco.com/tescoapiweb/

=item * C<< developer_key => 'yyyyyy' >>

Set the developer key. This can be set up at:
https://secure.techfortesco.com/tescoapiweb/

=item * C<< debug => [0|1] >>

Show debugging information

=back

=head1 METHODS

=head2 get($args)

General method for sending a GET request.
Set $args->{secure} to use the https endpoint (required for certain requests).
You shouldn't need to use this method directly

=head2 login({ email => 'test@test.com', password => 'password' })

Log in to the Tesco Grocery API
It uses the https endpoint to send email and password.
Returns a session key.

=head2 product_search({ searchtext => 'Turnip', extendedinfo => 'Y' })

Searches for products using text or barcode.

=over 4

=item * C<< searchtext => 'Turnip' >>

Text to search for products, 9-digit Product ID, or 13-digit numeric barcode value.

=back

=head2 list_product_categories

=head2 get_session

=head2 list_delivery_slots

=head2 choose_delivery_slot

=head2 amend_order

=head2 cancel_amend_order

=head2 change_basket

https://secure.techfortesco.com/tescoapiweb/wiki/changebasket.html

=head2 latest_app_version

Doesn't appear to be working. No version I can see to be set in the portal.

=head2 list_basket

=head2 list_basket_summary

=head2 list_favourites

=head2 list_pending_orders

=head2 list_product_offers

=head2 list_products_by_category

=head2 ready_for_checkout

=head2 save_amend_order

=head2 search_product

=head2 server_date_time

=head1 TESTS

To fully exercise the tests set the following environment variables:

Tesco API credentials:

TESCO_APP_KEY=85CA7F234919EB59F3ED
TESCO_DEVELOPER_KEY=MrQlih6BiuArPquj5BMi

Your Tesco account credentials:

TESCO_EMAIL=daveh@hodgkinson.org
TESCO_PASSWORD=xxxxxxx

=head1 AUTHOR

Willem Basson <willem.basson@gmail.com>
David Hodgkinson <daveh@hodgkinson.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Willem Basson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
