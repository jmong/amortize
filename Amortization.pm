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
package Amortization;

use strict;
use warnings;
use Exporter;

our @ISA     = qw(Exporter);

use constant FALSE  => 0;
use constant TRUE   => 1;

##-
# Constructor.
# @param  scalar  Class name.
##-
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;
    
    my %defaults = (
            'principal'       => 0.0,  # principal amount
            'rate'            => 0.0,  # annual interest rate
            'periods'         => 0,    # number of payment periods
            'period_amount'   => 0.0,  # total payment per period
            'period_rate'     => 0.0,  # periodic interest rate
            'total_payment'   => 0.0,  # total payment over life of terms
            'total_principal' => 0.0,  # total principal over life of terms
            'total_interest'  => 0.0,  # total interest over life of terms
            'extra_every'     => {},   # optional extra payment towards
                                       # principal reduction every 
                                       # recurring period
            'extra_at'        => {},   # optional extra payment towards
                                       # principal reduction at this
                                       # period
    );
    my %private = (
            'cache'                => {},    # cache of the payment
                                             # structure for each period
            'cur_iter_period_idx'  => 0,     # internal counter of 
                                             # current index when
                                             # using iterator
            'current'              => undef, # current cache
                                             # payment structure
    );
    
    my $self = { %defaults, %args, %private };
    
    return bless $self, $class;
}

##--
# Setter/getter principal amount.
# @param  scalar  Principal amount
# @return  scalar  Principal amount
##--
sub principal($;$) {
    my $self = shift;
    my $principal = shift;
    
    if (defined $principal) {
        $self->{'principal'} = $principal;
    }
    
    return $self->{'principal'};
}

##--
# Setter/getter annual interest rate.
# @param  scalar  Annual interest rate
# @return  scalar  Annual interest rate
##--
sub rate($;$) {
    my $self = shift;
    my $rate = shift;
    
    if (defined $rate) {
        $self->{'rate'} = $rate;
        $self->{'period_rate'} = $rate / 12;
    }
    
    return $self->{'rate'};
}

##-
# Make extra payment towards principal every annual period.
# @param  hash  The extra payment per every annual period
##-
sub extra_every($$) {
    my $self = shift;
    my $extra = shift;
    $self->{'extra_every'} = $extra;
}

##-
# Make extra payment towards principal at only this period.
# @param  hash  The extra payment at this period
##-
sub extra_at($$) {
    my $self = shift;
    my $extra = shift;
    $self->{'extra_at'} = $extra;
}

##-
# Setter/getter number of payment periods.
# @param  scalar  Number of payment periods
# @return  scalar  Number of payment perids
##-
sub periods($;$) {
    my $self = shift;
    my $periods = shift;
    
    if (defined $periods) {
        $self->{'periods'} = $periods;
    }
    
    return $self->{'periods'};
}

##-
# @todo
# Validate all required information is set.
# @return  bool  True if all required information is set | false
##-
#sub is_valid_terms($) {
#    return TRUE;
#}

##-
# @TODO
##-
#sub payment_at($$) {
#    my ($self, $period_idx) = @_;
#    
#    return if ($period_idx == 0 || $period_idx > $self->{'periods'});
#    
#    if (exists $self->{'cache'}->{$period_idx}) {
#        $self->{'current'} = $self->{'cache'}->{$period_idx};
#    } else {
#        my $cur_balance = $self->{'principal'} * $period_idx;
#        
#        my $to_interest = sprintf("%0.2f", $cur_balance * $self->{'period_rate'});
#        my $to_principal = sprintf("%0.2f", $self->{'period_amount'} - $to_interest);
#        my $remaining_balance = $cur_balance - $to_principal;
#        
#        $self->{'cache'} = { $period_idx => {'remaining_balance' => $remaining_balance,
#                                           'interest'          => $to_interest,
#                                           'principal'         => $to_principal} };
#        $self->{'current'} = $self->{'cache'}->{$period_idx};
#    }
#}

##-
# Portion of the period payment for principal.
# @return  scalar  Principal amount
##-
sub principal_amount($) {
    my $self = shift;
    if (defined $self->{'current'}) {
        return $self->{'current'}->{'principal'};
    }
}

##-
# Portion of the period payment for interest.
# @return  scalar  Interest amount
##-
sub interest_amount($) {
    my $self = shift;
    if (defined $self->{'current'}) {
        return $self->{'current'}->{'interest'};
    }
}

##-
# Remaining principal balance at this period.
# @return  scalar  Remaining principal amount
##-
sub remaining_amount($) {
    my $self = shift;
    if (defined $self->{'current'}) {
        return $self->{'current'}->{'remaining_balance'};
    }    
}

##-
# Total payment amount at this period.
# @return  scalar  Total payment amount
##-
sub payment_amount($) {
    my $self = shift;
    if (defined $self->{'current'}) {
        return $self->{'current'}->{'payment'};
    }
}

##-
# Total payment amount.
# @return  scalar  Total payment amount
##-
sub total_payment_amount() {
    my $self = shift;
    return $self->{'total_payment'};
}

##-
# Total principal amount.
# @return  scalar  Total principal amount
##-
sub total_principal_amount() {
    my $self = shift;
    return $self->{'total_principal'};
}

