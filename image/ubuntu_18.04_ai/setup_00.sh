#!/bin/bash

# Required OS: Ubuntu 18.04 LTS
# Requires the following packages to be downloaded from Nvidia's website and placed in /mnt/nvidia
# - nccl-repo-ubuntu1804-2.7.8-ga-cuda11.0_1-1_amd64.deb
#   - https://developer.nvidia.com/compute/machine-learning/nccl/secure/v2.7/prod/nccl-repo-ubuntu1804-2.7.8-ga-cuda11.0_1-1_amd64.deb

sudo apt-get update
sudo apt install build-essential -y

### Disable network for cloud init
echo network: {config: disabled} | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo bash -c "cat > /etc/netplan/50-cloud-init.yaml" <<'EOF'
network:
    ethernets:
        eth0:
            dhcp4: true
    version: 2
EOF

### Place the topology file in /opt/msft
sudo mkdir -p /opt/msft
sudo bash -c "cat > /opt/msft/topo.xml" <<'EOF'
<system version="1">
  <cpu numaid="0" affinity="0000ffff,0000ffff" arch="x86_64" vendor="AuthenticAMD" familyid="143" modelid="49">
    <pci busid="ffff:ff:01.0" class="0x060400" link_speed="16 GT/s" link_width="16">
      <pci busid="0001:00:00.0" class="0x030200" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0101:00:00.0" class="0x020700" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0002:00:00.0" class="0x030200" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0102:00:00.0" class="0x020700" link_speed="16 GT/s" link_width="16"/>
    </pci>
    <pci busid="ffff:ff:02.0" class="0x060400" link_speed="16 GT/s" link_width="16">
      <pci busid="0003:00:00.0" class="0x030200" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0103:00:00.0" class="0x020700" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0004:00:00.0" class="0x030200" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0104:00:00.0" class="0x020700" link_speed="16 GT/s" link_width="16"/>
    </pci>
      <pci busid="ffff:ff:03.0" class="0x060400" link_speed="16 GT/s" link_width="16">
      <pci busid="000b:00:00.0" class="0x030200" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0105:00:00.0" class="0x020700" link_speed="16 GT/s" link_width="16"/>
      <pci busid="000c:00:00.0" class="0x030200" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0106:00:00.0" class="0x020700" link_speed="16 GT/s" link_width="16"/>
    </pci>
    <pci busid="ffff:ff:04.0" class="0x060400" link_speed="16 GT/s" link_width="16">
      <pci busid="000d:00:00.0" class="0x030200" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0107:00:00.0" class="0x020700" link_speed="16 GT/s" link_width="16"/>
      <pci busid="000e:00:00.0" class="0x030200" link_speed="16 GT/s" link_width="16"/>
      <pci busid="0108:00:00.0" class="0x020700" link_speed="16 GT/s" link_width="16"/>
    </pci>
  </cpu>
</system>
EOF

# Get the kernel patch
sudo chmod 777 /mnt
cd /mnt
wget https://github.com/longlimsft/shared-binary/raw/master/linux-headers-5.4.73-revert-pci_5.4.73-revert-pci-1_amd64.deb
wget https://github.com/longlimsft/shared-binary/raw/master/linux-image-5.4.73-revert-pci_5.4.73-revert-pci-1_amd64.deb
sudo dpkg -i linux-headers-5.4.73-revert-pci_5.4.73-revert-pci-1_amd64.deb
sudo dpkg -i linux-image-5.4.73-revert-pci_5.4.73-revert-pci-1_amd64.deb

sudo reboot
