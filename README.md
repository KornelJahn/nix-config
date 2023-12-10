# Personal NixOS and Home Manager configs

Personal [NixOS][nixos] and [Home Manager][home-manager] (HM) configurations, all contained in a Nix [flake][nix-flakes]. There may be some rough edges as Nix Flakes are still considered experimental.

Highlights:

- Fully declarative configurations of multiple NixOS configurations of laptops and workstations
- Encrypted ZFS-based root file system with automatic partitioning and formatting provided by [disko][disko]
- Ephemeral dataset for `/` (through restoring a blank snapshot on boot) and opt-in persistence with help of the [impermanence][impermanence] module
- Mounted datasets nested under either `local` and `safe` parents, with only the latter group backed up (inspired by [Graham Christensen][erase-your-darlings])
- Hosts in a private mesh network using [tailscale][tailscale]
- Separate Home Manager configuration, also applicable to non-NixOS systems
- NixOS and Home Manager modules included in the Flake output and reusable by other personal flakes
- Declarative desktop environment based on Sway (Wayland)

Feel free to grab some inspiration from this repo but do not use it as a dependency. Please remember: *"You don't want my crap, you want your own."* ([dasJ][dasj-dotfiles])

## Installation

0. (Prerequisite) It is assumed that disko has already been configured for the target machine with valid by-id block device paths. Otherwise, find out persistent virtual disk block device paths of the target machine in a live Linux enviromnent by comparing `lsblk` and `ls -l /dev/disk/by-id` outputs and edit the config accordingly.

1. Boot a recent NixOS ISO image on the target machine.

   - Download the latest ISO from

        wget -O nixos.iso https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso

   - If using an USB key, my preferred method is to use [Ventoy][ventoy]. In case of a VM, simply assign the ISO to its virtual CD drive.

2. Ensure that the machine has wired or wireless network connection.

3. Enter a host-specific installer devshell of this flake as follows

        nix develop --experimental-features 'nix-command flakes' github:KornelJahn/nix-config#<hostname>

4. Store ZFS encryption passphrase and user password in advance for unattended formatting and installation:

        my-mkpass

5. Partition the disks, create the file systems, install NixOS, and reboot if successful:

        my-format && my-install && sudo reboot

That's all! :sunglasses:

## Post-install configuration

1. Activate Home Manager:

        home-manager switch --flake github:KornelJahn/nix-config

   Execute `nix profile list` before switching if `home-manager` fails with the following error message:

        Could not find suitable profile directory, [...]

2. Deploy SSH keys for users using one of the following methods:

  - Fetch existing keys.

  - Generate new keys. Include new public key in `nixos/configs/<username>.nix` and switch config. Copy public key to required non-NixOS hosts and register new public key at Github, Gitlab etc.

3. Clone this repo for development.

## Management

Below is a table of commands for common management tasks, where `FLAKE_URI` can either be a reference to the online repo (`github:KornelJahn/nix-config`) or a path to a local clone.

| Operation | Command | Own HM shell alias |
|-----------|---------|--------------------|
| Collect garbage[^1] | `nix-collect-garbage [-d]` | |
| Switch to new OS config | `sudo nixos-rebuild {switch|boot} --flake
FLAKE_URI` | `nr {switch|boot}` |
| Switch to new HM config | `sudo home-manager switch --flake FLAKE_URI` | `hm switch` |
| Check the config[^2] | `nix flake check` | |
| Format source files[^2] | `nix fmt` | |
| Update the lock file[^2] | `nix flake` | |

[^1]: The `-d` option also removes GC roots such as old system/HM configurations,
making it impossible to roll back to previous configs. Executing a `nixos-rebuild switch` is necessary to clean up boot menu entries.

[^2]: To be executed within the repo directory.

## Troubleshooting

### Installation

If you get

    error: filesystem error: cannot rename: Invalid cross-device link [...] [...]

during NixOS installation, then there is likely a different underlying error, which is unfortunately masked by this one. In such a case, try to build the system config first as

    nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

which will then reveal the root cause for the error.

### Mirrored multi-disk setups

#### Single-disk boot

If one is forced to do a single-disk boot (e.g. due to a failed second disk), it may happen that one is dropped into the UEFI shell because the default ESP is missing. In that case, available (mounted) additional spare ESPs are listed when entering the UEFI shell or can be listed using `map -r`. Additional mirrored (non-default) and mounted spare ESP file systems appear as `FSn` where `n` is an integer. Suppose our spare ESP file system is `FS0`. In this case, all you need to do is to change to that file system and find & launch the corresponding EFI executable of the OS (say, `BOOTX64.EFI`) as

    FS0:
    cd EFI/BOOT
    BOOTX64.EFI

If on subsequent reboots, the EFI shell keeps coming up, it is worth examining the boot order inside the EFI shell using

    bcfg boot dump -s

and -- if necessary -- move some entries around specifying their actual number and the target number, e.g.

    bcfg boot mv 02 04

Credits: https://www.youtube.com/watch?v=t_7gBLUa600

#### Partial partitioning and formatting

The disko configuration of this flake is composed in a way that it is possible to partition and format a subset of disks only, e.g., when replacing a failed disk or adding additional disks later to create a new mirrored ZFS pool.

Accordingly, inside the installer shell `my-format` can be run as

    my-format -d '[ "disk1" ]'

for partitioning of a single disk `disk1` only, or as

    my-format -d '[ "disk3" "disk4" ]' -p '[ "dpool" ]'

for the creation of a new zpool `dpool` for newly added disks `disk3` and `disk4`, which have been introduced previously to the disko config.

The values of options `-d` and `-p` must be valid (quoted) Nix expressions, lists of strings (names of disks and ZFS pools in the disko config, respectively).

## To-do list

- For increased consistency, when activating HM, switch to `nix run` the utility from the `home-manager` input (?)
- Configure LSP-based completion in NeoVim
- Configure MIME types in shell and Midnight Commander (mc)
- Configure Actions Menu in mc
- Configure Directory Hotlist in mc
- Make dircolors and mc colors consistent

## Acknowledgements

Special thanks to Dávid Wágner and András Olasz for fruitful discussions.

Some parts of this flake were inspired by:

- Dávid Wágner's [homelab][wagdav-homelab];
- Gabriel Fontes' [nix-config][misterio77-nix-config].
- Henrik Lissner's [dotfiles][hlissner-dotfiles];

This flake stands on the shoulders of other flake-giants, explicitly referenced in the `inputs` attribute set of `flake.nix`.

[nixos]: https://nixos.org
[nix-flakes]: https://nixos.wiki/wiki/Flakes
[erase-your-darlings]: https://grahamc.com/blog/erase-your-darlings/
[nixos-on-arm]: https://nixos.wiki/wiki/NixOS_on_ARM
[disko]: https://github.com/nix-community/disko
[home-manager]: https://github.com/nix-community/home-manager
[impermanence]: https://github.com/nix-community/impermanence
[tailscale]: https://tailscale.com
[ventoy]: https://www.ventoy.net
[wagdav-homelab]: https://github.com/wagdav/homelab
[the-wagner-net]: https://thewagner.net/
[dasj-dotfiles]: https://github.com/dasj/dotfiles
[misterio77-nix-config]: https://github.com/Misterio77/nix-config
[hlissner-dotfiles]: https://github.com/hlissner/dotfiles
