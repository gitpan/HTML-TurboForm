package HTML::TurboForm::Element::Select;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);

sub render{
    my ($self, $options)=@_;
    my $request=$self->request;
    my $result='';
    my $disabled='';
    my $class='form_select';     
    $self->label('&nbsp;') if ($self->label eq '');        
    $class=$self->{class}  if exists($self->{class});
    my $name=' name="'.$self->name.'" ';
    my $checked='';

    $disabled=' disabled ' if ($options->{frozen} == 1);
    
    $result.='<select class="'.$class.'" '.$self->get_attr().$disabled.$name.'>';
    my $result2='';
    while ( my( $key,$value) = each %{$self->options}){
        my $values = $request->{ $self->name };
        $values = [ $values ] unless ref( $values ) =~ /ARRAY/;
        $checked='';
        if ( $values && $value ) { $checked=' selected ' if ( grep { $_ eq $value } @{ $values } ); }
        $result.='<option '.$checked.' value="'.$value.'">'.$key.'</option>';        
        $result2.='<input type="hidden" '.$name.' value="'.$value.'">' if (($disabled ne '')&& ( $checked ne ''));
    }   
    $result.='</select>';       

  return $self->vor($options).$result.$result2.$self->nach;
}

1;


__END__

=head1 HTML::TurboForm::Element::Select

Representation class for HTMl SelectBox element.

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 render

Arguments: $options

returns HTML Code for select element.

=head1 AUTHOR

Thorsten Domsch, tdomsch@gmx.de

=cut


