package HTML::TurboForm::Element::Date;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);

sub render{
    my ($self, $options, $view)=@_;
    if ($view) { $self->{view}=$view; }  
    my $request=$self->request;
    my $result='';
    my $disabled='';
    my $class='form_date';     
    $self->label('&nbsp;') if ($self->label eq '');        
    $class=$self->{class}  if exists($self->{class});
    my $name=' name="'.$self->name;
    my $checked='';
    my $startyear=1977;
    my $endyear=2010;
    $startyear=$self->{params}->{startyear};
    $endyear=$self->{params}->{endyear};

    if ($options->{frozen} == 1){
        $disabled=' disabled ';
        $result.='<input type="hidden" name="'.$self->name.'_day" value="'.$request->{ $self->name.'_day' }.'">';
        $result.='<input type="hidden" name="'.$self->name.'_month" value="'.$request->{ $self->name.'_month' }.'">';
        $result.='<input type="hidden" name="'.$self->name.'_year" value="'.$request->{ $self->name.'_year' }.'">';
    }

    $result.='<select class="'.$class.'_day" '.$self->get_attr().$disabled.$name.'_day">';
    for (my $i=1;$i<32;$i++){
        $checked='';
        if ( $request->{ $self->name.'_day' } ){ $checked=' selected ' if ( $request->{ $self->name.'_day' } == $i);}
        $result.='<option '.$checked.' value="'.$i.'">'.$i.'</option>';
    }
    $result.='</select>';     
    $result.='<select class="'.$class.'_month" '.$self->get_attr().$disabled.$name.'_month">';
    my @month = qw(Januar Februar März April Mai Juni Juli August September Oktober November Dezember);
 
    for (my $i=0;$i<12;$i++){
        $checked='';
        if( $request->{ $self->name.'_month' } ){ $checked=' selected ' if ( $request->{ $self->name.'_month' } == ($i+1)); }
        $result.='<option '.$checked.' value="'.($i+1).'">'.$month[$i].'</option>';
    }

    $result.='</select>';     
    $result.='<select class="'.$class.'_year" '.$self->get_attr().$disabled.$name.'_year">';
    for (my $i=$startyear;$i<=$endyear;$i++){
        $checked='';
        if ($request->{ $self->name.'_year' } ){ $checked=' selected ' if ( $request->{ $self->name.'_year' } == $i);}
        $result.='<option '.$checked.' value="'.$i.'">'.$i.'</option>';
    }
    $result.='</select>';       

    return $self->vor($options).$result.$self->nach;  
}

sub get_value{
    my ($self) = @_;
    my $result='';        
    if ($self->{request}->{$self->name.'_day'}) {
       $result=$self->{request}->{$self->name.'_year'}.'-'.
               $self->{request}->{$self->name.'_month'}.'-'.
               $self->{request}->{$self->name.'_day'};
    }       
    return $result;
}

1;

__END__

=head1 HTML::TurboForm::Element::Date

Representation class for Date element consisting out of three seperate select boxes.

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 render

Arguments: $options

returns HTML Code for date element.

=head2 get_value

Arguments: none

returns selected Date as MySQL compatible String.

=head1 AUTHOR

Thorsten Domsch, tdomsch@gmx.de

=cut

