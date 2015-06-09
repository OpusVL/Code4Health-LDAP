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

ok $ldap->ensure_uid_not_used(10003);
ok $ldap->add_user($username, 'Colin Newell', 'Newell', $password, 5000, 10003), 'Create user';
ok ! $ldap->ensure_uid_not_used(10003);
ok $ldap->authenticate($username, $password), 'Authenticate';
ok $ldap->set_password($username, 'newpassword'), 'Set password';
ok $ldap->authenticate($username, 'newpassword'), 'Authenticate again';
throws_ok { $ldap->authenticate($username, $password) } 'failure::code4health::ldap', 'Fail to authenticate';
ok $ldap->remove_user($username), 'Remove user';

done_testing;
