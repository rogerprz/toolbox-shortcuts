# shortcuts
enable to turn on/off features in ADO
`document.cookie = "features-dev-mode=true;path=/"`

# Windows

## SSH Keys
* See output `cat ~/.ssh/id_rsa.pub`
* Copy `clip < ~/.ssh/id_rsa.pub`

## Terminate local host

### Kill process port
1. netstat -aon | findstr 8080
2. Look for listen `TCP 0.0.0.0:8080 0.0.0.0:0 LISTEN 77777`
3. `taskkill /f /pid` 77777
