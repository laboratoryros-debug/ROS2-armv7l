# ROS2-armv7l
Guia passo a passo para instalar e rodar ros humble em mobile com arquitetura armv7l

# Comandos

```bash
pkg update
pkg install wget proot tar -y
mkdir ~/ubuntu
cd ~/ubuntu

# Baixar rootfs Ubuntu 22.04 para armhf (32-bit ARM)
wget https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-armhf.tar.gz

# Extrair com proot que suporta hard links
proot --link2symlink tar -xzf ubuntu-base-22.04-base-armhf.tar.gz

chmod + start-ubuntu.sh

./start-ubuntu.sh

```

# Dentro do ubuntu

``` bash
# Configurar PATH temporariamente
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Tornar PATH permanente (use /root/ diretamente)
echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> /root/.bashrc

# Adicionar os grupos faltantes ao /etc/group não interfere no funcionamento, mas evita mensagem de warning no console.
echo "aid_net_bt_admin:x:3003:" >> /etc/group
echo "aid_everybody:x:9997:" >> /etc/group  
echo "aid_u0_a126:x:20126:" >> /etc/group
echo "aid_u0_a126_cache:x:50126:" >> /etc/group

# 1. Configurar DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf


apt update

```

# Caso queira istalação automática do ubuntu pode usar

```
git clone https://github.com/SEU_USUARIO/ROS2-armv7l.git && chmod +x ROS2-armv7l/install-ubuntu.sh && ./ROS2-armv7l/install-ubuntu.sh
```