#!/usr/bin/perl
 
use strict;
use Getopt::Long;
use DBI;
 
# forked : https://github.com/digitalcardboard/phpbb-mod-q-notifier
# origin : http://www.phpbb.com/community/viewtopic.php?f=72&t=832195&start=15
 
# optional changes
my $subject='PHPBB moderation required';
my $counter_file = "check_moderator_count.txt";
my $queue_file = "check_moderator_queue.tmp";
 
my $post_approval_count = 0;
my $post_report_count = 0;
 
# ---------------------------------------------------------
# No changes below this line.
# ---------------------------------------------------------

# default variables
my $database_host =        "localhost"; # your database host, the same on phpBB uses
my $database_port =        "3306"; # your database port, the same one phpBB uses
my $database_name =        ""; # your database name, the same one phpBB uses
my $database_username =    ""; # your database username, the same one phpbBB uses
my $database_password =    ""; # your data base password, the same one phpBB uses
my $table_prefix =         "";
my $forum_address =        ""; # http://www.example.com/forums
my $to =                   'postmaster@domain.com'; # email to address, must be single-quoted
my $from =                 'postmaster@domain.com'; # email from address, must be single-quoted
 
my %options=();
(GetOptions( \%options,
    "d|debug",
    "e|email",
    "h|host=s" => \$database_host,
    "o|port=i" => \$database_port,
    "u|username=s" => \$database_username,
    "p|password=s" => \$database_password,
    "db=s" => \$database_name,
    "t|table-prefix=s" => \$table_prefix,
    "url=s" => \$forum_address,
    "to=s" => \$to,
    "from=s" => \$from
)) || die "ERROR: Unknown arguments or parameters.\n" unless ($#ARGV < 0);

if ( $options{d} ) {
    print "database_host: $database_host\n";
    print "database_port: $database_port\n";
    print "database_username: $database_username\n";
    print "database_password: $database_password\n";
    print "database_name: $database_name\n";
    print "table_prefix: $table_prefix\n";
    print "forum_address: $forum_address\n";
    print "to: $to\n";
    print "from: $from\n";
}

open FILE, ">", $queue_file or die $!;

my $dsn = "dbi:mysql:$database_name:$database_host:$database_port";
my $dbh = DBI->connect($dsn,$database_username,$database_password);
 
# Check for Posts Needing Approval
# Create a query of the database.
my $sql = "SELECT `poster_id`, `post_subject`, `post_text` FROM `${table_prefix}phpbb_posts` WHERE post_approved=0";
# Give the database a chance to prepare. Perhaps it will compile the request.
my $sth = $dbh->prepare($sql);
# Run the query.
$sth->execute || die "Could not execute SQL statement ... maybe invalid?";
my (@row, @row2, $name, $sth2);
while (@row=$sth->fetchrow_array) {
   $post_approval_count++;
   $sql = "SELECT `username` FROM `${table_prefix}phpbb_users` WHERE user_id=$row[0]";
   $sth2 = $dbh->prepare($sql);
   $sth2->execute || die "Could not execute SQL statement ... maybe invalid?";
   while (@row2=$sth2->fetchrow_array) {
      $name = $row2[0];
   }
   printf (FILE "Name: $name ($row[0])\nSubject: $row[1]\nText: $row[2]\n\n");
}
 
# Check for Reported Posts 
# Create a query of the database.
$sql = "SELECT `poster_id`, `post_subject`, `post_text` FROM `${table_prefix}phpbb_posts` WHERE post_reported=1";
# Give the database a chance to prepare. Perhaps it will compile the request.
$sth = $dbh->prepare($sql);
# Run the query.
$sth->execute || die "Could not execute SQL statement ... maybe invalid?";
while (@row=$sth->fetchrow_array) {
   $post_report_count++;
   $sql = "SELECT `username` FROM `${table_prefix}phpbb_users` WHERE user_id=$row[0]";
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
 
my $mod_total;
my $last_mod_total;

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
if (($mod_total >0 && $mod_total != $last_mod_total)
    || $options{e}) { 
 
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
    if ( $options{d} ) {
      print "A message has been sent from $from to $to\n";
    }
} else {
    if ( $options{d} ) {
        print "Moderation queue is empty\n";
    }
}

