#!/usr/bin/env bash
echo -e "[ + ] creating the mount point directories ..."
mkdir -p /store/nfsd0{1..5}

drives=(sda sdb sdc sdd sde)
COUNT=1

for d in "${drives[@]}"; do
    if [[ $(fdisk -l /dev/sd"{d}") ]]; then
        echo -e "[ + ] partitioning drive /dev/sd${d}"
        parted -s -a optimal /dev/"${d}" mklabel gpt mkpart primary 2048 100%

        echo -e "[ + ] formating partition /dev/sd${d}1 with xfs filesystem ..."
        mkfs.xfs -f /dev/sd"${d}"1

        echo -e "[ + ] appending /dev/sd${d}1 mount information to /etc/fstab"
        uuid=$(blkid -o value -s UUID /dev/sd"${d}"1)
        echo "UUID=${uuid} /store/nfsd0${COUNT}                  xfs    noatime        0     0" | tee -a /etc/fstab

        COUNT=$((COUNT + 1))
    fi
done

echo "[ + ] mount newly created filesystem"
mount -av

echo -e "[+] display mounted drives"
df -T
