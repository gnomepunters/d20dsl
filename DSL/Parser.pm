#!/usr/bin/perl -w

use strict;
use warnings;

package DSL::Parser;

use Moose;
use Carp;


our $grammar=<<'END_OF_GRAMMAR';

start: statement(s) /^\Z/ { DSL::Script->new(statements => $item{'statement(s)'}) }

statement: 
  print_statement eos { $item[1] }
| assignment_statement eos { $item[1] }

eos:
  /;\s*/

print_statement:
  /print\s/ expression(s /,/) { "DSL::Statement::Print"->new(expressions => $item[2]) }

assignment_statement:
  variable equals expression { "DSL::Statement::Assignment"->new(variable => $item{variable}, expression => $item{expression}) }

equals: '='

variable:
  /(?!=print[^a-zA-Z0-9_])[a-zA-Z_][a-zA-Z0-9_]*/ { "DSL::Variable"->get($item[1]) }

expression: <leftop: term ('+' | '-') term>
  { 
    my $expressions=$item[1];
    if (ref $expressions ne 'ARRAY') {
      $return=$expressions;
    }
    elsif (@$expressions == 1) {
      $return=$expressions->[0];
      if (ref $return eq 'ARRAY' and @$return == 1) {
        $return=$return->[0];
      }
    }
    else {
      $return=DSL::Operator->from_parse($expressions);
    }
  }

term: <leftop: factor ('*' | '/') factor>
  {
    my $expressions=$item[1];
    if (ref $expressions ne 'ARRAY') {
      $return=$expressions;
    }
    elsif (@$expressions == 1) {
      $return=$expressions->[0];
      if (ref $return eq 'ARRAY' and @$return == 1) {
        $return=$return->[0];
      }
    }
    else {
      $return=DSL::Operator->from_parse($expressions);
    }
  }

factor:
  dieSimple
| number
| variable
| '(' expression ')' { $item[2] }

dieSimple: <skip:''> number 'd' number { DSL::Die->new(count => $item[2], pips => $item[4]); }

number: /\d+/ { DSL::Number->new(value => $item[1]) }

END_OF_GRAMMAR

# 1 while $grammar =~ s{\{[^\}\n]*\}}{}g;
# $grammar = "<autotree>\n" . $grammar;
has 'parser' => (
  is => 'ro',
  default => sub { Parse::RecDescent->new($grammar) },
  lazy => 1,
  handles => { parse => 'start' },
);

__PACKAGE__->meta->make_immutable;

1;
