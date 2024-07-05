package GenerateCCLforDomainStd;

use strict;
use warnings;
use File::Temp qw(tempfile);
use File::Basename;
use Cwd 'abs_path';

# Constructor
sub new {
    my ($class, %args) = @_;
    my $self = {
        domains => $args{domains} || [],
    };
    bless $self, $class;
    return $self;
}

# Method to set SST with Curvature correction turbulence model
sub set_turbulence_SST_CC {
    my ($self) = @_;

    # Get the directory of the current file (class file)
    my $class_file_dir = dirname(abs_path($0));

    # Method name for the prefix
    my $method_name = 'set_turbulence_SST_CC';

    # Initialize the CCL content
    my $ccl_content = "FLOW: Flow Analysis 1\n";

    # Loop through each domain and append the respective section to the CCL content
    foreach my $domain (@{$self->{domains}}) {
        $ccl_content .= <<"END_DOMAIN";
  DOMAIN: $domain
    FLUID MODELS:       
      &replace  TURBULENCE MODEL: 
        Option = SST
        CURVATURE CORRECTION: 
          Curvature Correction Coefficient = 1.0
          Option = Production Correction
        END
      END
      &replace TURBULENT WALL FUNCTIONS: 
        Option = Automatic
      END
    END      
  END
END_DOMAIN
    }

    # Add the final END statement for the FLOW block
    $ccl_content .= "END\n";

    # Attempt to create a temporary file for the CCL output in the specified directory
    my ($fh, $filename) = File::Temp::tempfile("${method_name}_XXXX", SUFFIX => '.ccl', DIR => $class_file_dir);

    # Check for errors during file creation
    unless ($fh) {
        die "Failed to create temporary file in $class_file_dir: $!";
    }

    # Write the processed template to the temporary file
    print $fh $ccl_content;
    close $fh;

    return $filename;
}

1; # Return a true value to indicate the module was loaded successfully
