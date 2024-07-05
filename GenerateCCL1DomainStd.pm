package GenerateCCL1DomainStd;

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

# Method to create a hello world text file
sub hello_world {
    my ($self) = @_;

    # Hardcoded directory path
    my $file_path = 'D:/Jeevan/JCS00139/03CFX';

    # File name for the hello world text file
    my $file_name = 'hello_world.txt';

    # Full path to the file
    my $full_path = "$file_path/$file_name";

    # Text content for the file
    my $file_content = "hello world\n";

    # Attempt to open the file for writing
    open(my $fh, '>', $full_path) or die "Cannot create $full_path: $!";
    print $fh $file_content;
    close $fh or die "Cannot close $full_path: $!";

    return $full_path;  # Return the full path of the created file
}


# Method to create a default domain CCL file
sub default_domain {
    my ($self) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'default_domain';

    # Template text
    my $template_text = <<'END_TEMPLATE';
FLOW: Flow Analysis 1
  &replace DOMAIN: Default Domain
    Coord Frame = Coord 0
    Domain Type = Fluid
    Location = domain
    BOUNDARY: Default Domain Default
      Boundary Type = WALL      
      Location = inlet,outlet,wall
      BOUNDARY CONDITIONS: 
        MASS AND MOMENTUM: 
          Option = No Slip Wall
        END
        WALL ROUGHNESS: 
          Option = Smooth Wall
        END
      END
    END
    DOMAIN MODELS: 
      BUOYANCY MODEL: 
        Option = Non Buoyant
      END
      DOMAIN MOTION: 
        Option = Stationary
      END
      MESH DEFORMATION: 
        Option = None
      END
      REFERENCE PRESSURE: 
        Reference Pressure = 1 [atm]
      END
    END
    FLUID DEFINITION: Fluid 1
      Material = Air at 25 C
      Option = Material Library
      MORPHOLOGY: 
        Option = Continuous Fluid
      END
    END
    FLUID MODELS: 
      COMBUSTION MODEL: 
        Option = None
      END
      HEAT TRANSFER MODEL: 
        Fluid Temperature = 25 [C]
        Option = Isothermal
      END
      THERMAL RADIATION MODEL: 
        Option = None
      END
      TURBULENCE MODEL: 
        Option = SST
      END
      TURBULENT WALL FUNCTIONS: 
        Option = Automatic
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

# Method to generate the velocity inlet CCL file
sub velocity_inlet {
    my ($self, $flow_regime) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'velocity_inlet';

    my $template_text;

    if ($flow_regime eq 'turbulent') {
        $template_text = <<'END_TEMPLATE';
FLOW: Flow Analysis 1
  DOMAIN: Default Domain
    &replace BOUNDARY: inlet
      Boundary Type = INLET      
      Location = inlet
      BOUNDARY CONDITIONS: 
        FLOW REGIME: 
          Option = Subsonic
        END
        MASS AND MOMENTUM: 
          Normal Speed = velocityIn
          Option = Normal Speed
        END
        TURBULENCE: 
          Option = Medium Intensity and Eddy Viscosity Ratio
        END
      END
    END
  END
END
END_TEMPLATE
    } elsif ($flow_regime eq 'laminar') {
        $template_text = <<'END_TEMPLATE';
# Laminar flow configuration will be added here in future
END_TEMPLATE
    } else {
        die "Unknown flow regime: $flow_regime";
    }

    # Create a temporary file for the CCL output in the same directory as the class file
    my ($fh, $filename) = tempfile("${method_name}_XXXX", SUFFIX => '.ccl', DIR => $class_file_dir);

    # Write the processed template to the temporary file
    print $fh $template_text;
    close $fh;

    return $filename;
}

# Method to generate the pressure outlet CCL file
sub pressure_outlet {
    my ($self) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'pressure_outlet';

    # Template text for the pressure outlet
    my $template_text = <<'END_TEMPLATE';
FLOW: Flow Analysis 1
  DOMAIN: Default Domain
    &replace BOUNDARY: outlet
      Boundary Type = OUTLET      
      Location = outlet
      BOUNDARY CONDITIONS: 
        FLOW REGIME: 
          Option = Subsonic
        END
        MASS AND MOMENTUM: 
          Option = Static Pressure
          Relative Pressure = 0 [Pa]
        END
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

# Method to generate the wall boundary CCL file
sub wall_boundary {
    my ($self, $boundary_type) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'wall_boundary';

    my $template_text;

    if ($boundary_type eq 'no_slip') {
        $template_text = <<'END_TEMPLATE';
FLOW: Flow Analysis 1
  DOMAIN: Default Domain
    &replace BOUNDARY: wall
      Boundary Type = WALL      
      Location = wall
      BOUNDARY CONDITIONS: 
        MASS AND MOMENTUM: 
          Option = No Slip Wall
        END
        WALL ROUGHNESS: 
          Option = Smooth Wall
        END
      END
    END
  END
END
END_TEMPLATE
    } elsif ($boundary_type eq 'free_slip') {
        $template_text = <<'END_TEMPLATE';
# Free slip wall configuration will be added here in future
END_TEMPLATE
    } else {
        die "Unknown boundary type: $boundary_type";
    }

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

# Method to set SST with Curvature correction turbulence model
sub set_turbulence_SST_CC {
    my ($self) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'set_turbulence_SST_CC';

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
