package HTML::TurboForm::Element;

use warnings;
use strict;
use base qw/ Class::Accessor /;
__PACKAGE__->mk_accessors( qw/ params type name label text value request options class attributes table columns / );


sub add_options{
   my ($self, $opt) = @_;
   $self->{options} = $opt;  
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

sub vor{
    my ($self,$options)=@_;
    my $error='';
    $error=$options->{error_message};
    my $result='';
    my $table='';

    if ($error ne '') {
        $error="<div class='form_error'>$error</div>";
    }

#   if ($self->table>(-1)) {
#       $table='<td>';
#       if ($self->colcount==1) $table='<tr><td>';        
#    }

    $result=$table."<div class='form_row'>".$error."<div class='form_left'>".$self->label."</div><div class='form_right'>";
    $result=$table."<div class='form_row'>" if ($self->type eq "html");
    
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


    $result="</div>" if ($self->type eq "html");
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

