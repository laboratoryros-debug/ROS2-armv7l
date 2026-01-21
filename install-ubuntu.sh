#!/data/data/com.termux/files/usr/bin/bash

# Script de instalação automática do Ubuntu 22.04 no Termux
# Arquitetura: armv7l (ARM 32-bit)

set -e

echo "========================================="
echo "Instalador Ubuntu 22.04 para Termux"
echo "Arquitetura: armv7l"
echo "========================================="
echo ""

# Verificar arquitetura
ARCH=$(uname -m)
if [ "$ARCH" != "armv7l" ]; then
    echo "AVISO: Arquitetura detectada: $ARCH"
    echo "Este script foi feito para armv7l"
    read -p "Deseja continuar mesmo assim? (s/n): " confirm
    if [ "$confirm" != "s" ]; then
        exit 1
    fi
fi

# Atualizar Termux
echo "[1/7] Atualizando Termux..."
pkg update -y
pkg upgrade -y

# Instalar dependências
echo "[2/7] Instalando dependências..."
pkg install wget proot tar -y

# Criar diretório
echo "[3/7] Criando diretório..."
mkdir -p ~/ubuntu
cd ~/ubuntu

# Baixar rootfs se ainda não existir
TARBALL="ubuntu-base-22.04-base-armhf.tar.gz"
if [ ! -f "$TARBALL" ]; then
    echo "[4/7] Baixando Ubuntu 22.04 rootfs (pode demorar)..."
    wget https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-armhf.tar.gz
else
    echo "[4/7] Rootfs já existe, pulando download..."
fi

# Verificar se já foi extraído
if [ ! -d "bin" ] || [ ! -d "usr" ]; then
    echo "[5/7] Extraindo rootfs (pode demorar)..."
    proot --link2symlink tar -xzf $TARBALL 2>&1 | grep -v "Cannot hard link" || true
else
    echo "[5/7] Rootfs já extraído, pulando..."
fi

# Copiar start-ubuntu.sh do repositório se existir, senão criar
echo "[6/7] Configurando script de inicialização..."
if [ -f "../ROS2-armv7l/start-ubuntu.sh" ]; then
    echo "Copiando start-ubuntu.sh do repositório..."
    cp ../ROS2-armv7l/start-ubuntu.sh ./start-ubuntu.sh
    chmod +x start-ubuntu.sh
else
    echo "start-ubuntu.sh não encontrado no repo, criando padrão..."
    cat > start-ubuntu.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD

UBUNTU_PATH="$HOME/ubuntu"

proot --link2symlink -0 -r ~/ubuntu -b /dev -b /proc -b /sys -w /root /bin/bash -c "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; exec /bin/bash --login"
EOF
    chmod +x start-ubuntu.sh
fi

# Criar script de configuração inicial do Ubuntu
echo "[7/7] Criando script de configuração inicial..."
cat > setup-ubuntu.sh << 'SETUPEOF'
#!/bin/bash
# Script de configuração inicial do Ubuntu
# Execute este script DENTRO do Ubuntu após o primeiro login

echo "Configurando Ubuntu..."

# Configurar PATH permanentemente
echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> /root/.bashrc

# Adicionar grupos para evitar warnings
echo "aid_net_bt_admin:x:3003:" >> /etc/group
echo "aid_everybody:x:9997:" >> /etc/group  
echo "aid_u0_a126:x:20126:" >> /etc/group
echo "aid_u0_a126_cache:x:50126:" >> /etc/group

# Configurar DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Atualizar repositórios
echo "Atualizando repositórios..."
apt update

echo ""
echo "Configuração inicial concluída!"
echo "Execute: source /root/.bashrc"
echo "Depois: apt install -y sudo nano wget curl"
SETUPEOF

chmod +x setup-ubuntu.sh

# Criar alias no Termux
echo ""
echo "========================================="
echo "Instalação concluída!"
echo "========================================="
echo ""
echo "Para iniciar o Ubuntu, execute:"
echo "  cd ~/ubuntu && ./start-ubuntu.sh"
echo ""
echo "Ou crie um alias (recomendado):"
echo "  echo \"alias ubuntu='cd ~/ubuntu && ./start-ubuntu.sh'\" >> ~/.bashrc"
echo "  source ~/.bashrc"
echo "  ubuntu"
echo ""
echo "Após entrar no Ubuntu pela primeira vez, execute:"
echo "  bash /setup-ubuntu.sh"
echo ""
echo "========================================="