use Test::Most;
BEGIN {
    unless ($ENV{LDAP_HOST})
    {
        # NOTE: the test server needs to have a project named Test-Project on it to pass.
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
ok $ldap->add_group('Person', 5000);

done_testing;

