goal
=========
- huge amount of files in source server
- files need to sync to dest server
- rsync take time to find different files
- use inotify and got fileinfo for rsync, and speed up transfer 


package install
============
- yum install epel-relase -y
- yum install inotify-tools -y
- yum install rsync -y


execute method
==============
- ./inotify.sh &