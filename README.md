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

Clone repo or 'wget https://raw.github.com/digitalcardboard/phpbb-mod-q-notifier/master/phpbb-mod-q-notifier.pl' and place on your webserver, outside of the webroot.

chmod +x phpbb-mod-q-notifier.pl to set executable.

This fork uses command line parameters instead of editing the script directly,
so you'll run it like this:

> ./phpbb-mod-q-notifier.pl --username=USERNAME --password=PASSWORD --db=DATABASE --url=http://yourforum.com/ --to=email@domain.com --from=email@domain.com

Refer to the config.php file in your PhpBB directory if you need to find 
the necessary parameters.

Cron it up to run as often as you deem necessary. An hour seems decent.

For use on Dreamhost, refer to http://wiki.dreamhost.com/Crontab
See the specific info on calling the entire path to perl.

Options
-------

    -d, --debug                 (optional) force a tiny amount of debug output
    -e, --email                 (optional) force email to send regardless of moderation queue, for testing
    -h, --host=HOSTNAME         (optional) database host, defaults to localhost if not provided
    -o, --port=PORT             (optional) database port, defaults 3306 if not provided
    -u, --username=USERNAME     database username
    -p, --username=PASSWORD     database password
        --db=DATABASE           database name
    -t, --table-prefix=PREFIX   (optional) table prefix
        --url=URL               path to your forum
        --to=EMAIL              to email address
        --from=EMAIL            from email address

