Use GitHub Actions to build Arch packages.
For more information, please read [my post](https://viflythink.com/Use_GitHubActions_to_build_AUR/) (Chinese).

# Usage

Add the following code snippet to your `/etc/pacman.conf`:

```
[vifly]
Server = https://github.com/vifly/arch-build/releases/latest/download
```

And import my pubkey:

```Bash
wget -O /tmp/vifly-repo.key 'https://share.viflythink.com/arch-repo.key' && sudo pacman-key --add /tmp/vifly-repo.key
sudo pacman-key --lsign-key viflythink@gmail.com
```

Then, run `sudo pacman -Syu` to update the repository and upgrade the system.

Now you can use `sudo pacman -S <pkg_name>` to install packages from my repository.

# TODO
- [ ] some actions are too coupled, need to refactor
- [ ] add more clear output log for debug
- [x] remove OneDrive functionality and create repository directly in releases
