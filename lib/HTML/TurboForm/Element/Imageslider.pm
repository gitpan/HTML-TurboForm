package HTML::TurboForm::Element::Imageslider;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);
__PACKAGE__->mk_accessors( qw/ noimgs / );


sub init{
    my ($self)=@_;

    @{$self->{modules}} = ('jquery/jquery','jquery/jcarousellite_1.0.1.min', 'jquery/easing');
    my $name=$self->name;

    $self->{js} = '
        $(function() {
            $("#'.$name.'").jCarouselLite({
                btnNext: "#next_'.$name.'",
                btnPrev: "#prev_'.$name.'"
            });
        });
       ';
}

sub render{
    my ($self, $options, $view)=@_;
    if ($view) { $self->{view}=$view; }
    my $result='';
    my $disabled='';
    my $class='form_slider';
    my $request=$self->request;

    $self->label('&nbsp;') if ($self->label eq '');

    $class=$self->{class}  if exists($self->{class});
    my $aha=$self->options;
    my $name=$self->name;

    $disabled=' disabled ' if ($options->{frozen} == 1);
    $result='<div class="slider_img" style="float:left;" id="prev_'.$name.'"><<</div>';
    $result.='<div class="slider_img" style="float:right;" id="next_'.$name.'">>></div>'."\n";
    #$result.='<center>upload img</center>';
    $result.='<div class="'.$class.'" id="'.$name.'"><ul>'."\n";

    foreach (@{$self->options}){
        $result.='<li><img src="'.$_.'" border="0"/></li>'."\n" if (!$self->noimgs);
        $result.='<li>'.$_.'</li>'."\n" if ($self->noimgs);
    }
    $result.="</ul></div>";
  $result= $self->vor($options).$result.$self->nach if ($self->check_param('norow')==0);
  return $result;
}

sub get_dbix{
    my ($self)=@_;
    return 0;
}

1;


__END__

=head1 HTML::TurboForm::Element::Imageslider

Representation class for Imageslider element.

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 render

Arguments: $options

returns HTML Code for checkbox element.

=head1 AUTHOR

Thorsten Domsch, tdomsch@gmx.de

=cut



