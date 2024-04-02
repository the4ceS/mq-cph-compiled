#!/usr/bin/perl

use strict;
use warnings;

# Sample MQ Queue Manager Setup for MQ-CPH Test (Converted to Perl)

my $QM_NAME = 'PERF0';

my $MQ_DEFAULT_INSTALLATION_PATH = '/opt/mqm';
my $MQ_INSTALLATION_PATH = $ENV{'MQ_INSTALLATION_PATH'} // $MQ_DEFAULT_INSTALLATION_PATH;
$ENV{'MQ_INSTALLATION_PATH'} = $MQ_INSTALLATION_PATH;

# Source the setmqenv - not directly possible in Perl, so we execute commands in subshells where it's sourced
sub source_setmqenv {
    my $command = shift;
    return `source \$MQ_INSTALLATION_PATH/bin/setmqenv; $command`;
}

#Override the following two variables for non-default file locations
my $LOG_DIR = "$ENV{'MQ_DATA_PATH'}/log";
my $DATA_DIRECTORY = "$ENV{'MQ_DATA_PATH'}/qmgrs";

# Create Queue Manager
my $crtmqm_cmd = "crtmqm -u SYSTEM.DEAD.LETTER.QUEUE -h 50000 -lc -ld $LOG_DIR -md $DATA_DIRECTORY -lf 16384 -lp 16 $QM_NAME";
if (system(source_setmqenv($crtmqm_cmd)) == 0) {
    print "Modifying $DATA_DIRECTORY/$QM_NAME/qm.ini\n";
    system("perl ./modifyQmIni.pl $DATA_DIRECTORY/$QM_NAME/qm.ini ./qm_update.ini");

    # Start the Queue Manager
    my $strmqm_cmd = "strmqm $QM_NAME";
    system(source_setmqenv($strmqm_cmd));

    # Apply MQSC Commands
    my $runmqsc_base_cmd = "runmqsc $QM_NAME < ./mqsc/base.mqsc";
    system(source_setmqenv($runmqsc_base_cmd));
    
    my $runmqsc_rr_cmd = "runmqsc $QM_NAME < ./mqsc/rr.mqsc";
    system(source_setmqenv($runmqsc_rr_cmd));
} else {
    print "Cannot create queue manager $QM_NAME\n";
}
