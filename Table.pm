##--
# Copyright 2015 Joe Mong
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##--
package Table;

use strict;
use warnings;
use Exporter;

our @ISA     = qw(Exporter);

use constant DEFAULT_SPACING  => 2;

##-
# Constructor.
# @param  scalar  Class name.
##-
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;
    
    my %defaults = (
            'labels'       => {},  # list of map of label names
                                   # to their container.
            'label_order'  => [],  # list of label names in order
    );
    my %private = ();
    
    my $self = { %defaults, %args, %private };
    
    return bless $self, $class;
}

##-
# Register label name for column.
# @param  scalar  A label for the name of the column.
# @param[optional]  scalar  Extra side buffer space (default = 2). 
##-
sub register($$;$) {
    my $self = shift;
    my $label = shift;
    my $spacing = (@_) ? shift : DEFAULT_SPACING;
    
    $self->{'labels'}->{uc $label} = {'spacing' => $spacing};
    push( @{$self->{'label_order'}}, uc $label);
}

##-
# String render of a table border.
# @return  scalar  Table border string
##-
sub get_draw_border($) {
    my $self = shift;
    
    my $draw = '';
    foreach my $label (@{$self->{'label_order'}}) {
        my $label_len = length $label;
        $draw .= '+';
        $draw .= '-' x ($label_len + $self->{'labels'}->{uc $label}->{'spacing'});
    }
    $draw .= "+\n";
    
    return $draw;
}

##-
# String render of the table header with label names.
# @return  scalar  Table header string
##-
sub get_draw_header($) {
    my $self = shift;
    my $draw = '';
    
    $draw .= $self->get_draw_border();
    foreach my $label (@{$self->{'label_order'}}) {
        my $half_spacing = $self->{'labels'}->{uc $label}->{'spacing'} / 2;
        $draw .= '|' . ' ' x $half_spacing;
        $draw .= $label . ' ' x $half_spacing;
    }
    $draw .= "|\n";
    $draw .= $self->get_draw_border();
    
    return $draw;
}

##-
# String render for each table row.
# @param  hash_ref  Map of label names and the value to render
# @return  scalar  Table row string
##-
sub get_draw_data_row($$) {
    my $self       = shift;
    my $label_hash = shift;  # key is label name, value is the text to display.
    
    my $draw = '';
    my @label_hash_keys = map { uc } keys %{$label_hash};
    return if ! scalar @label_hash_keys;
    
    foreach my $label (@{$self->{'label_order'}}) {
        if (grep /^$label$/i, @label_hash_keys) {
            my $value = $label_hash->{$label};
            my $value_len = length $value;
            my $label_len = length $label;
            my $spacing = $label_len + $self->{'labels'}->{uc $label}->{'spacing'} - $value_len;
            
            my $equal_space = int( $spacing / 2 );
            my $leftover_space = $spacing % 2;
            
            $draw .= '|';
            if ($leftover_space == 0) {
                $draw .= ' ' x $equal_space;
                $draw .= $value;
                $draw .= ' ' x $equal_space;
            } else {
                $draw .= ' ' x ($equal_space + $leftover_space);
                $draw .= $value;
                $draw .= ' ' x $equal_space;
            }
        }
    }
    $draw .= "|\n"; 
    
    return $draw;
}

1;

=head1 NAME

Table.pm - Renders a spreadsheet-like table showing per-period payment

=head1 SYNOPSIS

    my $table = new Table;
    $table->register("payment", 4);
    print $table->get_draw_header();
    
    my $row = { 'payment' => 1000.00 };
    print $table->get_draw_data_row($row);
    
    print $table->get_draw_border();

=head1 DESCRIPTION

This module helps render a spreadsheet-like table for displaying
payment schedules.

You register() label names for the value that you will display.
For example, you can have label named "principal" for displaying
payment amount towards principal. The label names are also used
to display the column headers. 

=head1 LICENSE

This is released under the Apache 
License 2.0. See L<LICENSE>.

=head1 AUTHOR

Joe Mong - L<http://github.com/jmong/>

=head1 SEE ALSO

L<perlpod>, L<perlpodspec>

=cut
