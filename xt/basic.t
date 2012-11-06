use strict;
use warnings;

use RT::Extension::MandatoryOnTransition::Test tests => 20;

use_ok('RT::Extension::MandatoryOnTransition');

my ( $baseurl, $m ) = RT::Test->started_ok();

ok( $m->login( 'root', 'password' ), 'logged in' );
$m->get_ok($m->rt_base_url);

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

    $m->submit_form_ok( { form_name => 'TicketUpdate',
                          fields => { UpdateTimeWorked => 10 },
                          button => 'SubmitTicket',
                        }, 'Submit resolve with Time Worked');

    $m->content_contains("TimeWorked changed from &#40;no value&#41; to &#39;10&#39;");
    $m->content_contains("Status changed from &#39;open&#39; to &#39;resolved&#39;");
}
