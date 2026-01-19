WORKDIR=/opt/ufo_lab/

NETRIS_SIMULATOR_DIR=${WORKDIR}/netris-simulator
export DEBIAN_FRONTEND=noninteractive

apt update && apt install -y python3-pip

pip3 install ansible --break-system-packages

mkdir -p ${WORKDIR}

if [[ ! -d $NETRIS_SIMULATOR_DIR ]]; then
    git clone https://github.com/jumpojoy/netris-simulator $NETRIS_SIMULATOR_DIR
fi

CUMULUS_NEW_PASSWORD=$(date +%s | sha256sum | base64 | head -c 15)
NETRIS_ADMIN_PASSWORD=$(date +%s | sha256sum | base64 | head -c 15)

sed -i "s/<CUMULUS_NEW_PASSWORD>/${CUMULUS_NEW_PASSWORD}/g" ${NETRIS_SIMULATOR_DIR}/inventory.yml
sed -i "s/<NETRIS_ADMIN_PASSWORD>/${NETRIS_ADMIN_PASSWORD}/g" ${NETRIS_SIMULATOR_DIR}/inventory.yml


ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/k0s.yml
ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/configure-sushyemulator.yml


ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/create-vms.yml
