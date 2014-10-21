use warnings;
use strict;
use Test::More;

# my $plans=3;

BEGIN { use_ok('DSL'); }

my @dsl_parse_tests=(
  "print 7;",
  "print 7;\n",
  "c=9+3;\n",
  "c=9+3; print c;",
  "c=9+3;\nprint c;\n",
  "c=9+3;y=c*2+1;print y;",
  "a=1d6;",
  "print 1d6;",
);
my @dsl_parse_tests_TODO=(
);

# plan tests => $plans + @dsl_parse_tests + @dsl_parse_tests_TODO;

can_ok('DSL', 'new');

our $dsl=DSL->new;

isa_ok($dsl, "DSL");

dsl_parse_test(@dsl_parse_tests);

is(0+$dsl->parse('print 7;')->do, 7, "print 7 gives 7");
is(0+$dsl->parse('print 1+1;')->do, 2, "print 1+1 gives 2");
is(0+$dsl->parse('print 1+2*3;')->do, 7, "print 1+2*3 gives 7");

TODO: {
  local $TODO='not yet implemented';
  dsl_parse_test(@dsl_parse_tests_TODO);
  is(0+$dsl->parse('a=7;print a;')->do, 7, "a=7; print 7 gives 7");
}

sub dsl_parse_test {
  my ($string, $compressed_string, $result, $compressed_result);
  while(@_) {
    $string=shift;
    
    $compressed_string=$string;
    $compressed_string=~s{\s+}{}g;
    $result=$dsl->parse($string);
    $result='UNDEF' unless (defined($result));
    if (ref $result and $result->can('prettyprint')) {
      $result=$result->prettyprint;
    }
    $compressed_result=$result;
    $compressed_result =~ s{\s+}{}g;
    $string=~s{\n}{\\n}g;
    $string=~s{\t}{\\t}g;
    ok($compressed_string eq $compressed_result, "parse: $string") or diag("returned: ", $result);
  }
}

done_testing;