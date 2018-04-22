windows svn
==============

on gitbash:

    $ svn relocate --username <username> --password '<password>' url

after this, svn will not prompt for username and password again. they will be
stored (password encoded) under %appdata%/subversion/auth
