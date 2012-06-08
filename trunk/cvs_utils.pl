# Michael Paulukonis
# Nov 26, 2007 - Jan 2010
# this is included as past-code example for a dev-to-production script

use strict;
use warnings;

use File::stat;
use File::Spec;
use Time::localtime;
use Cwd;
use File::Copy;
use File::Path;
use Getopt::Long;
use Data::Dumper;

use feature "switch";

use Win32::TieRegistry(Delimiter=>"/");
use Win32::API;

use Cvs_Support;                # no name-space declared


my ($force_copy,$copy_ini) = 0; # default to false
my ($action,$source,$dest,$comments) = "";

GetOptions ("help|?"            => $action="help",
            "action:s"          => \$action,
            "source:s"          => \$source,
            "destination:s"     => \$dest,
            "comments:s"        => \$comments,
            "forcecopy!"        => \$force_copy);

if ( $action eq "" ) {
  print "\nNo action indicated!!!\n\n";
  print_help();
  die();
}

$source = convert_shortcut($source);
$dest = convert_shortcut($dest);

# TODO: come up with some sort of filter that can be passed around....
given ($action) {
  when(/help/i)				 { print_help(); }
  when(/commit/i)			 { commit_it($comments); }
  when(/copy/i)				 { if ($source && $dest) {
    my @files = get_files();
    copy_from_to(\@files, $source, $dest, $force_copy);
  } else { print "Source and Dest not set!\n\n";} }
  when(/snapshot/i)                      { snapshot($source); }
  when(/printlist/i)                     { print_list(); }
  when(/printenvironment/i)              { print_environment(); }
  when(/timelist|listtime/i)		 { print_time( $source ); }
  when(/timecompare|comparetime/i)	 { compare_time( $source, $dest ); }
  when(/coderelease|cr/i)		 { coderelease( $source, CODE_RELEASE()); }
  default				 { print "\n\nunknown action '$action'.\n\n"; print_help(); }
}

1;				# exit app after parsing options

sub convert_shortcut {

  my $short = $_[0] || "";
  my $conv = "";

  given ($short) {
    when(/^dev/i)                  { $conv = DEV(); }
    when(/^test/i)                 { $conv = TEST(); }
    when(/^prod/i)                 { $conv = PROD() ; }
    when(/^(here|this|local)/i)    { $conv = getcwd() ; }
    default                        { $conv = ""; }
  }

  return $conv;

}


# is $name1 newer than $name2
sub is_newer {
  my($name1,$name2) = @_;

  my $date_1 = 0;
  my $date_2 = 0;

  if (-e $name1) {
    $date_1 = stat($name1)->mtime;
  }
  if (-e $name2) {
    $date_2 = stat($name2)->mtime;
  }

  return ($date_1 > $date_2);
}


# wait for keypress, so cmd-window doesn't vanish
sub wait_for_it {
  print "\n\nHit enter to exit.";
  getc;
  print "\n\n";
}

# return list of project files
sub get_files {
  my $local_path = getcwd() . "/"; # script should reside in CVS folder

  # list of project files (2-d array)
  my @project_files = get_projectfiles();

  my $fcount = scalar @project_files; # capture the length of the array

  my @files;
  my $sub_dir;

  for (my $i=0; $i < $fcount; $i++) {

    #retrieve/assign sub_dir
    for ($project_files[$i][0]) {
      if (/--/) {
        $sub_dir = "";
      }                         # file s/b local
      elsif (!(/^$/)) {
        $sub_dir = $project_files[$i][0];
      }                         # not blank, use what we got
    }

    #retrieve/assign name
    my $name = $project_files[$i][1];

    $files[$i][0] = $sub_dir;
    $files[$i][1] = $name;

  }

  return @files;

}

# print list of files
# bulk of below is just some easy-on-the-eyes formatting.
sub print_list {
  my (@files) = get_files();
  my $fcount = scalar @files;
  my $prev_sub_dir = "";

  for (my $i=0; $i< $fcount; $i++) {
    my $sub_dir = $files[$i][0];
    if ($sub_dir ne $prev_sub_dir) {
      $prev_sub_dir = $sub_dir;
      $sub_dir = "\n" . $sub_dir; #add an extra LF to the first one
    }
    my $name = $sub_dir . $files[$i][1];
    print "\n$name";
  }

}

