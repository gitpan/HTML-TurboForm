package HTML::TurboForm;

use 5.6.1;

use strict;
use warnings;

use UNIVERSAL::require;
use YAML::Syck;

our $VERSION='0.02';

sub new{
  my ($class, $r)=@_;
  my $self = {};
  $self->{request}= $r;
  $self->{submitted} = 0;
  $self->{submit_value} = '';
  $self->{count}=0;

  bless( $self, $class );  
  return $self;
}

sub add_constraint{
  my ($self, $params) = @_;
  
  my $name= $params->{name};
  $params->{request}=$self->{request};
  my $class_name = "HTML::TurboForm::Constraint::" . $params->{ type };
  $class_name->require() or die "Constraint Class '" . $class_name . "' does not exist: $@";  
  my $new_len =  push(@ { $self->{constraints} }, $class_name->new($params));
}

sub load{
    my ($self,$fn)=@_;
    my $data = LoadFile($fn);

    foreach my $item( @{ $data->{elements} }) {
        $self->add_element($item);
    }
    foreach my $item( @{ $data->{constraints} }) {

        if ($item->{params}->{compvalue}){
           my $tmp=$item->{params}->{compvalue};
           $item->{params}->{comp}=$self->get_value($tmp); 
        }
        $self->add_constraint($item);
    }
}

sub add_element{
  my( $self, $params ) = @_;
  my $class='';
  my $options='';
  if (!$params->{name}){
    $params->{name}='html'.$self->{count};
    $self->{count}++;
  }
  $params->{request}=$self->{request};

  my $name= $params->{name};
  my $class_name = "HTML::TurboForm::Element::" . $params->{ type };
  $class_name->require() or die "Class '" . $class_name . "' does not exist: $@";  
  my $new_len =  push(@ { $self->{element} }, $class_name->new($params));

  if ($params->{type} eq 'Submit') {
    if ( exists $self->{request}->{$name } ){
      $self->{submitted}=1 ;
      $self->{submit_value} = $name;
    }
  }
  $self->{element_index}->{$name}->{index}=$new_len-1;
  $self->{element_index}->{$name}->{frozen}=0;  
  $self->{element_index}->{$name}->{error_message}='';  
}

sub render{
  my ($self)=@_;

  my $result='<form method=post>';
  foreach my $item(@{$self->{element}}) {
    my $name = $item->name;
    $result .= $item->render($self->{element_index}->{$name});
  }
  return $result.'</form>';
}

sub submitted{ 
  my ($self) = @_;
  my $result='';
  my $set=0;
  if ($self->{submit_value} ne '') { 
    $result=$self->{submit_value}; 
    foreach my $item(@{$self->{constraints}}) {
      my $name=$item->{name};
      if ($item->check() == 0){
        $self->{element_index}->{$name}->{error_message}= $item->message();
        $set=1;
      }       
    }
    $result='' if ($set==1);
  }
  return $result;
}

sub add_options{
  my ($self,$name,$options)=@_;
  $self->{element}[$self->{element_index}->{$name}->{index}]->add_options($options);
}

sub freeze{
  my ($self, $name)=@_;
  $self->{element_index}->{$name}->{frozen}=1;
}

sub freeze_all{
  my ($self)=@_;
  my $k;
  my $v;
  
  foreach $k(keys %{ $self->{element_index} } ){    
    $self->{element_index}->{$k}->{frozen}=1;
  } 
}

sub unfreeze{
  my ($self, $name)=@_;
  $self->{element_index}->{$name}->{frozen}=0;
}

sub get_value{
  my ($self, $name)=@_;
  my $result='';
  $result=$self->{element}[$self->{element_index}->{$name}->{index}]->get_value();
  return $result;
}

sub populate{
  my ($self, $data)=@_;
  my @columns= $data->result_source->columns;
  
  foreach my $item(keys %{$self->{element_index}}) {
    if ( grep { $item eq $_ } @columns ) { 
       if (!$self->{request}->{$item}) { $self->{request}->{$item}=$data->$item;  }
    }
  } 
}

sub map_value{
  my ($self, @columns)=@_;
  my $result;

  foreach my $item(keys %{$self->{element_index}}) {
    if ( grep { $item eq $_ } @columns ) { $result->{$item}=$self->get_value($item); }
  }
 return $result;
}

1;

__END__

=head1 HTML::TurboForm

HTML::TurboForm - fast and compact HTML Form Class

=head1 SYNOPSIS

to start with, two simple examples of how to use turboform. I am still working on both the classes and the docs so please be patient.

