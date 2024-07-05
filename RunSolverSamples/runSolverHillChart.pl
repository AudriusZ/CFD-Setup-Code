#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path);
use File::Spec;
use FindBin;
use lib "$FindBin::Bin";

# Add the current directory to @INC
use lib '.';

# Use the modules
use GenerateCCLforSolver;
use GenerateCCLforDomainStd;

my $partitions = 12;
my $convergence_target = 5e-5;
my $max_iter = 2;
my $results_folder = 'Results';

# Create instances of the necessary classes
my $generator_solve = GenerateCCLforSolver->new();
my $domain_r_s_ccl = GenerateCCLforDomainStd->new(domains => ['R', 'S']);

# Generate the CCL files to be used by solver
my $convergence_target_ccl = $generator_solve->set_convergence_target($convergence_target);
my $max_iter_ccl = $generator_solve->set_max_iterations($max_iter);
my $expressions_ccl = $generator_solve->add_expressions();
my $default_monitors_ccl = $generator_solve->add_default_monitors();
my $TurbulenceSST_CC_CCL = $domain_r_s_ccl->set_turbulence_SST_CC();
my $n_rpm_ccl = $generator_solve->set_expression_value('n', 60, 'rev/min');
# my $initial_conditions_ccl = $generator_solve->initial_conditions();

# Get list of .def files in Def folder
my @def_files = glob("Def/*.def");

# Print all .def files found
print "Found .def files:\n";
foreach my $def_file (@def_files) {
    print "$def_file\n";
}

# Check if Results folder exists, if not, create it
unless (-d $results_folder) {
    make_path($results_folder) or die "Failed to create path: $results_folder";
}

# Define the array of n_rpm values
my @n_rpm = (113.5, 56.75, 170.25);


# Run simulation for each .def file
foreach my $def_file (@def_files) {
    # Loop through the n_rpm values
    foreach my $n_value (@n_rpm) {
        # Generate the CCL file with the current n value        
        my $n_rpm_ccl = $generator_solve->set_expression_value('n', $n_value, 'rev/min');

        my $defname = basename($def_file, ".def");
        my $basename = $defname . "_n_" . $n_value;

        print "Running $basename\n";
        my $command = "cfx5solve.exe"
                    . " -double -par-local -part $partitions"
                    . " -def $def_file"
                    . " -ccl $TurbulenceSST_CC_CCL"
                    . " -ccl $n_rpm_ccl"
                    . " -ccl $max_iter_ccl"
                    . " -ccl $convergence_target_ccl"
                    . " -cont-from-file Def/MOGU_1.65_angle_0_001.res"
                    . " -name Results/$basename";

        system($command);
        unlink $n_rpm_ccl if -e $n_rpm_ccl;
    }
}

# Optionally clean up the generated CCL files
unlink $convergence_target_ccl if -e $convergence_target_ccl;
unlink $max_iter_ccl if -e $max_iter_ccl;
unlink $expressions_ccl if -e $expressions_ccl;
unlink $default_monitors_ccl if -e $default_monitors_ccl;
unlink $n_rpm_ccl if -e $n_rpm_ccl;
unlink $TurbulenceSST_CC_CCL if -e $TurbulenceSST_CC_CCL;
# unlink $initial_conditions_ccl if -e $initial_conditions_ccl;

print "Simulation run completed.\n";
