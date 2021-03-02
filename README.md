# shortcuts
enable to turn on/off features in ADO
`document.cookie = "features-dev-mode=true;path=/"`


# Git

- [.gitconfig](./gitconfig-template) template

### Cloning a repo
1. Open Terminal 
1. Make new directory `mkdir` (note that you may not need to create a new directory depending on the project)
1. Navigate to newly created directory `cd`
1. Paste https copied from GitHub `git clone <git-url>`
1. See list of copied items `ls`
1. Open item in VS code `code .`

### Pushing a Commit
1. In Terminal `git status`
    * shows the current status w/in the repo
1. `git add .`
    * command adds ALL tracked and untracked files to a commit
    * Alternate: `git add <file name>` add single file 
1. `git commit -m " add message here"` add a note to the file when uploaded
1. `git push` command pushes changes to original repo (wherever orginal doc was cloned)  

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



