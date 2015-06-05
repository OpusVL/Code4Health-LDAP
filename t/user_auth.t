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

my $username = 'test-auth';
my $password = 'testpassword';

ok $ldap->add_user($username, 'Colin Newell', 'Newell', $password, 5000, 10000), 'Create user';
ok $ldap->authenticate($username, $password), 'Authenticate';
ok $ldap->remove_user($username), 'Remove user';

done_testing;
