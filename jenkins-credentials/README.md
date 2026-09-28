# Jenkins Username and Password Credential Demo

## What it is
A "Username with password" credential stores a login pair in Jenkins.
A job binds it to two environment variables at build time, so the
password never appears in the script or the repo.

## Files
- `userpass-demo.sh`: reads `$MY_USER` and `$MY_PASS` and prints them.

## Expected console output
    Username is: demouser
    Password is: ****
    Password length: 11

Jenkins masks the password as `****`. The username is not secret, so it
shows in plain text. The length line proves the script still receives
the real value.

## Notes
- Never hardcode passwords in scripts or commit them to GitHub.
- Use demo values only. Rotate any real credential that appears in logs.
