WORKDIR=/opt/ufo_lab/

NETRIS_SIMULATOR_DIR=${WORKDIR}/netris-simulator
export DEBIAN_FRONTEND=noninteractive
export PIP_BREAK_SYSTEM_PACKAGES=1

apt update && apt install -y python3-pip

pip3 install ansible

mkdir -p ${WORKDIR}

if [[ ! -d $NETRIS_SIMULATOR_DIR ]]; then
    git clone https://github.com/jumpojoy/netris-simulator $NETRIS_SIMULATOR_DIR
fi

CUMULUS_NEW_PASSWORD=$(date +%s | sha256sum | base64 | head -c 15)
NETRIS_ADMIN_PASSWORD=$(date +%s | sha256sum | base64 | head -c 15)
REDFISH_PASSWORD=$(date +%s | sha256sum | base64 | head -c 15)
CTL_PUBLIC_IP=$(ip route get 4.2.2.1 | awk '{print $7}' |tr -d "\n")

sed -i "s/<CUMULUS_NEW_PASSWORD>/${CUMULUS_NEW_PASSWORD}/g" ${NETRIS_SIMULATOR_DIR}/inventory.yml
sed -i "s/<NETRIS_ADMIN_PASSWORD>/${NETRIS_ADMIN_PASSWORD}/g" ${NETRIS_SIMULATOR_DIR}/inventory.yml
sed -i "s/<REDFISH_PASSWORD>/${REDFISH_PASSWORD}/g" ${NETRIS_SIMULATOR_DIR}/inventory.yml
sed -i "s/<CTL_PUBLIC_IP>/${CTL_PUBLIC_IP}/g" ${NETRIS_SIMULATOR_DIR}/inventory.yml


# TODO: fix ugly hack
ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/k0s.yml || /bin/true
sleep 30
rm -rf /root/.kube/config

ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/libvirt.yml
ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/k0s.yml || /bin/true
ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/ipa.yml
ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/lvp.yml
ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/metallb.yml
ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/netris-controller.yml
ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/netris-operator.yml
#ansible-playbook -i ${NETRIS_SIMULATOR_DIR}/inventory.yml ${NETRIS_SIMULATOR_DIR}/ufo.yml
