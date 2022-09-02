# Win10 Launcher Script

A script that start (stop) a virtual machine via `virsh` and launch `virt-viewer` and few related files. All of them are designed to fit to my particular case. Here are:

* Wiki: [QEMU/KVM on AMD Ryzen 9 Desktop with Dual-boot and Passthrough](https://wiki.metalevel.tech/wiki/QEMU/KVM_on_AMD_Ryzen_9_Desktop_with_Dual-boot_and_Passthrough)
* Vide: [Configuration of the manipulated virtual machines](https://vimeo.com/745733269)

## Functions of the script
Currently it manages two virtual machines that uses the same SATA controller and physical SSD.

```bash
win10.virt.launcher.sh start|start-pt|stop|deploy|backup
```

* `start` - starts VM named `Win10` and launch `virt-viewer`,
* `start-pt` - starts VM named `Win10PT` and 20 seconds later launch `remmina`,
* `stop` - stops both virtual machines,
* `deploy` - copy the .desktop files to `~/Desktop/` and `~/.local/share/applications/`, and symlink the script to `~/.local/bin`.
* `backup` - dump the xml configuration of the both virtual machines.

## Notes

* The path `~/.local/bin/` must be added to your `$PATH` environment variable. Usually this is done by a code like below in your run command file (.zshrc, .profile or .bashrc, etc.).

    ```bash
    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/.local/bin" ] ; then
        PATH="$HOME/.local/bin:$PATH"
    fi
    ```

* The command `update-icon-caches ~/.local/share/icons/*` may not take effect immediately, you may need to execute is for yourself.