=head2 Usage variant 1 : via objects and methods

    my $form= new HTML::TurboForm($c->req->params);
    my $options={}; 
    $options->{ 'label1' }='1';
    $options->{ 'label2' }='2';
    $options->{ 'label3' }='3';
    $form->add_element({ type => 'Html', text =>'<center>'  });
    $form->add_element({ type => 'Text',     name => 'texttest',     label => 'element1' } );
    $form->add_element({ type => 'Text',     name => 'texttest2',     label => 'vergleichselement' } );
    $form->add_element({ type => 'Textarea', name => 'textareatest', label => 'Areahalt:' } );
    $form->add_element({ type => 'Submit',   name => 'freeze',       label => ' ',            value=>'einfrieren' } );
    $form->add_element({ type => 'Submit',   name => 'unfreeze',     label => ' ',            value=>'normal' } );
    $form->add_element({ type => 'Checkbox', name => 'boxtest',      label => 'auswählen',   
                                                                    options => $options, params =>{ 'listmode' } } );
    $form->add_element({ type => 'Html', text =>'<hr>'  });
    $form->add_element({ type => 'Select',   name => 'selecttest',   label => 'selectieren', options => $options } );
    $form->add_element({ type => 'Select',   name => 'selecttest2',  label => 'selectieren', 
                                          options => $options,    attributes => { 'multiple' , 'size'=>'3' } } );
    $form->add_element({ type => 'Text',     name => 'mailtest',    label => 'E-Mail' } );
    $form->add_element({ type => 'Radio',    name => 'tadiotest',    label => 'radioteile', 
                                          options => $options, params =>{ 'listmode', 'norow'} } );
    $form->add_element({ type => 'Date',     name => 'datetest',    label => 'Datum', params=>{ startyear=> '2000' , endyear => '2020' } } );
    $form->add_constraint({ type=> 'Equation', name=> 'texttest', text=> 'kein Vergleich', 
                                            params=>{ operator => 'eq', comp=>$form->get_value('texttest2') } });
    $form->add_constraint({ type=> 'Required', name=> 'boxtest', text=> 'du musst schon was auswählen' });
    $form->add_constraint({ type=> 'Date',     name=> 'datetest', text=> 'das ist doch kein datum' });
    $form->add_constraint({ type=> 'Email',    name=> 'mailtest', text=> 'ungültige Mailadresse' });
    $form->add_element({ type => 'Html', text =>'</center>'  });
    $form->freeze_all() if ($form->submitted() eq 'freeze');
    $c->stash->{form} = $form->render();
    $c->stash->{template}='formtest/formtest.tt';
    if ($form->submitted() eq 'freeze') {
       my @cols= ('txt1','date','txt2','checkboxtest');
       my $data=$form->map_value(@cols); 
    }

=head2 Usage Variant 2 : via yml file:

 my $form= new HTML::TurboForm($c->req->params);
 $form->load('test.yml');
 my $text=$form->render();

 if ($form->submitted eq 'freeze') {}

 Sample yml-file:

---
languages:
  - de
elements:
  - type: Html
    text: <center>

  - type: Text
    name: messageausyml
    label: ausyml

  - type: Text
    name: txt1
    label: sampleinput

  - type: Text
    name: txt2
    label: whatever to compare

  - type: Checkbox
    label: chooser
    name: checkboxtest
    options:  
        label1: 1
        label2: 2

  - type: Html
    text: <div class="form_row"><hr></div>

  - type: Radio
    label: radiochooser
    options:
        radio1: 1
        radio2: 2

  - type: Submit
    name: freeze
    value: einfrieren

  - type: Submit
    name: defreeze
    value: normal

  - type: Date
    label: Datum
    name: date
    params:
      startyear: 2000
      endyear: 2010

  - type: Html
    text: </center>

constraints:

  - type: Required
    name: messageausyml
    text: <font size=2><b>mandatory field</b></font>

  - type: Date
    name: date
    text: <font size=2><b>must be a correct date</b></font>

  - type: Equation
    name: txt1
    text: <font size=2><b>must be higher</b></font>
    params:
      operator: <   
      compvalue: txt2  


=head1 DESCRIPTION

HTML::TurboForm was designed as a small, fast and compact Form Class to use with catalyst in order to easily create any needed Form. 
I know there a quite a lot of classes out there which do the same but i wasn't quite content with what i found. 
They were either too slow or complicated or both. 

=head1 METHODS

=head2 new

Arguments: $request

Creates new Form Object, needs Request Arguments to fill out Form Elements. To do so it's very important that the form elements
have the same names as the request parameters.

=head2 add_constraint

Arguments: $params

Adds a new Contraint to the Form. Constraints can be date, required or any other constraint class object.
Only if they successfully match the given constraint rule the form will return valid.

=head2 load

Arguments: $fn

Loads a form from a given YML File.

=head2 add_element

Arguments: $params

Will add a new Form Element, for example a new text element or select box or whatever.

=head2 render

Arguments: none

Renders the form. Will retrun the HTML Code for the form including error messages.

=head2 submitted

Arguments: none

Will be true if the form is correctly filled out by user, otherwise it returns false and shows the corresponding error message(s).

=head2 add_options

Arguments: $name, $option

Adds option to HTML elements that needs them, for example select boxes.

=head2 freeze

Arguments: $name

Will disable the HTML Element identified by name for viewing purposes only.

=head2 freeze_all

Arguments: none

Freezes the whole form.

=head2 unfreeze

Arguments: $name

Unfreezes certain Element.

=head2 get_value

Arguments: $name

Returns Value of Eelement by name

=head2 populate

Arguments: $data

fills form with values form hash.

=head2 map_value

Arguments: @columns

Expects an array with column names. This method is used to map the request and form elements to the columns of a database table.

=head1 AUTHOR

Thorsten Domsch, camelcase@gmx.de

=head1 LICENSE 
 
This library is free software, you can redistribute it and/or modify it under 
the same terms as Perl itself. 

=cut


