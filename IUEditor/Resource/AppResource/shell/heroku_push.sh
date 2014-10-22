#!/usr/bin/expect -f

#call heroku auth
set git [lindex $argv 0]
set timeout 300

spawn $git push --force heroku master

expect {
    "Are you sure you want to continue connecting" {
        send -- "yes"
        send -- "\r"
        exp_continue
    }
    timeout{
        exit
    }
    eof{
        exit
    }
}