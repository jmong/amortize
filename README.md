amortize
========

Calculates and displays amortization payment schedule.

## Description

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

## Synopsis

```
    perl amortize.pl [OPTIONS]  --principal <principal amount> 
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
```

## Examples

Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years.
```
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360
```

Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years starting on June 2015.
```
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360
                   --month 6 --year 2015
```
                   
Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years with extra $500 payments every March and September.
```
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360
                   --extraevery 3=500 --extraevery 9=500
```
                   
Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years with extra $500 payments only at periods 5 and 8.
```
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360
                   --extraat 5=500 --extraat 8=500
```
                   
Amortization payment schedule for a $100,000 loan at annual interest rate
of 5.0% for 30 years starting on June 2015 with extra $500 payments
every February and August. 
```
$ perl amortize.pl --principal 100000 --interest 0.05 --periods 360 
                   --extraevery 3=500 --extraevery 9=500 
                   --month 6 --year 2015
```
(NOTE: Extra every "3" and "9" here means every 3rd and 9th period annually 
which does not necessarily mean every March and September annually if your
starting month is June. It is offset by when your starting month is.)

## Copyright

Copyright 2015 Joe Mong. Licensed under the Apache License 2.0
