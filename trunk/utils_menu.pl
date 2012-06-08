# Michael Paulukonis
# Nov 26, 2007 - Feb 2008
# http://pmwiki.divintech.com/pmwiki.php?n=IT.UsingCVS#Scripting

use strict;
use warnings;
use Data::Dumper;
use feature "switch";
use Cvs_Support;                # no name-space declared

my $maintain_loop = 1;

while ($maintain_loop) {

  parse_menu();

}

1;

## SUBROUTINES

sub parse_menu {

  my @menu = get_menu();

  my $count = scalar @menu;

  #print_menu();
  print "\n\ntools for ".PROJ_NAME().":\n\n";

  # okay smart guy, where's the enumeration?
  my $i;
  map { print sprintf('%2s> ', $i++).$_->[1]."\n"; } @menu;

  print "\n\n Enter option: ";

  chomp (my $selection = <STDIN>);

  # throws error on non-numeric [eg, empty return]
  #$selection = (/d+/ ? $selection : ($count - 1) );
  $selection = (($selection ne '') && ($selection < $count)) ? $selection : ($count - 1); #if invalid, default to menu (last option)

  my $option = $menu[$selection][0] || '--menu'; # selection, or default to menu

  #print "\n\nyou want to $menu[$selection][1]\n"; # doesn't work for unitialized values

  given ($option) {
    when(/-*(menu)/i)    { }
    when(/exit/i)        { $maintain_loop = 0; }
    when(/commit$/i)     { commit(); }
    default              { system("cvs_utils.pl"." ".$option);}
  }

}

sub commit {

  print "comments for commit: ";
  chomp (my $comments = <STDIN>);

  my $command = "cvs_utils.pl --action=commit -comments=\"$comments\"";

  system($command);

}

#associative array of command-line options, w/ descriptive text
sub get_menu {

  my @menu = (["--help",                                         "Print HELP File."],
              ["--action=commit",                                "Commit project folder [THIS] to CVS"],
              ["--action=snapshot -source=TEST",                 "Create a dated SNAPSHOT dir of code as found in TEST server"],
              ["--action=snapshot -source=DEV",                  "Create a dated SNAPSHOT dir of code as found in DEV server"],
              ["--action=coderelease -source=TEST",               "Create a dated CODE RELEASE dir of code as found in the TEST server"],
              ["--action=copy -source=DEV -dest=HERE",           "Copy files from DEV to PROJECT"],
              ["--action=copy -source=HERE -dest=TEST",          "Copy files from PROJECT to TEST"],
              ["--action=copy -source=HERE -dest=DEV",           "Copy files from PROJECT to DEV"],
              ["--action=copy -source=TEST -dest=HERE",          "Copy files from TEST    to PROJECT."],
              ["--action=copy -source=TEST -dest=DEV",           "Copy files from TEST    to DEV."],
              # NOTE: you should never NEVER copy directly from DEV to anything but the project
              #       commit to the CVS, then roll it out somewhere
              #       of course, this can't really be enforced. So. whatevs.
              ["--action=printlist",                             "Print list of files."],
              ["--action=timelist",                              "Print time-list."],
              ["--action=timecompare -source=DEV -dest=HERE",    "Compare times DEV and PROJECT."],
              ["--action=timecompare -source=DEV -dest=TEST",    "Compare times DEV and TEST."],
              ["--exit",                                         "EXIT"],
              ["--menu",                                         "Print this menu"],
             );

  return @menu;

}

