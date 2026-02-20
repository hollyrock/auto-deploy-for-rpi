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
hostname: YOUR_PI_NAME
manage_etc_hosts: true
users:
  - name: YOUR_USER_NAME
    passwd: "$6$rounds=4096$salt$hashedpassword"
    groups: [sudo, video, input]
    shell: /bin/bash
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB....   < YOUR SSH PUBLIC KEY

chpasswd:
  list: |
    YOUR_USER_NAME:USER_PASSWORD
  expire: False

ssh_pwauth: true

```

### network-config

Configuration file for Rspberry Pi OS.

SAMPLE:

```YAML
version: 2
ethernets:
  eth0:
    dhcp4: true
wifis:
  wlan0:
    dhcp4: true
    access-points:
      "YOUR-SSID":
        password: "YOUR-SSID-PASSWORD"
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
