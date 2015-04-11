#!/usr/bin/perl
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

use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use Amortization;
use Table;

# Boolean.
use constant FALSE  => 0;
use constant TRUE   => 1;
# Labels.
use constant  PERIOD    => 'period';
use constant  PAYMENT   => 'payment';
use constant  PRINCIPAL => 'principal';
use constant  INTEREST  => 'interest';
use constant  BALANCE   => 'balance';
use constant  DATE      => 'date';
# Best to use even number.
use constant  HEADER_SPACING   => 4;
use constant  DATE_SPACING     => 8;

###############
# SUBROUTINES #
###############

##-
# Display help usage.
# @param  scalar  Filename of this script.
##-
sub usage($) {
    my $basename = basename $_[0];
    print "Usage: $basename [OPTIONS] --principal <principal amount>\n"; 
    print "                             --interest <interest rate>\n";
    print "                             --periods <number of payment periods>\n";
    print "Description: Calculate and display amortization payments and schedules.\n";
    print "OPTIONS:\n";
    print "    --extraat <period=amount>\n";
    print "        Extra principal payment amount at a specific period.\n";
    print "        Can specify more than once.";
    print "    --extraevery <period=amount>\n";
    print "        Extra principal payment amount every recurring annual period.\n";
    print "    --month <month index>\n";
    print "        Specify the starting month for payment.\n";
    print "        Use number index to represent the month, eg- 1 is January.\n";
    print "        Must use with --startyear option.\n";
    print "    --year <year>\n";
    print "        Specify the starting year for payment.\n";
    print "        Must use with --startmonth option.\n";
    print "    --help\n";
    print "        Show help information.\n";
}

##-
# Convert percent string to float.
# @param  scalar  Percent string or float
# @return  scalar  Float representation
##-
sub percent_to_float($) {
    my $rate = shift;
    
    if ($rate =~ /^([\d*][\.*][\d*])%$/) {
        $rate = int $rate;
        $rate = $rate / 100;
    }
    
    return sprintf("%0.5f", $rate);
}

##-
# Convert float to percentage string.
# @param  scalar  Percent string or float
# @return  scalar  Percentage string
##-
sub float_to_percent($) {
    my $rate = shift;
    
    if ($rate =~ /^([\d*][\.*][\d*])%$/) {
        return $rate;
    }
    $rate = $rate * 100;
    
    return sprintf("%0.3f", $rate)."%";
}

##-
# Month and year date of the payment period.
# @param  scalar  Payment period
# @param  scalar  Month index
# @param  scalar  Year
# @return  array  Month and year date of this payment period
##-
sub get_date_from($$$) {
    my $period  = shift;
    my $month   = shift;
    my $year    = shift;
    
    my $y = $year + int(($period + $month -1) / 12);
    my $m = (($period + $month) % 12);
    $m = 12 if $m == 0;
    
    return ($m, $y);
}

##-
# Convert month index to its name.
# @param  scalar  Month index
# @return  scalar  Name of the month
##-
sub to_month_str($) {
   my $month = shift;
   
   if ($month == 1) {
       return "Jan";
   } elsif ($month == 2) {
       return "Feb";
   }  elsif ($month == 3) {
       return "Mar";
   }  elsif ($month == 4) {
       return "Apr";
   }  elsif ($month == 5) {
       return "May";
   }  elsif ($month == 6) {
       return "Jun";
   }  elsif ($month == 7) {
       return "Jul";
   }  elsif ($month == 8) {
       return "Aug";
   }  elsif ($month == 9) {
       return "Sep";
   }  elsif ($month == 10) {
       return "Oct";
   }  elsif ($month == 11) {
       return "Nov";
   }  elsif ($month == 12) {
       return "Dec";
   } else {
       return;
   }
}

##-
# Determine if both month and year are non-zero.
# @param  scalar  Starting month index
# @param  scalar  Starting year
# @return  boolean  True if both month and year are non-zero | false
##-
sub have_start_date($$) {
    my $month = shift;
    my $year  = shift;
    
    return ($month != 0 && $year != 0) ? TRUE : FALSE;
}

##-
# Validate starting month and year values.
# @param  scalar  Starting month index
# @param  scalar  Starting year
# @return  boolean  True if starting month and year are valid | false
##-
sub validate_start_date($$) {
    my $month = shift;
    my $year  = shift;
    
    # True if both month and year equal 0 
    # or both month and year not equal to 0
    return FALSE if $month > 12 || $month < 0;
    return FALSE if $month != 0 && $year == 0;
    return FALSE if $month == 0 && $year != 0;
    return TRUE;
}

########
# MAIN #
########

my $principal        = 0;
my $interest_rate    = 0;
my $periods          = 0;
my $month            = 0;
my $year             = 0;
my %extra_at         = ();
my %extra_every      = ();
my $help             = 0;

GetOptions ("principal=i"  => \$principal,
            "interest=s"   => \$interest_rate,
            "periods=i"    => \$periods,
            "month=i"      => \$month,
            "year=i"       => \$year,
            "extraat=s"    => \%extra_at,
            "extraevery=s" => \%extra_every,
            "help"         => \$help)
or die("Error in command line arguments\n");

