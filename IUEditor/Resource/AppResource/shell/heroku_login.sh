#!/usr/bin/expect -f

set arg1 [lindex $argv 0]
set arg2 [lindex $argv 1]

spawn heroku login
expect "Enter your Heroku credentials."
expect "Email:"

send "$arg1\n"

expect "Password (typing will be hidden): "

send "$arg2\n"

expect {
	"Authentication successful." {
		exit 0
	}
    "Email:" {
        exit 1
    }
	default {
		exit 1
	}
}
