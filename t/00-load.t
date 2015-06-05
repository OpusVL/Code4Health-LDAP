#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Code4Health::LDAP' ) || print "Bail out!\n";
}

diag( "Testing Code4Health::LDAP $Code4Health::LDAP::VERSION, Perl $], $^X" );
