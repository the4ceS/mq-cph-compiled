#!/usr/bin/perl

use strict;
use warnings;

# Sample MQ Queue Manager Setup for MQ-CPH Test on Windows

my $QM_NAME = 'PERF0';

my $MQ_DEFAULT_INSTALLATION_PATH = 'C:\\Program Files\\IBM\\MQ';
my $MQ_INSTALLATION_PATH = $ENV{'MQ_INSTALLATION_PATH'} // $MQ_DEFAULT_INSTALLATION_PATH;

# For Windows, adjust these paths as needed
my $LOG_DIR = "$ENV{'MQ_DATA_PATH'}\\log";
my $DATA_DIRECTORY = "$ENV{'MQ_DATA_PATH'}\\qmgrs";

# Note: In Windows, 'setmqenv' is a .bat file, and you can't source it like in Unix/Linux.
# Environment variables set in a batch file won't affect the parent Perl process.
# You may need to set necessary MQ environment variables directly in Perl or ensure they are set globally.

# Create Queue Manager
# For Windows, consider using backticks or system() without trying to source 'setmqenv' first
my $crtmqm_cmd = "crtmqm -u SYSTEM.DEAD.LETTER.QUEUE -h 50000 -lc -ld \"$LOG_DIR\" -md \"$DATA_DIRECTORY\" -lf 16384 -lp 16 $QM_NAME";
if (system($crtmqm_cmd) == 0) {
    print "Modifying $DATA_DIRECTORY\\$QM_NAME\\qm.ini\n";
    system("perl modifyQmIni.pl \"$DATA_DIRECTORY\\$QM_NAME\\qm.ini\" qm_update.ini");

    # Start the Queue Manager
    my $strmqm_cmd = "strmqm $QM_NAME";
    system($strmqm_cmd);

    # Apply MQSC Commands
    # Directly executing these might require ensuring the commands are in a PATH-accessible location or specifying full paths
    system("runmqsc $QM_NAME < mqsc\\base.mqsc");
    system("runmqsc $QM_NAME < mqsc\\rr.mqsc");
} else {
    print "Cannot create queue manager $QM_NAME\n";
}
