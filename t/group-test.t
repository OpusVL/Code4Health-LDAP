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

ok $ldap->add_user('col4', 'Colin Newell', 'Newell', 'insecure', 5001, 10002), 'Create user';
ok $ldap->add_user('col5', 'Colin Newell', 'Newell', 'insecure', 5002, 10003), 'Create user';
ok $ldap->add_user('col6', 'Colin Newell', 'Newell', 'insecure', 5003, 10004), 'Create user';

ok $ldap->add_to_group('Verified', 'col4');

for my $user (qw/col1 col2 col3/)
{
    ok $ldap->remove_user($user), 'Remove user';
}

done_testing;
