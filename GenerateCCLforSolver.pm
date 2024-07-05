package GenerateCCLforSolver;

use strict;
use warnings;
use File::Temp qw(tempfile);
use File::Basename;
use Cwd 'abs_path';

# Constructor
sub new {
    my ($class, %args) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

# Method to set convergence target and create the CCL file
sub set_convergence_target {
    my ($self, $target) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'set_convergence_target';

    # Template text
    my $template_text = <<'END_TEMPLATE';
FLOW: Flow Analysis 1
  SOLVER CONTROL:     
    &replace CONVERGENCE CRITERIA: 
      Residual Target = [% target %]
      Residual Type = RMS
    END    
  END
END
END_TEMPLATE

    # Replace the placeholder with the actual target value
    $template_text =~ s/\[% target %\]/$target/;

    # Create a temporary file for the CCL output in the same directory as the class file
    my ($fh, $filename) = tempfile("${method_name}_XXXX", SUFFIX => '.ccl', DIR => $class_file_dir);

    # Write the processed template to the temporary file
    print $fh $template_text;
    close $fh;

    return $filename;
}

sub set_max_iterations {
    my ($self, $max_iter) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'set_max_iterations';

    # Template text
    my $template_text = <<'END_TEMPLATE';
FLOW: Flow Analysis 1
  SOLVER CONTROL: 
    CONVERGENCE CONTROL:       
      &replace Maximum Number of Iterations = [% max_iter %]      
    END    
  END
END
END_TEMPLATE

    # Replace the placeholder with the actual max_iter value
    $template_text =~ s/\[% max_iter %\]/$max_iter/;

    # Create a temporary file for the CCL output in the same directory as the class file
    my ($fh, $filename) = tempfile("${method_name}_XXXX", SUFFIX => '.ccl', DIR => $class_file_dir);

    # Write the processed template to the temporary file
    print $fh $template_text;
    close $fh;

    return $filename;
}

# Method to generate the initial conditions CCL file
sub initial_conditions {
    my ($self) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'initial_conditions';

    # Template text for the initial conditions
    my $template_text = <<'END_TEMPLATE';
FLOW: Flow Analysis 1
  &replace INITIALISATION: 
    Option = Automatic
    INITIAL CONDITIONS: 
      Velocity Type = Cartesian
      CARTESIAN VELOCITY COMPONENTS: 
        Option = Automatic with Value
        U = 0 [m s^-1]
        V = 0 [m s^-1]
        W = 0 [m s^-1]
      END
      STATIC PRESSURE: 
        Option = Automatic with Value
        Relative Pressure = 0 [Pa]
      END
      TURBULENCE INITIAL CONDITIONS: 
        Option = Medium Intensity and Eddy Viscosity Ratio
      END
    END
  END
END
END_TEMPLATE

    # Create a temporary file for the CCL output in the same directory as the class file
    my ($fh, $filename) = tempfile("${method_name}_XXXX", SUFFIX => '.ccl', DIR => $class_file_dir);

    # Write the processed template to the temporary file
    print $fh $template_text;
    close $fh;

    return $filename;
}

# Method to generate the expressions CCL file
sub add_expressions {
    my ($self) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'add_expressions';

    # Template text for the expressions
    my $template_text = <<'END_TEMPLATE';
LIBRARY: 
  CEL: 
    &replace EXPRESSIONS: 
      inletVelMonitor = areaAve(Velocity)@inlet
      pressureDropMonitor = areaAve(Pressure)@inlet-areaAve(Pressure)@outlet
      velocityIn = 8.8 [m/s]
      volumeFlowIn = 0.00030 [m^3/s]
      volumeFlowMonitor = area()@inlet*inletVelMonitor
    END
  END
END
END_TEMPLATE

    # Attempt to create a temporary file for the CCL output in the specified directory
    my ($fh, $filename) = File::Temp::tempfile("${method_name}_XXXX", SUFFIX => '.ccl', DIR => $class_file_dir);

    # Check for errors during file creation
    unless ($fh) {
        die "Failed to create temporary file in $class_file_dir: $!";
    }

    # Write the processed template to the temporary file
    print $fh $template_text;
    close $fh;

    return $filename;
}




# Method to set an expression value and create the CCL file
sub set_expression_value {
    my ($self, $expression_name, $value, $units) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'set_expression_value';

    # Template text for setting an expression value
    my $template_text = <<'END_TEMPLATE';
LIBRARY: 
  CEL: 
    EXPRESSIONS: 
      &replace [% expression_name %] = [% value %] [[% units %]]
    END
  END
END
END_TEMPLATE

    # Replace the placeholders with the actual values
    $template_text =~ s/\[% expression_name %\]/$expression_name/;
    $template_text =~ s/\[% value %\]/$value/;
    $template_text =~ s/\[% units %\]/$units/;

    # Create a temporary file for the CCL output in the same directory as the class file
    my ($fh, $filename) = tempfile("${method_name}_XXXX", SUFFIX => '.ccl', DIR => $class_file_dir);

    # Write the processed template to the temporary file
    print $fh $template_text;
    close $fh;

    return $filename;
}

# Method to generate the default monitors CCL file
sub add_default_monitors {
    my ($self) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'add_default_monitors';

    # Template text for the default monitors
    my $template_text = <<'END_TEMPLATE';
FLOW: Flow Analysis 1
   OUTPUT CONTROL: 
    &replace MONITOR OBJECTS: 
      MONITOR BALANCES: 
        Option = Full
      END
      MONITOR FORCES: 
        Option = Full
      END
      MONITOR PARTICLES: 
        Option = Full
      END
      MONITOR POINT: Flow Rate
        Coord Frame = Coord 0
        Expression Value = volumeFlowMonitor
        Option = Expression
      END
      MONITOR POINT: Inlet Velocity
        Coord Frame = Coord 0
        Expression Value = inletVelMonitor
        Option = Expression
      END
      MONITOR POINT: Pressure Loss
        Coord Frame = Coord 0
        Expression Value = pressureDropMonitor
        Option = Expression
      END
      MONITOR RESIDUALS: 
        Option = Full
      END
      MONITOR TOTALS: 
        Option = Full
      END
    END
    RESULTS: 
      File Compression Level = Default
      Option = Standard
    END
  END
END
END_TEMPLATE

    # Attempt to create a temporary file for the CCL output in the specified directory
    my ($fh, $filename) = File::Temp::tempfile("${method_name}_XXXX", SUFFIX => '.ccl', DIR => $class_file_dir);

    # Check for errors during file creation
    unless ($fh) {
        die "Failed to create temporary file in $class_file_dir: $!";
    }

    # Write the processed template to the temporary file
    print $fh $template_text;
    close $fh;

    return $filename;
}


1; # Return a true value to indicate the module was loaded successfully