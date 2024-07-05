#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";
use GenerateCCLforDomainStd;


# Create an object with the domain names
my $domain_r_s_ccl = GenerateCCLforDomainStd->new(domains => ['R', 'S']);

# Generate the CCL file
my $filename = $domain_r_s_ccl->set_turbulence_SST_CC();

print "CCL file generated: $filename\n";


# Create an object with the domain names
my $domain_default_ccl = GenerateCCLforDomainStd->new(domains => ['Default Domain']);

# Generate the CCL file
my $filename = $domain_default_ccl->set_turbulence_SST_CC();

print "CCL file generated: $filename\n";
    