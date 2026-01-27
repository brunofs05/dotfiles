### If i don't remember: 
### In a new station (formatted):

```
cd
git init
git remote add origin <code-ssh>
git fetch
git checkout -f master
```

### If i will use dual-boot linux/windows + grub:

sudo pacman -S os-prober ntfs-3g

Edit /etc/default/grub and comment or add the line:

GRUB_DISABLE_OS_PROBER=false

```
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
