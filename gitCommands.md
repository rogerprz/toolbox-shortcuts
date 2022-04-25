# Git Commands

## Exclude directory in git log

```
git log -p -- . ":(exclude)name_of_folder"
# Multiple directories
git log release-2204-1.1..develop --pretty=format:'%s | %aE' --reverse ":\!./apps" ":\!./packages"
```

