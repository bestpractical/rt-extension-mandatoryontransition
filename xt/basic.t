use strict;
use warnings;

use RT::Extension::MandatoryOnTransition::Test tests => 37;

use_ok('RT::Extension::MandatoryOnTransition');

my ( $baseurl, $m ) = RT::Test->started_ok();

ok( $m->login( 'root', 'password' ), 'logged in' );
$m->get_ok($m->rt_base_url);

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

diag "Try a resolve without TimeWorked";
{
    my $t = RT::Test->create_ticket(
         Queue => 'General',
         Subject => 'Test Mandatory On Resolve',
         Content => 'Testing',
         );

    ok( $t->id, 'Created test ticket: ' . $t->id);
    ok( $t->SetStatus('open'), 'Set status to open');
    $m->goto_ticket($t->id);

    $m->follow_link_ok( { text => 'Resolve' }, 'Try to resolve ticket');
    $m->submit_form_ok( { form_name => 'TicketUpdate',
                          button => 'SubmitTicket',},
                          'Submit resolve with no Time Worked');
    $m->content_contains('Time Worked is required when changing Status to resolved');
    $m->content_contains('Test Field is required when changing Status to resolved');

    $m->submit_form_ok( { form_name => 'TicketUpdate',
                          fields => { UpdateTimeWorked => 10,
                                    'Object-RT::Ticket-' . $t->id . '-CustomField-1-Values' => 'foo'},
                          button => 'SubmitTicket',
                        }, 'Submit resolve with Time Worked and Test Field');

    $m->content_contains("TimeWorked changed from &#40;no value&#41; to &#39;10&#39;");
    $m->content_contains("Status changed from &#39;open&#39; to &#39;resolved&#39;");
}

diag "Try a resolve without TimeWorked in mobile interface";
{
    $m->get_ok($m->rt_base_url . "/m/");

    $m->follow_link_ok( { text => 'New ticket' }, 'Click New ticket');
    $m->title_is('Create a ticket');
    $m->follow_link_ok( { text => 'General' }, 'Click General queue');
    $m->title_is('Create a ticket');

    $m->submit_form_ok( { form_name => 'TicketCreate',
                        }, 'Create new ticket');

    my $title = $m->title();
    my ($ticket_id) = $title =~ /^#(\d+)/;
    like( $ticket_id, qr/\d+/, "Got number $ticket_id for ticket id");

    $m->get_ok($m->rt_base_url . "/m/ticket/show/?id=$ticket_id");

    $m->follow_link_ok( { text => 'Reply' }, 'Click Reply link');

    $m->submit_form_ok( { form_number => 1,
                          fields => { Status => 'resolved' },
                          button => 'SubmitTicket',
                        }, 'Submit resolve with no Time Worked');

    $m->content_contains('Time Worked is required when changing Status to resolved');
    $m->content_contains('Test Field is required when changing Status to resolved');

    $m->submit_form_ok( { form_number => 1,
                          fields => { UpdateTimeWorked => 10,
                                    'Object-RT::Ticket-' . $ticket_id . '-CustomField-1-Values' => 'foo'},
                          button => 'SubmitTicket',
                        }, 'Submit resolve with Time Worked and Test Field');

    # Try to confirm the page was updated.
    $m->title_like(qr/^#$ticket_id:/, "Page title starts with ticket number $ticket_id");
    like($m->uri->as_string, qr/show/, "On show page after ticket resolve");
}
