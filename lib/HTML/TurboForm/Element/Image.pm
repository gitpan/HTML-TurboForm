package HTML::TurboForm::Element::Image;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);
use Imager;
__PACKAGE__->mk_accessors( qw/ upload width height savedir thumbnail loadurl / );

sub new{
    my ($class, $request, $upload) = @_;
    my $self = $class->SUPER::new( $request );
    $self->upload( $upload );
    return $self;
}
sub render{
    my ($self, $options)=@_;
    my $request=$self->request;
    my $result='';
    my $disabled='';
    my $class='form_select';     
    $self->label('&nbsp;') if ($self->label eq '');        
    $class=$self->{class}  if exists($self->{class});
    my $name=' name="'.$self->name.'_upload" ';
    my $checked='';
    my $pic='';

    $pic=$request->{$self->name} if ($request->{$self->name});

    $disabled=' disabled ' if ($options->{frozen} == 1);
    if ($options->{frozen} != 1 ){
    $result.='<input type="file" class="'.$class.'" '.$self->get_attr().$disabled.$name.'>';
    $result.='<input type="submit" value="'.$self->label.'" name="'.$self->name.'_submit">';
    }
    if ($request->{ $self->name.'_upload' } && $request->{$self->name.'_submit'} ) {    
          if( $self->upload->type !~ /^image\/(jpeg|jpg|gif|png|pjpeg)$/ ) {
                #$c->stash->{ 'error' } = 'Dieser Dateityp wird nicht unterstützt!';
            } else {
                # read image          
                my $image = Imager->new;
                if( $image->read( file => $self->upload->tempname ) ) {
                    # remove alpha channels because jpg does not support it  # and its not used anyways
                    $image = $image->convert( preset => 'noalpha' );
                    if (($self->width) and ($self->height) and ($self->savedir) ){                     
                        $image = $image->scale(xpixels=>$self->width,ypixels=>$self->height,type=>'min'); 
                        my $tmp = File::Temp->new( DIR => $self->savedir.'', UNLINK => 0, SUFFIX => '.jpg' );
                        $image->write( 
                            file        => $tmp, 
                            type        => 'jpeg', 
                            jpegquality => 90 
                        );
                        $pic = substr( $tmp, length( $self->savedir )+1 );
                        if ($self->thumbnail) {
                            if ($self->thumbnail->{width} && $self->thumbnail->{height} ) {
                                $image = $image->scale(xpixels=>$self->thumbnail->{width},ypixels=>$self->thumbnail->{height},type=>'min');  
                                $image->write( 
                                file        => $self->savedir.'/thumb_'.$pic, 
                                type        => 'jpeg', 
                                jpegquality => 90 
                                );
                            }    
                        }                  
                    }                    
                } 
           }           
      } 
      if ($pic ne ''){
         $result.="<img id='bigpic' src='".$self->loadurl."/".$pic."'>"; 
         $result.='<input type="hidden" name="'.$self->name.'" value="'.$pic.'">';
         $result.="<img id='thumbnail' src='".$self->loadurl."/thumb_".$pic."'>" if ($self->thumbnail) ;
      }  

  return $self->vor($options).$result.$self->nach;
}

1;


__END__

=head1 HTML::TurboForm::Element::Image

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

