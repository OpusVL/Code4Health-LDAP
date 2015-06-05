package Code4Health::LDAP;

use Moo;
use Types::Standard -types;
use Net::LDAP;
use Net::LDAP::Util qw/escape_dn_value/;
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
has user => (is => 'ro', isa => Str, default => 'admin');
has password => (is => 'ro', isa => Str, required => 1);

has _client => (is => 'ro', lazy => 1, builder => '_build_client');

sub _build_client
{
    my $self = shift;
    my $ldap = Net::LDAP->new($self->host) || failure::code4health::ldap->throw($@);
    my $user = $self->user;
    my $res = $ldap->bind("cn=$user," . $self->dn, password => $self->password);
    if($res->is_error)
    {
        failure::code4health::ldap->throw($res->error);
    }
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

  dc=code4health,dc=org

=head2 user

Defaulted to admin

=head2 password

The password for the user you're trying to bind to.

=head1 METHODS

=head2 add_user

=cut

sub add_user
{
    my $self = shift;
    my $username = shift;
    my $fullname = shift;
    my $surname = shift;
    my $password = shift;
    my $group_id = shift;
    my $uid = shift;

    my $dn = $self->dn;
    my $res = $self->_client->add("uid=$username,ou=People,$dn",
        attrs => [
            cn => $fullname,
            displayName => $fullname,
            gidNumber => $group_id,
            uidNumber => $uid,
            uid => $username,
            userPassword => $password,
            sn => $surname,
            homeDirectory => '/tmp', # FIXME: this seems ugly
            objectClass => [qw/posixAccount inetOrgPerson/],
        ]
    );
    return $self->_success($res);
}

=head2 add_group

Adds a group.

=cut

sub _success
{
    my $self = shift;
    my $res = shift;
    if($res->is_error)
    {
        failure::code4health::ldap->throw($res->error);
    }
    return 1;
}

sub add_group
{
    my $self = shift;
    my $name = shift;
    my $gid = shift;
    # FIXME: auto-generated gid if not provided
    my $dn = $self->dn;
    my $res = $self->_client->add("cn=$name,ou=Groups,$dn",
        attrs => [
            cn => $name,
            gidNumber => $gid,
            objectClass => 'posixGroup',
        ]
    );
    return $self->_success($res);
}

=head2 remove_user

Remove a user.

    $ldap->remove_user($username);

=cut

sub remove_user
{
    my $self = shift;
    my $username = shift;
    # FIXME: auto-generated gid if not provided
    my $dn = $self->dn;
    my $res = $self->_client->delete("uid=$username,ou=People,$dn");
    return $self->_success($res);
}

=head2 authenticate

Authenticate a user.

    $ldap->authenticate($username, $password);

=cut

sub authenticate
{
    my $self = shift;
    my $username = shift;
    my $password = shift;

    my $ldap = Net::LDAP->new($self->host) || failure::code4health::ldap->throw($@);
    my $query = sprintf("(uid=%s)", escape_dn_value($username));
    $DB::single = 1;
    my $mesg = $self->_client->search(base => 'ou=People,' . $self->dn, filter => $query);
    for my $entry ($mesg->entries)
    {
        my $login = $ldap->bind($entry->dn, password => $password);
        return $self->_success($login);
    }
    # user not found
    return 0;
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
