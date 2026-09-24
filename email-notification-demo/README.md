# Email Notification Demo (SMTP Configuration)

This folder demonstrates sending build result emails from Jenkins using the
built-in `mail` step, triggered from a pipeline's `post { }` block.

---

## Step 1 — Configure SMTP in Jenkins (one-time, applies to all jobs)

1. Manage Jenkins → System
2. Scroll to **E-mail Notification**
3. SMTP server: e.g. `smtp.gmail.com`
4. Click **Advanced**
5. Check **Use SMTP Authentication**
   - Username: your email address
   - Password: an **App Password** (not your real account password — required by Gmail/most providers when MFA is on)
6. Check **Use SSL** (port 465) or **Use TLS** (port 587), matching your provider
7. Set **SMTP Port** accordingly
8. Scroll to **Test configuration by sending test e-mail**
9. Enter your own email → click **Test configuration**
10. Confirm the test email arrives → Save

### Example values (Gmail)

```
SMTP server:       smtp.gmail.com
SMTP Port:         465
Use SSL:           checked
Username:          your.email@gmail.com
Password:          <Gmail App Password>
```

### Example values (Outlook/Office 365)

```
SMTP server:       smtp.office365.com
SMTP Port:         587
Use TLS:           checked
Username:          your.email@outlook.com
Password:          your account password (or app password if MFA enabled)
```

---

## Step 2 — Update the Jenkinsfile

Open `Jenkinsfile` in this folder and replace `YOUR_EMAIL@example.com` in
both the `success` and `failure` blocks with your real email address before
pushing.

---

## Step 3 — Jenkins job setup

1. New Item → name: `email-notification-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `email-notification-demo/Jenkinsfile`
6. Save → Build Now

---

## Step 4 — Verify both paths

**Success path:** run the build as-is — you should receive a "SUCCESS" email.

**Failure path:** edit the Jenkinsfile, uncomment this line in the `Build` stage:
```groovy
sh 'exit 1'
```
Push, rebuild — you should receive a "FAILED" email instead, with a link straight to the console output.

---

## Common issues

| Symptom | Likely cause |
|---|---|
| "Could not connect to SMTP host" | Wrong port, or the port is blocked by your network/firewall |
| "Authentication failed" | Wrong password — Gmail needs an App Password, not your real password |
| Test email works, but pipeline email never arrives | `mail to:` address has a typo, or spam folder |
| Nothing happens, no error | SMTP wasn't saved, or the `post` block condition (`success`/`failure`) never matched what actually happened |

