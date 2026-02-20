# Auto deployment of Raspberry Pi OS

## SUMMARY

Zsh script for macOS to make SSD of Raspberry Pi OS and setting initial configuration at one time.

## REQIORED TOOLS

### ansible

Excelent toolset for configuring Pi devices remotely.

## Configuration files

There are 3 configuration files required in the same folder with this script.

### user-data

Configuration file for Raspberry Pi OS.

SAMPLE:

```YAML
#cloud-config
manage_resolv_conf: false
hostname: YOUR-HOST-NAME
manage_etc_hosts: true
packages:
- avahi-daemon
apt:
  preserve_sources_list: true
  conf: |
    Acquire {
      Check-Date "false";
    };
timezone: Asia/Tokyo
keyboard:
  model: pc105
  layout: "us"
users:
  - name: YOUR-USER-NAME
    passwd: "$6$rounds=4096$salt$hashedpassword" # or 'password'
    groups: users,adm,dialout,audio,netdev,video,plugdev,cdrom,games,input,gpio,spi,i2c,render,sudo
    shell: /bin/bash
    lock_passwd: false
    sudo: ALL(ALL) NOPASSWD:ALL
chpasswd:
  list: |
    YOUR-USER-NAME:YOUR-PASSWORD
  expire: False
enable_ssh: true
ssh_pwauth: true
pri:
  interfaces:
    serial: true
```

### network-config

Configuration file for Rspberry Pi OS.

SAMPLE:

```YAML
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
  wifis:
    wlan0:
      dhcp4: true
      regulatory-domain: "JP"
      access-points:
        "YOUR_SSID":
          password: "YOUR-PASSKEY"
      optional: true
```

### inventory.ini

Device lists for ansible.

SAMPLE:

```ini
[rpis]
herios ansible_host=xxx.xxx.xxx.xxx ansible_user=your_user_name
```

## Todo

- Auto identification of the latest pi OS image from official site.
- Add task scripts for ansible.
- OS image selection dialog.
- Update function for after configuration.
- Backup/Restore image functions.
