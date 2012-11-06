use strict;
use warnings;

use RT::Extension::MandatoryOnTransition::Test tests => 19;

use_ok('RT::Extension::MandatoryOnTransition');

my ( $baseurl, $m ) = RT::Test->started_ok();

ok( $m->login( 'root', 'password' ), 'logged in' );

my $cf = RT::CustomField->new($RT::SystemUser);
my ( $id, $ret, $msg );

diag "Create custom field";
( $id, $msg ) = $cf->Create(
    Name      => 'Test Field',
    Type      => 'Select',
    LookupType => 'RT::Queue-RT::Ticket',
    MaxValues => '1',
    Queue     => 'General',
);

ok( $id, $msg );
$cf->AddValue( Name => 'foo' );
$cf->AddValue( Name => 'bar' );

diag "Test mandatory fields on create";
{
    $m->get_ok($m->rt_base_url);
    $m->submit_form_ok( { form_name => 'CreateTicketInQueue',
                          fields => { Queue => 'General',},
                        }, 'Click button to create ticket');

    $m->title_is('Create a new ticket');

    $m->submit_form_ok( { form_name => 'TicketCreate',
                          fields => { Status => 'resolved' },
                        }, 'Submit with resolved status');

    $m->content_contains('Time Worked is required when changing Status to resolved');
    $m->content_contains('Test Field is required when changing Status to resolved');

    $m->submit_form_ok( { form_name => 'TicketCreate',
                          fields => { Status => 'resolved',
                                    'Object-RT::Ticket--CustomField-1-Values' => 'foo'},
                        }, 'Submit with resolved status');

    $m->content_contains('Time Worked is required when changing Status to resolved');

    $m->submit_form_ok( { form_name => 'TicketCreate',
                          fields => { Status => 'resolved',
                                      'Object-RT::Ticket--CustomField-1-Values' => 'foo',
                                      'TimeWorked' => '10', },
                        }, 'Submit with resolved status');

    $m->content_contains("Ticket 1 created in queue &#39;General&#39;");
}
