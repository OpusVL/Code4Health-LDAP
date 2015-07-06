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
ok $ldap->add_group('Person', 5000);
ok $ldap->add_group('Verified', 5001);
ok $ldap->add_group('Moderator', 5002);

#ok $ldap->add_user('colin', 'Colin Newell', 'Newell', 'insecure', 5000, 10000);

done_testing;

