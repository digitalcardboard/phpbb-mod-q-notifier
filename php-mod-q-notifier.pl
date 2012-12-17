#!/usr/bin/perl
 
use DBI;
 
# forked : https://github.com/digitalcardboard/phpbb-mod-q-notifier
# origin : http://www.phpbb.com/community/viewtopic.php?f=72&t=832195&start=15
 
# The next nine lines are the only ones you should need to change. 
$database_host =        ""; # your database host, the same on phpBB uses
$database_port =        ""; # your database port, the same one phpBB uses
$database_name =        ""; # your database name, the same one phpBB uses
$database_username =    ""; # your database username, the same one phpbBB uses
$database_password =    ""; # your data base password, the same one phpBB uses
$table_prefix =         ""
$forum_address =        ""; # http://www.example.com/forums
$to =                   ""; # email to address
$from =                 ""; # email from address
 
# optional changes
$subject='PHPBB moderation required';
$counter_file = "check_moderator_count.txt";
$queue_file = "check_moderator_queue.tmp";
 
$post_approval_count = 0;
$post_report_count = 0;
 
open FILE, ">", $queue_file or die $!;
 
# ---------------------------------------------------------
# No changes below this line.
# ---------------------------------------------------------
$database_name = "dbi:mysql:$database_name:$database_host";
$dbh = DBI->connect($database_name,$database_username,$database_password);
 
# Check for Posts Needing Approval
$report_index = 0;
@col_titles[$report_index] = "Posts";
# Create a query of the data base.
$sql = "SELECT `poster_id`, `post_subject`, `post_text` FROM `phpbb_posts` WHERE post_approved=0";
# Give the data base a chance to prepare. Perhaps it will compile the request.
$sth = $dbh->prepare($sql);
# Run the query.
$sth->execute || die "Could not execute SQL statement ... maybe invalid?";
while (@row=$sth->fetchrow_array) {
   $post_approval_count++;
   $sql = "SELECT `username` FROM `phpbb_users` WHERE user_id=$row[0]";
   $sth2 = $dbh->prepare($sql);
   $sth2->execute || die "Could not execute SQL statement ... maybe invalid?";
   while (@row2=$sth2->fetchrow_array) {
      $name = $row2[0];
   }
   printf (FILE "Name: $name ($row[0])\nSubject: $row[1]\nText: $row[2]\n\n");
}
 
# Check for Reported Posts 
$report_index = 0;
@col_titles[$report_index] = "Posts";
# Create a query of the data base.
$sql = "SELECT `poster_id`, `post_subject`, `post_text` FROM `phpbb_posts` WHERE post_reported=1";
# Give the data base a chance to prepare. Perhaps it will compile the request.
$sth = $dbh->prepare($sql);
# Run the query.
$sth->execute || die "Could not execute SQL statement ... maybe invalid?";
while (@row=$sth->fetchrow_array) {
   $post_report_count++;
   $sql = "SELECT `username` FROM `phpbb_users` WHERE user_id=$row[0]";
   $sth2 = $dbh->prepare($sql);
   $sth2->execute || die "Could not execute SQL statement ... maybe invalid?";
   while (@row2=$sth2->fetchrow_array) {
      $name = $row2[0];
   }
   printf (FILE "Name: $name ($row[0])\nSubject: $row[1]\nText: $row[2]\n\n");
}
 
printf (FILE "--\n$forum_address/mcp.php?i=main&mode=front\n");
printf (FILE "Posts to Approve: $post_approval_count\n"); 
printf (FILE "Posts to Review: $post_report_count\n"); 
close (FILE);
 
$mod_total = $post_approval_count + $post_report_count;
 
# read counter
open (COUNTER, "<", $counter_file);
if (!($last_mod_total = <COUNTER>)) {
  $last_mod_total = 0;
}
close(COUNTER);
unlink($counter_file);
   
# send email only if moderation total has changed.
# this keeps the noise down while allowing regular checks.
if ($mod_total >0 && $mod_total != $last_mod_total) { 
 
  open FILE, "<", $queue_file or die $!;
   
  # use sendmail - works on postfix configured system also
  open(MAIL, "|/usr/sbin/sendmail -t");
    
  ## Mail Header
  print MAIL "To: $to\n";
  print MAIL "From: $from\n";
  print MAIL "Subject: $subject ($mod_total)\n\n";
  ## Mail Body
  while (<FILE>) {
    print MAIL $_;
  }
   
  close(MAIL);
  close (FILE);
   
  open COUNTER, ">", $counter_file;
  print COUNTER "$mod_total\n";
  close COUNTER;
 
  # silence is best here if we are running this from the crontab
  # as output gets forwarded to the machine admin.
  # run script with '-d' parameter to force output
    if ( $ARGV[0] eq "-d" ) {
      print "A message has been sent from $from to $to\n";
    }
} else {
    if ( $ARGV[0] eq "-d" ) {
        print "Moderation queue is empty\n";
    }
}
