#!/bin/bash

# Define VM names and IPs
declare -A vms
vms=(
  ["postgres-vm"]="192.168.56.10"
  ["spring-vm"]="192.168.56.4"
  ["angular-vm"]="192.168.56.16"
)

# SSH config file path
SSH_CONFIG="$HOME/.ssh/config"

# Backup old SSH config
cp "$SSH_CONFIG" "$SSH_CONFIG.bak.$(date +%s)" 2>/dev/null

# Loop over each VM
for vm in "${!vms[@]}"; do
  vm_path="$HOME/$vm"
  ip="${vms[$vm]}"

  echo "Creating $vm_path..."
  mkdir -p "$vm_path"
  cd "$vm_path" || exit

  # Initialize Vagrant
  vagrant init generic/ubuntu2204 > /dev/null

  # Add private network IP line after the first config.vm.* line
  sed -i "/^.*config.vm.box.*$/a\  config.vm.network \"private_network\", ip: \"$ip\"" Vagrantfile

  # Bring up the VM to ensure SSH is available
  echo "Bringing up $vm..."
  vagrant up --provider virtualbox

  # Append SSH config for this VM
  echo "Writing SSH config for $vm..."
  vagrant ssh-config | sed "s/Host default/Host $vm/" >> "$SSH_CONFIG"
  echo "" >> "$SSH_CONFIG"  # Add spacing between entries
done

echo "All VMs created and SSH config generated."
