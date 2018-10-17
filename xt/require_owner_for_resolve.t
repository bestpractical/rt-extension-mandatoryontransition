use strict;
use warnings;

use RT::Extension::MandatoryOnTransition::Test tests => undef, config => <<CONFIG
Set( %MandatoryOnTransition,
     '*' => {
         '* -> resolved' => ['Owner',],
     }
    );
CONFIG
  ;

use_ok('RT::Extension::MandatoryOnTransition');

my ( $baseurl, $m ) = RT::Test->started_ok();

ok( $m->login( 'root', 'password' ), 'logged in' );
$m->get_ok($m->rt_base_url);

diag "Test requiring an Owner to resolve tickets";
{
    my $t = RT::Test->create_ticket(
         Queue => 'General',
         Subject => 'Test Mandatory Owner On Resolve',
         Content => 'Testing',
         );

    ok( $t->id, 'Created test ticket: ' . $t->id);

    $m->goto_ticket($t->id);

    $m->follow_link_ok( { text => 'Resolve' }, 'Try to resolve ticket');
    $m->content_contains('Test Mandatory Owner On Resolve');
    $m->submit_form_ok( { form_name => 'TicketUpdate',
                          button => 'SubmitTicket',},
                        'Submit resolve with no Owner set');
    $m->content_contains('Owner is required when changing Status to resolved');
    $m->submit_form_ok( { form_name => 'TicketUpdate',
                          button => 'SubmitTicket',
                          fields => { Owner => RT->SystemUser->id }},
                        'Submit resolve with Owner set');
    $m->content_lacks('Owner is required when changing Status to resolved');
}

undef $m;
done_testing;
