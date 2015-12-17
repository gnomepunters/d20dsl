#!/usr/bin/perl -w

package ORC::Operator::Multiplication;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;

has 'arguments' => (
  is => 'rw',
  isa => 'ArrayRef',
  required => 1
);

has 'operator' => (
  is => 'ro',
  isa => 'Str',
  init_arg => undef,
  default => '*',
);

with 'ORC::Operator';

sub from_parse {
  my $self=shift;
  my @terms;
  my @args;
  @args=@{$_[0]};

  die "even number of terms in " . __PACKAGE__ . "->from_parse(): " . join(', ', @args)
    if (scalar(@args) % 2 == 1);

  push @terms, shift @args;
  while(@args) {
    #shift @args;
    push @terms, shift @args;
  }

  return __PACKAGE__->new( arguments => \@terms );
  
}

# prettyprint should be in ORC::Operator

sub do {
  my $self=shift;
  my $value;
  my @args=@{$self->arguments};
  $value=shift @args;
  while(@args) {
    $value = $value * shift @args;
  }
  return $value;
}

__PACKAGE__->meta->make_immutable;

1;
