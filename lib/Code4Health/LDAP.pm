package Code4Health::LDAP;

use Moo;

=head1 NAME

Code4Health::LDAP - Wrapper around LDAP

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module will allow access to users and groups within LDAP.

    use Code4Health::LDAP;

    my $ldap = Code4Health::LDAP->new();
    $ldap->add_user('test');
    ...

=head1 METHODS

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
