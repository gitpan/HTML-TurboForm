package HTML::TurboForm::Element::Image;
use warnings;
use strict;
use base qw(HTML::TurboForm::Element);
use Imager;
__PACKAGE__->mk_accessors( qw/ noprev upload keeporiginal width height savedir thumbnail loadurl caption / );

sub new{
    my ($class, $request, $upload) = @_;
    my $self = $class->SUPER::new( $request );
    $self->upload( $upload );

    $self->do_img();
    return $self;
}

sub do_img{
    my ($self)=@_;
    my $request=$self->request;
    my $pic='';
    if ($request->{ $self->name.'_upload' } && $request->{$self->name.'_submit'} ) {
        if( $self->upload->type !~ /^image\/(jpeg|jpg|gif|png|pjpeg)$/ ) {
                #$c->stash->{ 'error' } = 'Filetype not supported!';
        } else {
            # read image
            my $image = Imager->new;
            if( $image->read( file => $self->upload->tempname ) ) {
                # remove alpha channels because jpg does not support it  # and its not used anyways
                $image = $image->convert( preset => 'noalpha' );
                #attribute keeporignal isparams local path for storing orig sized images

                my $tmp = File::Temp->new( DIR => $self->savedir.'', UNLINK => 0, SUFFIX => '.jpg' );
                $pic = substr( $tmp, length( $self->savedir )+1 );
                $self->{pic}=$pic;

                if ($self->keeporiginal){
                    $image->write(
                            file        => $self->keeporiginal.'/orig_'.$pic,
                            type        => 'jpeg',
                            jpegquality => 90
                    );
                }

                if (($self->width) and ($self->height) and ($self->savedir) ){
                    $image = $image->scale(xpixels=>$self->width,ypixels=>$self->height,type=>'min');
                    $image->write(
                        file        => $self->savedir.'/med_'.$pic,
                        type        => 'jpeg',
                        jpegquality => 90
                    );

                    if ($self->thumbnail) {
                        if ($self->thumbnail->{width} && $self->thumbnail->{height} ) {
                            $image = $image->scale(xpixels=>$self->thumbnail->{width},ypixels=>$self->thumbnail->{height},type=>'min');
                            my $thmb_fn = $self->savedir.'/thumb_'.$pic;
                            $thmb_fn = $self->thumbnail->{savedir}.'/thumb_'.$pic if ($self->thumbnail->{savedir});
                                $image->write(
                                file        => $thmb_fn,
                                type        => 'jpeg',
                                jpegquality => 90
                            );
                        }
                    }
                    unlink($self->savedir.'/'.$pic);
                 }
            }
        }
    }
}

sub get_value{
    my ($self) = @_;
    my $result='';
    $result=$self->{pic};
    return $result;
}

sub render{
    my ($self, $options, $view)=@_;
    if ($view) { $self->{view}=$view; }
    my $request=$self->request;
    my $result='';
    my $disabled='';
    my $class='form_image_select';
    $self->label('&nbsp;') if ($self->label eq '');
    $class=$self->{class}  if exists($self->{class});
    my $name=' name="'.$self->name.'_upload" ';
    my $checked='';
    my $pic='';
    $pic=$request->{$self->name} if ($request->{$self->name});

    $pic= $self->{pic};

    $disabled=' disabled ' if ($options->{frozen} == 1);
    if ($options->{frozen} != 1 ){
        $result.='<input type="file" class="'.$class.'" '.$self->get_attr().$disabled.$name.'>';
        $result.='<input type="submit" class="form_image_submit" value="'.$self->caption.'" name="'.$self->name.'_submit">';
    }

    $result.='<input type="hidden" name="'.$self->name.'" value="'.$pic.'">';
    if ($pic ne ''){
        $result.="<br /><br />";
        $result.="<img id='thumbnail' src='".$self->loadurl."/thumb_".$pic."'>" if (($self->thumbnail) && (!$self->noprev));
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


