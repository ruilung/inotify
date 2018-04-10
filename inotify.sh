#!/bin/bash
#
# package install
# yum install epel-relase -y
# yum install inotify-tools -y
# yum install rsync -y
#
# execute method
# ./inotify.sh &
 

# make sure these directories are fit your enviroment (exist)
v_src_dir="/opt/tmp/"     # source dir for rsync (change to your directory)
v_dst_dir="/opt/tmp/"     # dest dir for rsync (change to your directory)
v_log_dir="/opt/ray/logs" # log dir for this script, check them and have clean action
v_work_dir="/opt/ray"     # work dir for this script, flag file put in here

v_dst_ip="YOUR DEST SERVER IP"   # suggestion: put sshkey to dst, for rsync can login by ssh without keyin password
v_date=$(date +"%Y%m%d")

 
#check rsync is running or not
if [[ -e rsync.flag ]]
  then 
    echo 'error: rsync flag exist. please check rsync process. '
    exit 1
  else
    cd ${v_work_dir}
    touch rsync.flag
    rsync -azv --delete --stats --bwlimit=15000 -e ssh ${v_src_dir} ${v_dst_ip}:${v_dst_dir} >> ${v_log_dir}/${v_date}_rsync.log
    rm -rf rsync.flag
fi


#check inotifywait is running or not
if [[ -n $(pidof inotifywait) ]]
  then
    echo 'error: got another instance of inotifywait'
    exit 1
fi


#while loop and got event of inotifywait
/usr/bin/inotifywait -mrq --timefmt '%Y%m%d %H%M%S' --format '%T %w %f %e' -e close_write,move,delete ${v_src_dir} | while read v_date v_time v_dir v_file v_event
do
v_dir_file=${v_dir}${v_file}
# echo ${v_dir_file}
echo "${v_date} ${v_time} ${v_event} ${v_dir}${v_file}" >> ${v_log_dir}/${v_date}_inotify.log
echo "${v_date} ${v_time}" >> ${v_log_dir}/${v_date}_rsync.log
#rsync -azv --delete --ignore-errors --bwlimit=15000 -e ssh ${v_dir_file} ${v_dst_ip}:${v_dir_file} >> ${v_log_dir}/${v_date}_rsync.log
  case ${v_event} in
      "DELETE"|"MOVED_FROM")  # rsync folder to delete file
        #echo "delete"
        echo "rsync -azv --delete --stats --ignore-errors --bwlimit=15000 -e ssh ${v_dir} ${v_dst_ip}:${v_dir}" >> ${v_log_dir}/${v_date}_rsync.log
        rsync -azv --delete --stats --ignore-errors --bwlimit=15000 -e ssh ${v_dir} ${v_dst_ip}:${v_dir} >> ${v_log_dir}/${v_date}_rsync.log
        ;;
      *)                      # rsync file to dst
        #echo "default"
        echo "rsync -azv --delete --stats --ignore-errors --bwlimit=15000 -e ssh ${v_dir_file} ${v_dst_ip}:${v_dir_file}" >> ${v_log_dir}/${v_date}_rsync.log
        rsync -azv --delete --stats --ignore-errors --bwlimit=15000 -e ssh ${v_dir_file} ${v_dst_ip}:${v_dir_file} >> ${v_log_dir}/${v_date}_rsync.log
        ;;
  esac
done
