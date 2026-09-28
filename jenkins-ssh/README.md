# Jenkins SSH Key Credential Demo

## What it is
An "SSH Username with private key" credential lets Jenkins clone private
repos over SSH without a password. The private key stays in Jenkins.
The public key is added to GitHub as a deploy key.

## Files
- `sshkey-demo.sh`: confirms the checkout came over SSH and prints the latest commit.

## Setup summary
1. Generate a dedicated key pair (no passphrase for the demo):
       ssh-keygen -t ed25519 -f ~/.ssh/jenkins_demo_key -C "jenkins-demo" -N ""
2. Add `jenkins_demo_key.pub` to the GitHub repo as a Deploy key (read-only).
3. Add `jenkins_demo_key` (private) to Jenkins as an SSH Username with private key credential.
4. Use `git@github.com:MOORTHYrm/Jenkins-build-triggers.git` as the job's repository URL.

## Expected console output
    Remote URL: git@github.com:MOORTHYrm/Jenkins-build-triggers.git
    Latest commit: <hash> <message>
    Checkout used SSH key: OK

## Notes
- Never commit the private key. Keep it outside the repo folder.
- Use one key per purpose, and delete the deploy key when the demo is done.
- If the build fails with "Host key verification failed", see Jenkins host key verification setting.
