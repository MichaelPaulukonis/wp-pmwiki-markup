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
sub DEV()  { return "\\\\pawpidw2\\CFSites\\" } ;
#sub DEV()  { return "e:\\tmp\\esis_test\\" } ;

sub TEST()    { return "\\\\nykwidw3\\ACEESISTest\\" } ;

sub CODE_RELEASE() { return "\\\\pawpicr17\\FWShare\\CodeRelease\\" } ;

sub PROJ_NAME()  { return "ACE_ESIS_Netview" }; #Update to match project


sub get_projectfiles {
  # list of project files (2-d array)
  # ["<sub-dir\\", "<filename.ext>"]

  my @list = ( ["ACEESISDev\\AJAX\\",		 "lookupClaimNumberDataAPL.cfm"],
               ["",				 "lookupClaimNumberDataWC.cfm"],
               ["",				 "updateClaimNumber.cfm"],
               ["",				 "verifyClaimNumberAPL.cfm"],
               ["",				 "verifyClaimNumberWC.cfm"],

               ["ACEESISDev\\",			 "Application.cfm"],
               ["",				 "index.cfm"],
               ["",				 "login_action.cfm"],
               ["",				 "logout.cfm"],
               ["",				 "timeout.cfm"],

               ["ACEESISDev\\secure\\workflow\\ESIS",
		                                 "changeQueue_action.cfm"],
               ["",				 "leftnav.cfm"],
               ["",				 "sendToIndexing_action.cfm"],
               ["",				 "sendToLetterQueue_action.cfm"]

             );


  return @list;
}


1;  ## keep Perl compiler absurdly happy
