package HTML::TurboForm::Element;

use warnings;
use strict;
use base qw/ Class::Accessor /;
__PACKAGE__->mk_accessors( qw/ params default dbsearchfield dbdata dbid dblabel ignore_dbix type id name label text value request options class left_class right_class row_class attributes table columns / );


sub new{
    my ($class, $request) = @_;
    my $self = $class->SUPER::new( $request );
    $self->{view} ='';
    $self->{submitted} = 0;

    if ($self->dbdata and $self->dbid and $self->dblabel){
       my @t = @{ $self->dbdata };
       foreach (@t){
            my $label_method = $self->dblabel;
            my $value_method = $self->dbid;
            my $l=$_->$label_method;
            my $v=$_->$value_method;
            $self->options->{$l}=$v;
       }
    }

    $self->init();
    return $self;
}

sub init{
   my ($self) = @_;
}

sub add_options{
   my ($self, $opt) = @_;
   $self->{options} = $opt;
}

sub freeze{
    my($self) =@_;
}

sub get_attr{
    my ($self) =@_;
    my $result="";

    while ( my( $key,$value) = each %{$self->{attributes}}){
        if ($value) {
            $result.=' '.$key.'="'.$value.'"';
        } else {
            $result.=' '.$key;
        }
    }

    return $result.' ';
}

sub check_param{
    my ($self, $name)=@_;
    my $result=0;
    if ( exists($self->{params}->{ $name })) {
        $result=1;
    }
    return $result;
}

sub get_dbix{
    my ($self)=@_;

    if (!$self->ignore_dbix) {
        my $dbname=$self->name if ($self->name);
        $dbname   =$self->dbsearchfield if ($self->dbsearchfield);

        if($self->get_value() ne '') {
            return { $dbname => $self->get_value() };
        } else {
            return 0;
        }
    }  else {return 0;}
}

sub vor{
    my ($self,$options)=@_;
    my $error='';
    $error=$options->{error_message};
    my $result='';
    my $table='';

    my $rwc='';
    my $rtc='';
    my $ltc='';
    my $class='class="form_row"';

    if ($self->{class}) {       $class='class="'.$self->{class}.'"'; }
    if ($self->{row_class}) {   $rwc  = " class='".$self->{row_class}."' ";  }
    if ($self->{right_class}) { $rtc  = " class='".$self->{right_class}."' "; }
    if ($self->{left_class}) {  $ltc  = " class='".$self->{left_class}."' ";  }

#   if ($self->table>(-1)) {
#       $table='<td>';
#       if ($self->colcount==1) $table='<tr><td>';
#    }

    if ($self->{view} eq '') {
        if ($error ne '') {
            $error="<div class='form_error'>$error</div>";
        }

        $result=$table."<div ".$class.$rwc.">".$error.
                       "<div class='form_left'".$ltc.">".$self->label."</div>".
                       "<div class='form_right'".$rtc.">";
        $result=$table."<div ".$class.$rwc.">" if ($self->type eq "Html");
    }

    if ($self->{view} eq 'table') {
        if ($error ne '') {
            $error='<tr><td colspan="2" class="form_error">'.$error.'</td></tr>';
        }

        $result = $table. $error. "<tr ". $class. $rwc.">".
                       "<td class='form_left'".$ltc.">".$self->label."</td>".
                       "<td class='form_right'".$rtc.">";

        $result=$table.'<tr><td colspan="2" '.$class.$rwc.'>' if ($self->type eq "Html");
    }

    return $result;
}

sub nach{
    my ($self)=@_;
    my $result= "</div></div>";
    my $table='';

#    if ($self->table>(-1)) {
#      $table='</td>';
#       if ($self->table==$self->colcount) $table='</tr></td>';
#    }
#    $result.=$table;
    $result="</div>" if ($self->type eq "Html");

    if ($self->{view} eq 'table') {
        $result="</td></tr>";
    }
    $result.="\n";
    return $result;
}

sub get_value{
    my ($self) = @_;
    my $result='';
    $result=$self->{request}->{$self->name} if exists($self->{request}->{$self->name});
    return $result;
}


1;


__END__

=head1 HTML::TurboForm::Element

Base Class for HTML elements

=head1 SYNOPSIS

$form->addelement(...);

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 add_options

Arguments: $options

adds option tags to a html element

=head2 get_value

Arguments: none

returns value of the element

=head2 get_attr

Arguments: none

Return List of attributes of HTML Tag

=head2 check_param

Arguments: $name

checks if param with given name does exist

=head2 nach

Arguments: none

returns given prehtml

=head2 vor

Arguments: none

return given posthtml

=head1 AUTHOR

Thorsten Domsch, tdomsch@gmx.de

=cut

