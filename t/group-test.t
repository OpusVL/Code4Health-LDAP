use Test::Most;
BEGIN {
    unless ($ENV{LDAP_HOST})
    {
        plan skip_all => "Set LDAP_HOST and LDAP_DN and LDAP_PASSWORD to run these tests.";
    }
}

use Code4Health::LDAP;

my $ldap = Code4Health::LDAP->new({ 
    host => $ENV{LDAP_HOST}, 
    dn => $ENV{LDAP_DN},
    user => $ENV{LDAP_USER} || 'admin',
    password => $ENV{LDAP_PASSWORD},
});

ok $ldap->add_user('col1', 'Colin Newell', 'Newell', 'insecure', 5001, 10002), 'Create user';
ok $ldap->add_user('col2', 'Colin Newell', 'Newell', 'insecure', 5002, 10003), 'Create user';
ok $ldap->add_user('col3', 'Colin Newell', 'Newell', 'insecure', 5003, 10004), 'Create user';

ok $ldap->add_to_group('Verified', 'col1');
ok $ldap->add_to_group('Moderator', 'col1');
ok $ldap->remove_from_group('Moderator', 'col1');

for my $user (qw/col1 col2 col3/)
{
    ok $ldap->remove_user($user), 'Remove user';
}

done_testing;
