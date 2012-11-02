use strict;
use warnings;

use RT::Extension::MandatoryOnTransition::Test tests => 13;

use_ok('RT::Extension::MandatoryOnTransition');

diag "Test RequiredFields without a ticket";
{
    my ($core, $cf) = RT::Extension::MandatoryOnTransition->RequiredFields(
                           From => 'open',
                           To   => 'resolved',
                       );
    is( $core->[0], 'TimeWorked', 'Got TimeWorked for required core');

    ($core, $cf) = RT::Extension::MandatoryOnTransition->RequiredFields(
                           From => "''",
                           To   => 'resolved',
                           Queue => 'General',
                       );

    is( $core->[0], 'TimeWorked', 'Got TimeWorked for required core');
    is( $cf->[0], 'Test Field', 'Got Test Field for required custom field');
}

diag "Test RequiredFields with a ticket";
{
    my $t = RT::Test->create_ticket(
         Queue => 'General',
         Subject => 'Test Mandatory On Resolve',
         Content => 'Testing',
         );

    ok( $t->id, 'Created test ticket: ' . $t->id);

    my ($core, $cf) = RT::Extension::MandatoryOnTransition->RequiredFields(
                           Ticket => $t,
                           To   => 'resolved',
                       );

    is( $core->[0], 'TimeWorked', 'Got TimeWorked for required core');
    is( $cf->[0], 'Test Field', 'Got Test Field for required custom field');
}
