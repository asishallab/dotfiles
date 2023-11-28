# dotfiles
My personal *nix system configuration

## Gnome Terminal setup

1. Go to https://github.com/Gogh-Co/Gogh
2. Install the Nerdfonts: https://gist.github.com/matthewjberger/7dd7e079f282f8138a9dc3b045ebefa0
3. Load the preconfigured terminal config: https://askubuntu.com/questions/774394/wheres-the-gnome-terminal-config-file-located

Dump
```sh
dconf dump /org/gnome/terminal/ > ~/gterminal.preferences
```

Install
```sh
cat ~/gterminal.preferences | dconf load /org/gnome/terminal/legacy/profiles:/
```
