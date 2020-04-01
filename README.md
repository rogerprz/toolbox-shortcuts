# shortcuts
enable to turn on/off features in ADO
`document.cookie = "features-dev-mode=true;path=/"`


# Git

### Remove cached tracked files
* `git rm -r --cached .`
* Replace `.` with a specific file name if you want to untrack only a specific file or folder.

### Reset git
* `git reset`

## Quick shortcuts 

* (Git log cheatsheet)[https://devhints.io/git-log]

# Windows

## SSH Keys
* See output `cat ~/.ssh/id_rsa.pub`
* Copy `clip < ~/.ssh/id_rsa.pub`

## Terminate local host

### Kill process port
1. netstat -aon | findstr 8080
2. Look for listen `TCP 0.0.0.0:8080 0.0.0.0:0 LISTEN 77777`
3. `taskkill /f /pid` 77777


# Macbook

### SSH Keys
* `pbcopy < ~/.ssh/id_rsa.pub`
