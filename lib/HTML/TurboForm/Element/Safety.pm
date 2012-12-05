package HTML::TurboForm::Element::Safety;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);
__PACKAGE__->mk_accessors( qw/ class special listmode pre post position labelclass/);


sub init{
    my ($self)=@_;

    my @names_o=('ape','dog','cat','unicorn','ant','bat','cow','fly','emu','gar','goose','koala','liger','otter','olm','moose','pig','pug','rat','snail');
    my @names_e=('lion','bird','donkey','dragon','wale','bear','dodo','fish','frog','goat','hare','kiwi','kudu','ibis','mole','newt','pike','puma','seal','tang');   
    my @possible_values=('1942','megatron','yellow','withbluespots','breathing','something','rogueninja','profx');

    $self->{names_o}=[@names_o];
    $self->{names_e}=[@names_e];
    $self->{p_v}=[@possible_values];
    my $n_e;
    my $n_o;
    
    while ( my ($k, $v) = each($self->{request}) ) {        
        foreach(@names_e){  $n_e=$_ if ($_ eq $k); }
        foreach(@names_o){  $n_o=$_ if ($_ eq $k); }
    }    
    my $tmp=0;    
    if ($n_e){    
        my $val=$self->{request}->{$n_e};
        foreach(@possible_values){ $tmp=1 if ($_ eq $val); }        
    }    
    $self->{value}='spam';
    $self->{value}='1' if ($n_o && $self->{request}->{$n_o} eq '' && $tmp==1);
}

sub get_value{
    my ($self) = @_;
    return $self->{value};
}

sub render{
    my ($self, $options, $view)=@_;
    if ($view) { $self->{view}=$view; }
    my $request=$self->request;
        
   my $result='';   
   my $name_o= $self->{names_o}[rand(scalar(@{ $self->{names_o}}))];
   my $name_e= $self->{names_e}[rand(scalar(@{ $self->{names_e}}))];
   my $rval= $self->{p_v}[rand(scalar(@{ $self->{p_v}}))];      
   $result.='<div style="display: none">';
   $result.='<input type="text" name="'.$name_o.'">';
   $result.='<input type="text" name="'.$name_e.'">';
   $result.='</div>';
   $result.='<script>$("[name='.$name_e.']").attr("value","'.$rval.'");</script>';    
  return $result;
}

1;

__END__

=head1 HTML::TurboForm::Element::Safety

Representation class for HTML Safety element.

=head1 DESCRIPTION

Straight forward so no need for much documentation.
See HTML::TurboForm doku for mopre details.

=head1 METHODS

=head2 render

Arguments: $options

returns HTML Code for Safety.

=head1 AUTHOR

Thorsten Drobnik, thorsten@base-10.net

=cut