# copy files from one place to another
# would be nice to supply the file list
# which could have been passed through a filter, f'r instance
sub copy_from_to {

  my (@files) = @{ $_[0] };
  my $source_path = $_[1];
  my $dest_path = $_[2];
  my $force_copy = $_[3];

  my @copied; #holds list of files actually copied, for eye-candy reports

#   print Dumper(@files, $source_path, $dest_path, $force_copy);
#   return 0;

  print "source: $source_path\ndest: $dest_path\n\n";

  if ($force_copy) {
    print "\n\nCOPY IS FORCED!!!\n";
  } else {
    print "\n\nCOPY NEW FILES ONLY (no force)\n\n";
  }


  #my (@files) = get_files();

  my $fcount = scalar @files;	# capture the length of the array

  for (my $i=0; $i < $fcount; $i++) {

    my $sub_dir = $files[$i][0];
    my $name = $files[$i][1];
    my $source = File::Spec->catdir($source_path, $sub_dir, $name);
    my $destination = File::Spec->catdir($dest_path, $sub_dir, $name);

    my $folder = File::Spec->catdir($dest_path,$sub_dir);

    if ((! $sub_dir eq "")  && (! -e $folder)) {
      mkpath($folder, 1, 0777) || die "cannot mkpath $folder: $!\n";
      print "\nCreated $folder\n";
    }

    if (! -e $source) {
      # if sourcedoesn't exist, something is wrong with the setup.
      die "\n\nCan't find $source - check project files: $!";
    } else {
	if ( (is_newer($source, $destination)) || $force_copy ) {
	  if (-e $destination) {
	    unlink($destination); # if exists (-e) delete
	  }
	  copy($source, $destination) or die "Copy failed: $!";
	  print "copied $name\t to $dest_path$sub_dir...\n";
	  #@copied = (@copied, $name);
	  push(@copied, $name);
	} else {
	  # ignore this file, as the local copy (CVS vers.) is newer than the server
	  print "Nothing new under the sun for $name\n";
	}
    }
  }

  print "\n\ncopied:\n";
  foreach my $file (@copied) {
    print "\t$file\n";
  }

  }

# commit
sub commit_it {

  my $comment = chomp($_[0]);

  # commit entire repository to server
  # NOTE: comments same for all files, as provided - you want to commit individually? you can do so.... just not here
  # unless, you know, we get some wicked keen filtering working....
  my $cvs_command = "cvs -q -x commit -m \"$comments\" ";
  print "\n$cvs_command\n";
  system($cvs_command);

}

# add a time-stamp to make sure we're generating a unique name
# if duplicating dirname, throws snapshot & a bunch of other crap in there
# this is wrong....
sub getUniqueName {

  my $unique = sprintf("%02d%02d%02d", localtime->hour(), localtime->min(), localtime->sec() );

  return getSnapshotName() . "_" . $unique;

}


sub yyyymmdd {

  my $year =  localtime->year() + 1900;           # counts from 1900
  my $day =  sprintf("%02d", localtime->mday() ); # counts from 1
  my $month = sprintf("%02d", localtime->mon() +1 ); # counts from 0

  return $year.'-'.$month.'-'.$day;

}



# snapshot name base
sub getSnapshotName {

  my $year =  localtime->year() + 1900;           # counts from 1900
  my $day =  sprintf("%02d", localtime->mday() ); # counts from 1
  my $month = sprintf("%02d", localtime->mon() +1 ); # counts from 0


  # drop everything into the SNAPSHOT dir, then subdivided by project and date
  # not using a time-stamp, as it's so infrequent you can do that manually
  my $new_dir = "SNAPSHOT\\".PROJ_NAME()."_SNAPSHOT_$year-$month-$day";

  return $new_dir;

}

# code-release pathname is NOT the same as snapshot......
# it's path, date, project-name, folders
# otherwise, same actions....
# default to unique neame w/o asking....
# would be nice if it compared files to production, and only copied newer files....
sub coderelease {

  my $from = $_[0];
  my $to = $_[1];

  my $crDir = yyyymmdd().'\\'.PROJ_NAME().'\\';

  #check if $crDir already exists, and take appropriate action
  if (-e $to.$crDir) {
    $crDir = getUniqueName($crDir);
  }

  #won't work, this smoothly, as CR is one folder up....
  my @files = get_files();
  copy_from_to(\@files, $from, $to.$crDir."\\", 1);

  return $to.$crDir;            # return the new code-release location


}

