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

Add a user,

    $ldap->add_user('username', 'Full Name', 'Surname', 'password', groupIdNumber, UidNumber);

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

    my $salt = join('',map { ('a' .. 'z','A' .. 'Z', 0 .. 9)[rand (26*2)+10] } 0..15);
    my $hash = "{crypt}" . crypt($password,"\$6\$$salt\$");
    my $dn = $self->dn;
    my $res = $self->_client->add("uid=$username,ou=People,$dn",
        attrs => [
            cn => $fullname,
            displayName => $fullname,
            gidNumber => $group_id,
            uidNumber => $uid,
            uid => $username,
            userPassword => $hash,
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

=head2 add_to_group

Adds a user to a group.  Note that it is the username that is passed
to the function, not the user id number.

    $ldap->add_to_group('Verified', 'col1');

=cut

sub add_to_group
{
    my $self = shift;
    my $group = shift;
    my $uid = shift;
    my $dn = $self->dn;
    my $res = $self->_client->modify("cn=$group,ou=Groups,$dn",
        add => {
            memberUid =>  [$uid]
        }
    );
    return $self->_success($res);
}

sub remove_from_group
{
    my $self = shift;
    my $group = shift;
    my $uid = shift;
    my $dn = $self->dn;

    return $self->_remove_from_group("cn=$group,ou=Groups,$dn", $uid);
}

sub _remove_from_group
{
    my $self = shift;
    my $group_dn = shift;
    my $uid = shift;
    my $res = $self->_client->modify($group_dn,
        delete => {
            memberUid =>  [$uid]
        }
    );
    return $self->_success($res);
}

sub remove_user
{
    my $self = shift;
    my $username = shift;
    my $dn = $self->dn;
    my $res = $self->_client->delete("uid=$username,ou=People,$dn");
    my $groups = $self->_groups_containing_user($username);
    for my $group ($groups->entries)
    {
        # remove from the group.
        $self->_remove_from_group($group->dn, $username);
    }
    return $self->_success($res);
}

=head2 get_user_info

Returns user information.

    $ldap->get_user_info($username);

=cut

sub _groups_containing_user
{
    my $self = shift;
    my $username = shift;

    my $query = sprintf("(memberUid=%s)", escape_dn_value($username));
    my $groups = $self->_client->search(base => 'ou=Groups,' . $self->dn, filter => $query);
    return $groups;
}

sub get_user_info
{
    my $self = shift;
    my $username = shift;

    my $query = sprintf("(uid=%s)", escape_dn_value($username));
    my @keys = qw/cn displayName gidNumber uidNumber uid sn homeDirectory/;
    my $mesg = $self->_client->search(base => 'ou=People,' . $self->dn, 
                                      filter => $query, attrs => \@keys);
    for my $entry ($mesg->entries)
    {
        my %user_info = map { $_ => $entry->get_attribute($_) } @keys;
        # FIXME: get groups

        my $groups = $self->_groups_containing_user($username);
        my @groups;
        for my $group ($groups->entries)
        {
            push @groups, $group->get_attribute('cn');
        }
        $user_info{groups} = \@groups;
        return \%user_info;
    }
    return undef;
    # return user info
    # and groups subscribed to
}


=head2 set_password

Sets the users password.

    $ldap->set_password($user, $newpassword);

=cut

sub set_password
{
    my $self = shift;
    my $username = shift;
    my $new_password = shift;
    my $dn = $self->dn;
    my $res = $self->_client->modify("uid=$username,ou=People,$dn", 
        replace => { userPassword => $new_password });
    return $self->_success($res);
}

=head2 authenticate

Authenticate a user.

    $ldap->authenticate($username, $password);

=head2 remove_user

Remove a user.

    $ldap->remove_user($username);

=head2 remove_from_group

Removes a user from a group.

    $ldap->remove_from_group('Moderator', 'col1');

=cut

sub authenticate
{
    my $self = shift;
    my $username = shift;
    my $password = shift;

    my $ldap = Net::LDAP->new($self->host) || failure::code4health::ldap->throw($@);
    my $query = sprintf("(uid=%s)", escape_dn_value($username));
    my $mesg = $self->_client->search(base => 'ou=People,' . $self->dn, filter => $query);
    for my $entry ($mesg->entries)
    {
        my $login = $ldap->bind($entry->dn, password => $password);
        return $self->_success($login);
    }
    # user not found
    return 0;
}

=head2 ensure_uid_not_used

Checks that the uidNumber is not in use.

    $ldap->ensure_uid_not_used(10003);

=cut

sub ensure_uid_not_used
{
    my $self = shift;
    my $uid = shift;
    my $query = sprintf("(uidNumber=%s)", escape_dn_value($uid));
    my $mesg = $self->_client->search(base => 'ou=People,' . $self->dn, 
                                      filter => $query, attrs => [1.1]);
    if($mesg->is_error)
    {
        failure::code4health::ldap->throw($mesg->error);
    }
    return $mesg->count == 0;
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
