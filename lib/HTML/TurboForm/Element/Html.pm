package HTML::TurboForm::Element::Html;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);

sub render {
  my ($self, $options)=@_;
 
  return $self->{text};
}

1;


__END__

=head1 HTML::TurboForm::Element::Html

Representation class for Html element .

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 render

Arguments: $options

returns HTML Code. This element is needed if you want to insert plain HTML Code in a certain Position in a form.


=head1 AUTHOR

Thorsten Domsch, tdomsch@gmx.de

=cut


