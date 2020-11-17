# shortcuts
enable to turn on/off features in ADO
`document.cookie = "features-dev-mode=true;path=/"`


# Git

### Cloning a repo

* 

### Remove cached tracked files
* `git rm -r --cached .`
* Replace `.` with a specific file name if you want to untrack only a specific file or folder.

### Reset git
* `git reset`

## Quick shortcuts 

* [Git log cheatsheet](https://devhints.io/git-log)


## SSH Keys

* See output `cat ~/.ssh/id_rsa.pub`

### Windows
* Copy `clip < ~/.ssh/id_rsa.pub`

### Macbook
* `pbcopy < ~/.ssh/id_rsa.pub`


## Terminate local host
### Windows

### Kill process port
1. netstat -aon | findstr 8080
2. Look for listen `TCP 0.0.0.0:8080 0.0.0.0:0 LISTEN 77777`
3. `taskkill /f /pid` 77777



