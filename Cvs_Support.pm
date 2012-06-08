# Michael Paulukonis
# Nov 26, 2007

#package Cvs_Support; # commented out for the time-being, to keep things working....

# use strict;
use warnings;

use File::stat;
use Time::localtime;

# subs that replaced file-constants
# possible, local_dev and fw_test could remain constants
# however, PROJ_NAME should be stored over here
sub DEV()  { return "\\\\dev_server\\CFSites\\" } ;

sub TEST()    { return "\\\\test_server\\ACEESISTest\\" } ;

sub CODE_RELEASE() { return "\\\\path_to\\CodeRelease\\" } ;

sub PROJ_NAME()  { return "proj_name" }; #Update to match project


sub get_projectfiles {
  # list of project files (2-d array)
  # ["<sub-dir\\", "<filename.ext>"]

  my @list = ( ["root\\AJAX\\",		 "lookupClaimNumberDataAPL.cfm"],
               ["",				 "lookupClaimNumberDataWC.cfm"],
               ["",				 "updateClaimNumber.cfm"],
               ["",				 "verifyClaimNumberAPL.cfm"],
               ["",				 "verifyClaimNumberWC.cfm"],

               ["root\\",			 "Application.cfm"],
               ["",				 "index.cfm"],
               ["",				 "login_action.cfm"],
               ["",				 "logout.cfm"],
               ["",				 "timeout.cfm"],

               ["root\\secure\\workflow\\ESIS",
		                                 "changeQueue_action.cfm"],
               ["",				 "leftnav.cfm"],
               ["",				 "sendToIndexing_action.cfm"],
               ["",				 "sendToLetterQueue_action.cfm"]

             );


  return @list;
}


1;  ## keep Perl compiler absurdly happy