##-
# Total interest amount.
# @return  scalar  Total interest amount
##-
sub total_interest_amount() {
    my $self = shift;
    return $self->{'total_interest'};
}

##-
# Is it at the recurring annual period?
# @param  scalar  This period
# @param  scalar  The recurring annual period
# @return  bool  True if this period is at the recurring annual period | false
##-
sub is_extra_every($$) {
    my $this_period = shift;
    my $every_period = shift;
    
    my $is = ($this_period - $every_period) / 12;
    
    return ($is =~ /^\d+$/) ? TRUE : FALSE;
    
}

##-
# Is it at the specified extra payment period?
# @param  scalar  This period
# @return  bool  True if this period is at the specific period | false
##-
sub is_extra_at($$) {
    my $self        = shift;
    my $this_period = shift;
    
    return (grep {/^$this_period$/} keys %{$self->{'extra_at'}}) ? TRUE : FALSE;
}

##-
# The total amount payment for each period.
# @return  scalar  Total amount payment
##-
sub _get_period_amount($) {
    my $self = shift;
    #if (! $self->is_valid_terms()) {
    #    return 0.0;
    #}
    
    my $dividend = ((1 + $self->{'period_rate'})**$self->{'periods'}) * $self->{'period_rate'} * $self->{'principal'};
    my $divisor = ((1 + $self->{'period_rate'})**$self->{'periods'}) - 1;
    my $payment = $dividend / $divisor;
    $self->{'period_amount'} = sprintf("%0.2f", $payment);
    
    return $self->{'period_amount'};
}

##-
# Iterate through each payment period.
# @return  subroutine_ref  The iterator going through each period
##-
sub next($) {
    my $self = shift;
    
    # Keep track of remaining balance through each period.
    my $cur_remaining = $self->{'principal'};
    my $cur_period = 0;
    $self->{'period_amount'} = $self->_get_period_amount();
    
    return sub {
        # Stop when we come to the end of the payment periods.
        return undef if ++$cur_period > $self->{'periods'};
        
        my $payment = $self->{'period_amount'};
        my $interest = sprintf("%0.2f", $cur_remaining * $self->{'period_rate'});
        my $principal = $self->{'period_amount'} - $interest;
        # Apply extra principal payment.
        foreach my $per (keys $self->{'extra_every'}) {
            if (is_extra_every($cur_period,$per) == TRUE) {
                $principal += $self->{'extra_every'}->{$per};
                $payment += $self->{'extra_every'}->{$per};
            } elsif ($self->is_extra_at($cur_period,$per) == TRUE) {
                $principal += $self->{'extra_at'}->{$per};
                $payment += $self->{'extra_at'}->{$per};
            }
        }
        $principal = sprintf("%0.2f", $principal);        
        
        # Stop when there are no more remaining balance.
        return undef if $cur_remaining <= 0;
        
        # For the last payment, the period payment amount
        # is the total of the remaining balance.
        if ($cur_period == $self->{'periods'}) {
            $payment = $cur_remaining;
            $principal = $payment - $interest;
            $cur_remaining = sprintf("%0.2f", 0);
        } else {
            $cur_remaining = sprintf("%0.2f", $cur_remaining - $principal);
        }
        
        # Total amounts.
        $self->{'total_payment'}   += $payment;
        $self->{'total_principal'} += $principal;
        $self->{'total_interest'}  += $interest;
        
        # Save each period payment information in cache.
        $self->{'cache'} = { $cur_period => {'remaining_balance' => $cur_remaining,
                                             'interest'          => $interest,
                                             'principal'         => $principal,
                                             'payment'           => $payment} };
        $self->{'current'} = $self->{'cache'}->{$cur_period};
    }
}

1;

=head1 NAME

Amortization.pm - Calculates amortization payment

=head1 SYNOPSIS

    use Amortization;
    my $amort = new Amortization;
    $amort->principal(100000);
    $amort->rate(0.05);  # 5.0%
    $amort->periods(360);
    $amort->extra_every({6 => 1000});  # every 6 months, pay extra $1000
    
    my $iter = $amort->next();
    while ($iter->()) {
        print "Monthly total payment: " . $amort->payment_amount() . "\n";
        print "Monthly payment toward interest: " . $amort->interest_amount() . "\n";
        print "Monthly payment toward principal: " . $amort->principal_amount() . "\n";
    }

=head1 DESCRIPTION

This module calculates an amortization payment schedule,
including periodic (eg- monthly) payment, what portion
of that payment is allocated for interest and principal
reduction, and remaining principal balance during each
period.

In addition, it can also calculate the payment schedule
if there are extra payments applied.

An amortization object requires 3 pieces of information 
in order to calculate a schedule:
  * principal amount
  * annual interest rate
  * number of payment periods.
  
Calling the next() method returns an iterator. Each iteration
calculates one period which you can extract information from.
For example, calling interest_amount() returns the amount
you are paying towards interest for this period.

next() returns undef at the end of the payment period or
when there are no more remaining principal balance.

=head1 LICENSE

This is released under the Apache 
License 2.0. See L<LICENSE>.

=head1 AUTHOR

Joe Mong - L<http://github.com/jmong/>

=head1 SEE ALSO

L<perlpod>, L<perlpodspec>

=cut
