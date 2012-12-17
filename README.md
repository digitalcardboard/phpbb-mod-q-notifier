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

Clone repo or 'wget https://raw.github.com/digitalcardboard/phpbb-mod-q-notifier/master/php-mod-q-notifier.pl' and place on your webserver, outside of the webroot.

Open script with your favorite text editor and make the appropriate
variables changes. Refer to the config.php file in your PhpBB directory,
if necessary.

chmod +x php-mod-q-notifier.pl to set executable.

Cron it up to run as often as you deem necessary. An hour seems decent.

For use on Dreamhost, refer to http://wiki.dreamhost.com/Crontab
See the specific info on calling the entire path to perl.

Run script with '-d' parameter to force a tiny amount of debug output.
