use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path);
use File::Spec;

# Add the current directory to @INC
use lib '.';

# Use the modules
use GenerateCCL1DomainStd;
use GenerateCCLforSolver;


my $partitions = 4;
my $convergence_target = 1e-4;
my $max_iter = 5;
my $inlet_velocity = 8.8; #m/s

my $results_folder = 'Results';


# Create an instance of GenerateCCL1DomainStd
my $generator = GenerateCCL1DomainStd->new();
my $generator_solve = GenerateCCLforSolver->new();

# Generate the CCL file with the desired convergence target value
my $convergence_target_ccl = $generator_solve->set_convergence_target($convergence_target);

# Generate the CCL file with the desired convergence target value
my $max_iter_ccl = $generator_solve->set_max_iterations($max_iter);

# Generate the initial conditions CCL file
my $initial_conditions_ccl = $generator->initial_conditions();

# Generate the expressions CCL file
my $expressions_ccl = $generator->add_expressions();

# Generate the default monitors CCL file
my $default_monitors_ccl = $generator->add_default_monitors();

# Set a specific expression value
my $vel_expression_value_ccl = $generator->set_expression_value('velocityIn', $inlet_velocity, 'm/s');



# Get list of .def files in Lib folder
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

# Run simulation for each .def file
foreach my $def_file (@def_files) {
    my $basename = basename($def_file, ".def");

    print "Running $basename\n";
    my $command = "cfx5solve.exe"
                . " -double -par-local -part $partitions"
                . " -def $def_file"
                . " -ccl $expressions_ccl" 
                . " -ccl $vel_expression_value_ccl"
                . " -ccl $default_monitors_ccl"
                . " -ccl $initial_conditions_ccl"
                . " -ccl $max_iter_ccl"
                . " -ccl $convergence_target_ccl"
                . " -cont-from-file Def/v3_001.res"
                . " -name Results/$basename";

    system($command);
}


# Optionally clean up the generated CCL files
unlink $convergence_target_ccl;
unlink $initial_conditions_ccl;
unlink $max_iter_ccl;
unlink $expressions_ccl;
unlink $default_monitors_ccl;
#unlink $vel_expression_value_ccl;
