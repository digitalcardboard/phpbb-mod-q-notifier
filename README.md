phpbb-mod-q-notifier
====================

Fork of PhpBB 3 Email Notification for Moderation Queue
http://www.mugginsoft.com/content/phpbb-3-email-notification-moderation-queue

Which in turn was forked from:
origin : http://www.phpbb.com/community/viewtopic.php?f=72&t=832195&start=15

Small changes to allow for use on with a separate database server and other
general needs.

Instructions
------------

Clone repo or wget phpbb-mod-q-notifier.pl and place on your webserver, 
outside of the webroot.

Open script with your favorite text editor and make the appropriate
variables changes. Refer to the config.php file in your PhpBB directory,
if necessary.

Cron it up to run as often as you deem necessary. An hour seems decent.

Run script with '-d' parameter to force a tiny amount of debug output.
