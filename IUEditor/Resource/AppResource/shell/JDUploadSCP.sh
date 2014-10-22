#!/usr/bin/expect -f

set from [lrange $argv 0 0]
set to [lrange $argv 1 1]
set password [lrange $argv 2 2]

set timeout 2
# now connect to remote UNIX box (ipaddr) with given script to execute
#spawn scp -r $local $remote  $user@$ipaddr:$remotefile
spawn scp -r $from $to
match_max 100000
# Look for passwod prompt
expect "*?assword:*"
set timeout 2
# Send password aka $password 
send -- "$password\r"
# send blank line (\r) to make sure we get back to gui
send -- "\r"
expect eof

