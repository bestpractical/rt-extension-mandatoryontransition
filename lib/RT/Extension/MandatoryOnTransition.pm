use strict;
use warnings;
package RT::Extension::MandatoryOnTransition;

our $VERSION = '0.01';

=head1 NAME

RT-Extension-MandatoryOnTransition - Require core and custom fields on status transitions

=head1 DESCRIPTION

=head1 CAVEATS

This extension does B<not> affect "quick actions" (those without an update
type) configured in your lifecycle (and appearing in the ticket Actions menu).
If you're requiring fields on resolve, for example, and don't want folks to
have a "Quick Resolve" button that skips the required fields, adjust your
lifecycle config to provide an update type (i.e make it a non-quick action).

Quick actions may be supported in a future release.

=head1 INSTALLATION

=over

=item perl Makefile.PL

=item make

=item make install

May need root permissions

=item Edit your /opt/rt4/etc/RT_SiteConfig.pm

Add this line:

    Set(@Plugins, qw(RT::Extension::MandatoryOnTransition));

or add C<RT::Extension::MandatoryOnTransition> to your existing C<@Plugins> line.

Then configure which fields should be mandatory on certain status changes
(either globally or in a specific queue).  An example making two custom fields
mandatory before resolving a ticket in the Helpdesk queue:

    Set(%MandatoryOnTransition,
        Helpdesk => {
            '* -> resolved' => ['CF.{Resolution}', 'CF.{Problem area}'],
        });

The transition syntax is similar to that found in RT's Lifecycles.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 AUTHOR

Thomas Sibley <trs@bestpractical.com>

=head1 BUGS

All bugs should be reported via
L<http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Extension-MandatoryOnTransition>
or L<bug-RT-Extension-MandatoryOnTransition@rt.cpan.org>.


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2012 by Best Practical Solutions

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;
