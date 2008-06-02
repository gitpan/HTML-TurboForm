package HTML::TurboForm::Element::Range;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);
__PACKAGE__->mk_accessors( qw/ min max dbtype steps start1 start2 modules / );


sub init{
    my ($self)=@_;

    my $min = 0;
    my $max = 100;
    my $step = 10;
    my $start1 = $min;
    my $start2 = $max;

    print STDERR $self->name." : ".$self->min ." -> ". $self->max ."\n";

    if ($self->min)   { $self->{min}=$self->min; };
    if ($self->steps) { $step=$self->steps; } else {
        $step = $self->max - $self->min;
    };
    if ($self->max)   { $self->{max}=$self->max; };
    if ($self->start1)  { $start1=$self->start1; };
    if ($self->start2)  { $start2=$self->start2; };
    $self->{value}='';

	if ($self->request->{ $self->name }) {
		$self->{value} = $self->request->{ $self->name };
		my @vals = split(/,/, $self->request->{ $self->name });
		$self->{start1}= $vals[0];
		$self->{start2}= $vals[1];
	}

    @{$self->{modules}} = ('jquery/jquery-1.2.4b.min','jquery/ui.core.min','jquery/ui.slider.min');
    $self->{js} = '
        $("#'.$self->name.'_slider").slider({
			"steps": '.$step.',range:true,
			"min": '.$self->{min}.',
			"max": '.$self->{max}.',
			"slide": function(e, ui){
                var value1 = $("#'.$self->name.'_slider").slider("value",0);
                var value2 = $("#'.$self->name.'_slider").slider("value",1);
				var field = value1+","+value2;

                $("#'.$self->name.'_label1").html(value1.toFixed(0),0);
		        $("#'.$self->name.'_label2").html(value2.toFixed(0),1);
				$("#'.$self->name.'").val(field);
			}
		});  ';

    if ($self->start2){
        $self->{js} .=  '$("#'.$self->name.'_slider").slider("moveTo",'.$self->{start2}.',1);';
    }
    if ($self->start1){
        $self->{js} .=  '$("#'.$self->name.'_slider").slider("moveTo",'.$self->{start1}.',0);';
    }
}

sub get_value{
    my ($self)=@_;
    return $self->{value};
}


sub freeze{
    my ($self)=@_;
    $self->{js} .=  '$("#'.$self->name.'_slider").slider("disable");';
}

sub get_dbix{
    my ($self)=@_;

    my $dbname=$self->name if ($self->name);
    $dbname   =$self->dbsearchfield if ($self->dbsearchfield);

    my @vals = split(/,/, $self->get_value());
	my $low  = $vals[0];
	my $high = $vals[1];
    my $result = 0;

    if($self->get_value() ne '') {
        if ($self->dbtype) {
            $result = { 'CAST('.$dbname.' AS '.$self->dbtype.')' => { '>=' => [$low] , '<=' => [$high] } };
        } else {
            $result = {  $dbname => { '>=' => $low, '<=' => $high  } };
        }
    }
    return $result;
}

sub render {
  my ($self, $options, $view)=@_;
  if ($view) { $self->{view}=$view; }
  my $request=$self->request;
  my $result='';
  my $disabled='';
  my $class='form_text';

  $class = $self->class if ($self->class);

  my $name=$self->name;

  #print STDERR $self->{min}." bis ".$self->{max}."\n";

  #$self->{min} =~ s/^(.*?)\..*$/$1/ ;
  #$self->{max} =~ s/^(.*?)\..*$/$1/ ;

  $result='  <div class="slider_label">
             <span class="slider_label_min" id="'.$name.'_label1"></span>
             <span class="slider_label_max" id="'.$name.'_label2"></span>
             </div><br>
             <div id="'.$name.'_slider" class="ui-slider-2">
                <div id="first" class="ui-slider-handle">&nbsp;</div>
                <div id="second" class="ui-slider-handle">&nbsp;</div>
             </div>

            <input class="range_min" type="hidden" name="'.$name.'_min" id="'.$name.'_min" value="">
            <input class="range_max" type="hidden" name="'.$name.'_max" id="'.$name.'_max" value="">
			<input type="hidden" name="'.$name.'" id="'.$name.'" value="">
			';

  return $self->vor($options).$result.$self->nach;
}
1;

__END__

=head1 HTML::TurboForm::Element::Range

Representation class for HTML SLider input element with two Sliders. This Element uses the jquery Javascript library !

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 render

Arguments: $options

returns HTML Code for element.

=head1 AUTHOR

Thorsten Domsch, tdomsch@gmx.de

=cut


