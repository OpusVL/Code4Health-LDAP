package Code4Health::LDAP;

use Moo;
use Types::Standard -types;
use Net::LDAP;
use failures qw/code4health::ldap/;
use namespace::clean;

=head1 NAME

Code4Health::LDAP - Wrapper around LDAP

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has host => (is => 'ro', isa => Str, required => 1);
has dn => (is => 'ro', isa => Str, required => 1);
has password => (is => 'ro', isa => Str, required => 1);

has _client => (is => 'ro', lazy => 1, builder => '_build_client');

sub _build_client
{
    my $self = shift;
    my $ldap = Net::LDAP->new($self->host) || failure::code4health::ldap->throw($@);
    $ldap->bind($self->dn, { password => $self->password });
    return $ldap;
}

=head1 SYNOPSIS

This module will allow access to users and groups within LDAP.

    use Code4Health::LDAP;

    my $ldap = Code4Health::LDAP->new();
    $ldap->add_user('test');
    ...

=head1 ATTRIBUTES

=head2 host

Hostname of the ldap server.

=head2 dn

dn to bind to when connecting, normally something like 

  cn=admin,dc=code4health,dc=org

=head2 password

The password for the user you're trying to bind to.

=head1 METHODS

=head2 add_user

=cut

sub add_user
{
    my $self = shift;
    my $username = shift;
    my $data = shift;

}

=head1 AUTHOR

OpusVL, C<< <support at opusvl.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-code4health-ldap at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Code4Health-LDAP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.


=cut

1; # End of Code4Health::LDAP
