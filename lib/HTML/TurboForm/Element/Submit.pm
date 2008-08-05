package HTML::TurboForm::Element::Submit;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);
__PACKAGE__->mk_accessors( qw/ pure / );

sub render{
  my ($self, $options, $view)=@_;
  if ($view) { $self->{view}=$view; }
  my $result='';
  my $disabled='';

  if ($self->label and ($self->label eq '')) {
    $self->label('&nbsp;');
  }

  my $class= "form_std";
  $class=$self->class if ($self->class);

  my $id='';
  $id=" id='$self->{name}' ";

  my $value=$self->value;
  $value= ' value="'.$value.'" ';

  if ($options->{frozen} == 1) {
    my $text= $value;
  }

  $result =$result.'<input class="'.$class.'" type="submit" '.$id.' name="'.$self->{name}.'" '.$value.'>' ;
  return $result if ($self->{pure});
  return $self->vor($options).$result.$self->nach;
}

sub get_dbix{
    my ($self)=@_;
    return 0;
}

1;


__END__

=head1 HTML::TurboForm::Element::Submit

Representation class for HTML Submit element.

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 render

Arguments: $options

returns HTML Code for Submit element.


=head1 AUTHOR

Thorsten Domsch, tdomsch@gmx.de

=cut



