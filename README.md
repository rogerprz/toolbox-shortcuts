# shortcuts
enable to turn on/off features in ADO
`document.cookie = "features-dev-mode=true;path=/"`


## Git

- [.gitconfig](./gitconfig-template) template
- [Useful commands](./gitCommands.md) 

### Review local git config and edit

- `--local`: This option specifies that you want to edit the local configuration file for the current Git repository. The local configuration is specific to a particular repository and is stored in the .git/config file within that repository.
- `-e`: This option opens the configuration file in the default text editor. It stands for "edit."
```
git config --local -e
```

### Git Remote Origin 

command : `git config --get remote.origin.url` gets remote origin url

Output 
```
https://github.com/rogerprz/toolbox-shortcuts.git
```
command: `git remote show origin` shows the remote origin url in detail

Output: 
```

remote origin
  Fetch URL: https://github.com/rogerprz/toolbox-shortcuts.git
  Push  URL: https://github.com/rogerprz/toolbox-shortcuts.git
  HEAD branch: master
  Remote branch:
    master tracked
  Local branch configured for 'git pull':
    master merges with remote master
  Local ref configured for 'git push':
    master pushes to master (up to date)
```

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