########################################################################
#
# code-snapshot
# take all VBPs (at this point) and make copies in a prefix'd, dated-director
# eg, IC_SNAPSHOT_03132008
# returns new location
#
########################################################################
sub snapshot {

  # uses "copy_from_to" with a generated "to" directory....
  # localtime notes at http://homepage.mac.com/corrp/macsupt/macperl/localtime.html

  my $loc = $_[0];

  my $snapshot_dir = getSnapshotName();

  my $new_loc = $loc.$snapshot_dir."\\";

  #check if $snapshot_dir already exists, and take appropriate action
  if (-e $loc.$snapshot_dir) {
    print "\n\n $loc$snapshot_dir already exists. Overwrite (Y/N)?: ";
    chomp (my $confirm = <STDIN>);

    if ($confirm =~ /^n/i ) {
      $snapshot_dir = getUniqueName($snapshot_dir);
    }
    # else - just ignore it, and overwite, right?

  }

  # force_copy
  my @files = get_files();
  copy_from_to(\@files, $loc, $loc.$snapshot_dir."\\", 1);

  # don't use "wait_for_it()" here, as copy_from_to executes it, as well....

  return $loc.$snapshot_dir; # return the new snapshot location

}

# prints major definitions
sub print_environment {

  print "\n\nEnvironment: \n";
  print "\nDEV: ".DEV();
  print "\nTEST: ".TEST();
  print "\nProject: ".PROJ_NAME();
  print "\n\n";

}

# TODO: make this a HEREDOC
sub print_help {

  print "\nCopy-and-Commit utilities for DIT/FormWare/InputAccel";

  print "\n\nCommand Line Options:\n";
  print "  -help|?\n";
  print "  -action\n";
  print "    available actions are:\n";
  print "    commit\n";
  print "    copy\n";
  print "    snapshot\n";
  print "    print\n";
  print "    timelist|listtime\n";
  print "    timecompare|comparetime\n";
  print "    coderelease|cr\n";
  print "  -source         - must be supplied when action = 'copy'\n";
  print "  -destination\n";
  print " locations are: DEV, PROD, TEST, and HERE|LOCAL|THIS (for the project folder)\n";
  print " locations are set in the Cvs_Support.pm file\n";

  print "  -comments\n     - when action = 'commit'";
  print "  -(no)forcecopy  - \"no\" can be replaced with \"!\"\n";
  print "  -(no)copyini    - \"no\" can be replaced with \"!\"\n";

  print "\nThere are no options to add files/folders; please do manually.";
  print "\n";
  print "\nIf you're reading this file from Explorer, you probably want to create shortcuts";
  print "\nfor the above options. If your command-path is enclosed in quotation marks, the ";
  print "\nparameter will be _outside_ the quotes.";

}

  # prints time-stamps for all files in provided project
  # print_time($environment)
  sub print_time {

    my $target_env = $_[0];

    # TODO: need to ensure a trailing slash....

    print "\n$target_env:\n";

    my (@files) = get_files();
    my $fcount = scalar @files; # capture the length of the array

    for (my $i=0; $i < $fcount; $i++) {

      my $sub_dir = $files[$i][0];
      my $name = $files[$i][1];
      my $target = File::Spec->catdir($target_env, $sub_dir, $name);

      my $modTime = stat($target)->mtime;
      print ctime($modTime) . ": " . $name . "\n";
    }

  }

# prints time-stamps for all files in provided project
# print_time($environment)
# returns array of newer items in env1
# would be nice if this had no side-effects (like printing)
sub compare_time {

  my ($env1, $env2) = @_;
  my @newer_files;

  print "\nfirst env: $env1\nsecond env: $env2\n";
  print "listing differences only....\n";

  my (@files) = get_files();
  my $fcount = scalar @files; # capture the length of the array

  for (my $i=0; $i < $fcount; $i++) {

    my $sub_dir = $files[$i][0];
    my $name = $files[$i][1];
    my $path1 = File::Spec->catdir($env1, $sub_dir, $name);
    my $path2 = File::Spec->catdir($env2, $sub_dir, $name);

    my $time1 = 0;
    my $time2 = 0;

    #print "$path1\n$path2\n";

    if (-e $path1) {
      $time1 = stat($path1)->mtime || die "can't stat $path1 : $!";
    }
    if (-e $path2) {
      $time2 = stat($path2)->mtime || die "can't stat $path2 : $!";
    }

    if ($time1 != $time2) {
      print ctime($time1) . ": " . $path1 . "\n";
      print ctime($time2) . ": " . $path2 . "\n";
      if ($time1 > $time2) { push(@newer_files, File::Spec->catdir($sub_dir, $name)); };
    } else {
      print "$name has identical time-stamps\n";
    }

  }

  foreach my $file (@newer_files) {
    print "\t$file\n";
  }

  return @newer_files;

}