# Validate script arguments.
if ($principal == 0 || $interest_rate == 0 || $periods == 0) {
    usage($0);
    exit(0);
}
if ($help == 1) {
    usage($0);
    exit(0);
}
if (! validate_start_date($month, $year)) {
    usage($0);
    exit(0);
}

my $amort = new Amortization;
$amort->principal($principal);
$amort->rate(percent_to_float($interest_rate));
$amort->periods($periods);
if (%extra_every) {
    $amort->extra_every(\%extra_every);
}
if (%extra_at) {
    $amort->extra_at(\%extra_at);
}

my $table = new Table;
$table->register(PERIOD, HEADER_SPACING);
if (have_start_date($month, $year)) {
    $table->register(DATE, DATE_SPACING);
}
$table->register(PAYMENT, HEADER_SPACING);
$table->register(PRINCIPAL, HEADER_SPACING);
$table->register(INTEREST, HEADER_SPACING);
$table->register(BALANCE, HEADER_SPACING);

# Display the calculation parameters.
print "Principal                 : \$".sprintf("%0.2f", $principal)."\n";
print "Interest rate             : ".float_to_percent($interest_rate)." (or ".percent_to_float($interest_rate).")\n";
print "Number of payment periods : ".$periods."\n";
if (have_start_date($month, $year)) {
    print "Start date                : ".to_month_str($month)." $year\n";
}
if (scalar %extra_every) {
    print "Extra payment             : \n";
    foreach my $every (keys %extra_every) {
        # The extra month corresponds to the period index,
        # not month index for purposes of display.
        my $m = ($every + $month - 1) % 12;
        my $every_str = (have_start_date($month, $year)) 
                        ?   to_month_str($m)
                        :   'annual period on ' . $every;
        print '         $'.sprintf("%0.2f",$extra_every{$every})." every ".$every_str."\n";
    }
}
if (scalar %extra_at) {
    print "Extra payment             : \n";
    foreach my $at (keys %extra_at) {
        # The extra month corresponds to the period index,
        # not month index for purposes of display.
        my $m = ($at + $month - 1) % 12;
        my $at_str = (have_start_date($month, $year)) 
                     ?   to_month_str($m)
                     :   $at;
        print '         $'.sprintf("%0.2f",$extra_at{$at})." at period $at_str\n";
    }
}

print $table->get_draw_header();
my $per = 1;
my $iter = $amort->next();
while ($iter->()) {
    # We count the first period as index zero for display purposes.
    my ($m, $y) = get_date_from($per - 1, $month, $year);
    my $row = { PERIOD     => $per,
                DATE       => to_month_str($m)." $y",
                INTEREST   => $amort->interest_amount(),
                PAYMENT    => $amort->payment_amount(),
                PRINCIPAL  => $amort->principal_amount(),
                BALANCE    => $amort->remaining_amount() };
    $per++;
    print $table->get_draw_data_row($row);
}
print $table->get_draw_border();

# Display the totals.
my $totals = { PERIOD    => '--',
               DATE      => '--',
               INTEREST  => sprintf("%0.2f", $amort->total_interest_amount()),
               PAYMENT   => sprintf("%0.2f", $amort->total_payment_amount()),
               PRINCIPAL => sprintf("%0.2f", $amort->total_principal_amount()),
               BALANCE   => '--' };
print $table->get_draw_data_row($totals);
print $table->get_draw_border();


=head1 NAME

amortize.pl - Displays amortization schedule table

=head1 SYNOPSIS

    amortize.pl [OPTIONS]  --principal <principal amount> 
                           --interest <interest rate> 
                           --periods <number of payment periods>
    OPTIONS:
        --extraat <period=amount>
            Extra principal payment amount at a specific period.
            Can specify more than once.
        --extraevery <period=amount>
            Extra principal payment amount every recurring annual period.
            Can specify more than once.
        --month <month index>
            Specify the starting month for payment.
            Use number index to represent the month, eg- 1 is January.
            Must use with --year option.
        --year <year>
            Specify the starting year for payment.
            Must use with --month option.
        --help
            Show help information.
            
=head1 SAMPLE

Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years.
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360

Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years starting on June 2015.
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360
                   --month 6 --year 2015
                   
Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years with extra $500 payments every March and September.
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360
                   --extraevery 3=500 --extraevery 9=500
                   
Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years with extra $500 payments only at periods 5 and 8.
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360
                   --extraat 5=500 --extraat 8=500
                   
Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years starting on June 2015 with extra $500 payments
every February and August. 
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360 
                   --extraevery 3=500 --extraevery 9=500 
                   --month 6 --year 2015
(NOTE: Extra every "3" and "9" here means every 3rd and 9th period annually 
which does not necessarily mean every March and September annually if your
starting month is June. It is offset by when your starting month is.)

=head1 DESCRIPTION

This script calculates and displays an amortization schedule, 
such as, mortgage payments.

It breaks down monthly payment amount, what portion of that
payment is allocated to interest and principal, and total
amount of payment made at the end. All of these are 
displayed in an easy-to-view table. 

Features include:
  * Extra principal payments at a specific payment period.
  * Extra principal payments at recurring annual 
    payment period.
  * Running total of payments, principal, and interest paid.

=head1 LICENSE

This is released under the Apache 
License 2.0. See L<LICENSE>.

=head1 AUTHOR

Joe Mong - L<http://github.com/jmong/>

=head1 SEE ALSO

L<perlpod>, L<perlpodspec>

=cut

