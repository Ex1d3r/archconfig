# Exider Linux Setup Guide

This guide explains how to set up an Arch Linux environment identical to **Exider’s configuration**.

---

## 📦 Step 1 — Install Required Packages

### Install packages from the official Arch repositories

```bash
sudo pacman -S wofi kitty freetype2 zsh git hyprlock hyprpaper waybar \
ttf-font-awesome otf-font-awesome ttf-jetbrains-mono obsidian pavucontrol \
feh ranger thunar meson nwg-look papirus-icon-theme fastfetch file \
powerline-fonts inetutils neovim code ttf-dejavu bluez bluez-utils \
blueman telegram-desktop vlc fastfetch bitwarden firefox discord
```

### Install yay (AUR helper)

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### Install AUR packages

```bash
yay -S hyprshot wlogout
```

---

## 🎨 Step 2 — Install Theme & Fan Scriptspts

### Install Graphite GTK theme

```bash
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
cd Graphite-gtk-theme
./install.sh
```

### Copy fan control scripts

```bash
sudo cp thinkpad-fan.sh /usr/local/bin/
sudo cp waybar-fan.sh /usr/local/bin/

sudo chmod +x /usr/local/bin/thinkpad-fan.sh
sudo chmod +x /usr/local/bin/waybar-fan.sh
```

---

## 🛠 Step 2.1 — Create Systemd Servicesces

### thinkpad-fan.service

```bash
sudo nano /etc/systemd/system/thinkpad-fan.service
```

Paste:

```ini
[Unit]
Description=ThinkPad Fan Controller Script
After=multi-user.target

[Service]
ExecStart=/usr/local/bin/thinkpad-fan.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

### waybar-fan.service

```bash
sudo nano /etc/systemd/system/waybar-fan.service
```

Paste:

```ini
[Unit]
Description=Waybar Fan Monitor Script
After=multi-user.target

[Service]
ExecStart=/usr/local/bin/waybar-fan.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

### Enable both services

```bash
sudo systemctl enable --now thinkpad-fan.service
sudo systemctl enable --now waybar-fan.service
```

---

## 🧩 Step 3 — Install Exider's Configsigs

Clone the config repository:

```bash
git clone https://github.com/Ex1d3r/archconfig
```

Move configs to `~/.config`:

```bash
cp -r <repo-folder>/* ~/.config/
```

---

## ✔ Done!ne!

You now have Exider's Linux environment fully installed and configured.

---



