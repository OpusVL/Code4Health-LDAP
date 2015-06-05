requires "perl" => "5.006";

on 'build' => sub {
  requires "ExtUtils::MakeMaker" => "6.59";
  requires "Test::Most" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};
