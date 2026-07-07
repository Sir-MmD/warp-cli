# WARP-CLI Installer
![App Screenshot](https://raw.githubusercontent.com/Sir-MmD/warp-cli/refs/heads/main/logo.png)
### About
This is a simple script to install the Cloudflare WARP Linux Client (warp-cli). It uses Cloudflare's official repository: https://pkg.cloudflareclient.com

<div align="center">

| Package Manager    | CPU Type         | Status                        |
|:------------------:|:----------------:|:-----------------------------:|
| **apt**            | x86_64 / aarch64 | ✅ Cloudflare official        |
| **dnf**            | x86_64 / aarch64 | ✅ Cloudflare official        |
| **yum / microdnf** | x86_64 / aarch64 | ✅ Cloudflare official        |
| **zypper**         | x86_64 / aarch64 | ⚠️ Unofficial, may not work   |
| **pacman**         | x86_64           | ⚠️ Community (AUR)            |

</div>

> **RHEL / CentOS note:** versions 9–10 require the **EPEL** repository for
> `cloudflare-warp` dependencies. The script auto-runs `dnf install epel-release`
> (skipped on Fedora). On genuine RHEL you may still need to enable EPEL manually
> per Red Hat's instructions. Fedora needs no EPEL.

> **Arch note:** Cloudflare ships no official Arch package. The script builds the AUR
> package `cloudflare-warp-bin`, which requires an AUR helper (`yay` or `paru`) already
> installed. Because `makepkg` cannot run as root, run the script via `sudo` **from a
> normal user account** (so `$SUDO_USER` is set for the build).

> **openSUSE note:** Cloudflare's RHEL RPM installs on openSUSE but is **not properly
> configured** (service/deps), so it may not work out of the box. For a working setup,
> prefer a community OBS package (e.g. `cloudflare_warp` from the `home:MaxxedSUSE`
> repository) instead of this script's zypper path.


### Installation
```bash
sudo bash -c "$(wget https://raw.githubusercontent.com/Sir-MmD/warp-cli/main/warp-cli.sh -O -)"
```
### Uninstall
```bash
sudo bash -c "$(wget https://raw.githubusercontent.com/Sir-MmD/warp-cli/main/warp-cli.sh -O -)" -- --uninstall
```

### Note
This script sets the mode of WARP to SOCKS5. During setup it prompts for a proxy port. Press Enter to accept the default **10808**. You can also change it later with the ```warp-cli``` command.
