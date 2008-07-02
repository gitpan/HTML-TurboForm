package HTML::TurboForm::Element::Radio;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);
__PACKAGE__->mk_accessors( qw/ listmode /);

sub render{
    my ($self, $options, $view)=@_;
    if ($view) { $self->{view}=$view; }
    my $request=$self->request;
    my $result='';
    my $disabled='';
    my $class='form_radio';

    $self->label('&nbsp;') if ($self->label eq '');
    $class=$self->{class}  if exists($self->{class});
    my $aha=$self->options;
    my $name=' name="'.$self->name.'" ';
    my $checked='';

    $disabled=' disabled ' if ($options->{frozen} == 1) ;

    my $pre='';
    my $post='';
    my $after='';

   if ( $self->listmode ){
        $result.='<ul>';
        $pre='<li>';
        $post='</li>';
        $after='</ul>';
    }

    while ( my( $key,$value) = each %{$self->options}){
        my $values = $request->{ $self->name };
        if (! $values){
           $values = $self->default;
        }

        $values = [ $values ] unless ref( $values ) =~ /ARRAY/;
        $checked='';
        if ([ $values ]) { $checked=' checked ' if ( grep { $_ eq $value } @{ $values } ); }
        $result.=$pre.'<input type="radio" '.$checked.$disabled.$name.' value="'.$value.'">'.$key.$post;
        $result.='<input type="hidden" '.$name.' value="'.$value.'">' if (($disabled ne '')&& ( $checked ne ''));
    }

   $result.=$after;
   $result= $self->vor($options).$result.$self->nach if ($self->check_param('norow')==0);
  return $result;
}

1;


__END__

=head1 HTML::TurboForm::Element::Radio

Representation class for HTML Radiobox element.

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 render

Arguments: $options

returns HTML Code for Radiobox.

=head1 AUTHOR

Thorsten Domsch, tdomsch@gmx.de

=cut


