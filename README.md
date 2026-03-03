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
```
sudo pacman -S os-prober ntfs-3g
```

Edit /etc/default/grub and comment or add the line:

GRUB_DISABLE_OS_PROBER=false
```
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Put system in darkmode:
```
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```

### Add function slash/question to dead key (hp440g9)
```
sudo pacman -S keyd
sudo systemctl enable --now keyd
```

Create or edit /etc/keyd/default.conf with this content:
```
[ids]
*

[main]
ro = slash
```
```
sudo keyd reload
```

### Install and configure drivers for gtx 1080 ti (eGPU)
```
# or headers equivalent
sudo pacman -S linux-zen-headers 

yay -S nvidia-580xx-dkms nvidia-580xx-utils

sudo mkinitcpio -P
```

### Configure hibernate (ext4 work and grub)
```
# 1. Create and enable swapfile (size >= RAM)
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 2. Persist in fstab
echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab

# 3. Get UUID and Offset dynamically
UUID=$(findmnt -no UUID -T /swapfile)
OFFSET=$(sudo filefrag -v /swapfile | awk '{ if($1=="0:"){print substr($4, 1, length($4)-2)} }')

# 4. Inject kernel parameters into GRUB and update
sudo sed -i "s/GRUB_CMDLINE_LINUX=\"[^\"]*/& resume=UUID=$UUID resume_offset=$OFFSET/" /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 5. Insert 'resume' hook after 'udev' in mkinitcpio and rebuild
sudo sed -i 's/udev autodetect/udev resume autodetect/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# 6. Reboot is mandatory before testing
# reboot
# systemctl hibernate
```
