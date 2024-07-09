# m4rcu5's dotfiles

This is a public selection of my dotfiles.

The full repository is managed by [yadm](https://github.com/TheLocehiliosan/yadm).

## Personal Notes


### Gnome Keyring (outside of Gnome)

To enable the gnome keyring, it needs to be enabled regardless of the logon manager
```
# delete current entry
pam-config -d --gnome_keyring

# re-add without filters
pam-config -a --gnome_keyring --gnome_keyring-auto_start
```
