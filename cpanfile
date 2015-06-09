requires "Moo" => "0";
requires "Net::LDAP" => "0";
requires "Types::Standard" => "0";
requires "failures" => "0";
requires "namespace::clean" => "0";
requires "perl" => "5.006";

on 'build' => sub {
  requires "ExtUtils::MakeMaker" => "6.59";
  requires "Test::Most" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};
