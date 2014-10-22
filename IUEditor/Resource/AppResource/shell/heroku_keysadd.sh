#!/usr/bin/expect -f

spawn heroku keys:add

expect {
	"\[Yn\]" {
		send -- "Y"
		send -- "\r"
	}
	default {
		return 1
	}
}
expect EOF
