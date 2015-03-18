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


our $VERSION = '0.02';

our $SECURE_ENDPOINT =
  'https://secure.techfortesco.com/tescolabsapi/restservice.aspx?';
our $USER_AGENT = LWP::Curl->new(user_agent => __PACKAGE__ . '_' . $VERSION);


has 'app_key'       => (is => 'ro', isa => 'Str', required => 1);
has 'developer_key' => (is => 'ro', isa => 'Str', required => 1);

has 'debug' => (is => 'ro', isa => 'Bool', default => 0);

has 'secure_url' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => $SECURE_ENDPOINT,
);

has 'session_key' => (is => 'rw', isa => 'Str');


sub get {
    my $self = shift;
    my $args = shift;
    my $urlstring = $self->secure_url ;

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
   # warn $res if $self->debug();

    return JSON->new->utf8->decode($res);
}


sub login {
    my $self = shift;

    my $result = $self->get(
        {   command        => 'LOGIN',
            email          => '',
            password       => '',
            applicationkey => $self->app_key(),
            developerkey   => $self->developer_key(),
            secure         => 1,
        }
    );

    $self->session_key($result->{SessionKey});

    return $result;
}


sub product_search {
    my $self = shift;
    my $args = shift;

    $args->{sessionkey} = $self->session_key;
    $args->{command}    = 'PRODUCTSEARCH';
    return $self->get($args);
}



sub list_product_categories {
    my $self = shift;
    return $self->get({command => 'LISTPRODUCTCATEGORIES',
                       sessionkey => $self->session_key });
}


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


=head1 AUTHOR

Willem Basson <willem.basson@gmail.com>
David Hodgkinson <daveh@hodgkinson.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Willem Basson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
