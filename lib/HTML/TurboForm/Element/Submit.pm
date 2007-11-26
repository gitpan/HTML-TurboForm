package HTML::TurboForm::Element::Submit;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);

sub render{
  my ($self, $options)=@_;
  my $result='';
  my $disabled='';
  my $class='form_submit';
  if ($self->label eq '') { 
    $self->label('&nbsp;');
  }
  
  $class=$self->{class} if exists($self->{class});
  my $id='';
  $id=" id='$self->{id}' " if exists($self->{id});

  my $value=$self->value;
  $value= ' value="'.$value.'" ';

  if ($options->{frozen} == 1) {
    my $text= $value;    
  }
    
  $result =$result.'<input class="form_std" type="submit" '.$id.' name="'.$self->{name}.'" '.$class.$value.'>' ;  
  return $self->vor($options).$result.$self->nach;
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



