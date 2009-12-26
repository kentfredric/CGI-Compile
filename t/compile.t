use Test::More;
use CGI::Compile;

my %orig_sig = %SIG;

my $sub = CGI::Compile->compile("t/hello.cgi");

is_deeply \%SIG, \%orig_sig, '%SIG preserved during compile';
%SIG = %orig_sig;

$ENV{REQUEST_METHOD} = 'GET';
$ENV{QUERY_STRING} = 'name=foo';

my $stdout = capture_out($sub);
like $stdout, qr/Hello foo counter=1/;

is_deeply \%SIG, \%orig_sig, '%SIG preserved during run';

$ENV{QUERY_STRING} = 'exit_status=1';
eval { capture_out($sub) };
like $@, qr/exited nonzero: 1/, 'non-zero exit status';

$ENV{QUERY_STRING} = 'name=bar';
$stdout = capture_out($sub);
like $stdout, qr/Hello bar counter=3/;

done_testing;


sub capture_out {
    my $code = shift;

    my $stdout;
    open my $oldout, ">&STDOUT";
    close STDOUT;
    open STDOUT, ">", \$stdout or die $!;
    select STDOUT; $| = 1;

    $code->();

    open STDOUT, ">&", $oldout;

    return $stdout;
}
