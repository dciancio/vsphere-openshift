#!/usr/bin/env bash

source 0_init_vars

cat >${TF_VAR_cluster_id}.conf <<EOF
\$ORIGIN apps.${TF_VAR_cluster_id}.${TF_VAR_base_domain}.
EOF

for i in $(echo ${TF_VAR_infra_ips} | tr -d '[",]'); do 
  echo "* A $i" >>${TF_VAR_cluster_id}.conf
done

cat >>$TF_VAR_cluster_id.conf <<EOF

\$ORIGIN ${TF_VAR_cluster_id}.${TF_VAR_base_domain}.
EOF

for i in $(seq 1 ${TF_VAR_master_count}); do
  COUNT=$(($i - 1))
  echo "_etcd-server-ssl._tcp SRV 0 10 2380 etcd-${COUNT}" >>${TF_VAR_cluster_id}.conf
done

echo "${TF_VAR_bastion_prefix}-0 A ${TF_VAR_bastion_ip}" >>${TF_VAR_cluster_id}.conf

COUNT=0
for i in $(echo ${TF_VAR_master_ips} | tr -d '[",]'); do
  echo "${TF_VAR_master_prefix}-${COUNT} A $i" >>${TF_VAR_cluster_id}.conf
  COUNT=$(($COUNT + 1))
done

for i in $(echo ${TF_VAR_master_ips} | tr -d '[",]'); do
  echo "${TF_VAR_api_prefix} A $i" >>${TF_VAR_cluster_id}.conf
done

for i in $(echo ${TF_VAR_master_ips} | tr -d '[",]'); do
  echo "${TF_VAR_api_prefix}-int A $i" >>${TF_VAR_cluster_id}.conf
done

COUNT=0
for i in $(echo ${TF_VAR_master_ips} | tr -d '[",]'); do
  echo "etcd-${COUNT} A $i" >>${TF_VAR_cluster_id}.conf
  COUNT=$(($COUNT + 1))
done

COUNT=0
for i in $(echo ${TF_VAR_worker_ips} | tr -d '[",]'); do
  echo "${TF_VAR_worker_prefix}-${COUNT} A $i" >>${TF_VAR_cluster_id}.conf
  COUNT=$(($COUNT + 1))
done

COUNT=0
for i in $(echo ${TF_VAR_infra_ips} | tr -d '[",]'); do
  echo "${TF_VAR_infra_prefix}-${COUNT} A $i" >>${TF_VAR_cluster_id}.conf
  COUNT=$(($COUNT + 1))
done

echo >>${TF_VAR_cluster_id}.conf

systemctl status named >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "WARNING:  DNS (named) service is not running on this system.  Zone file (${TF_VAR_cluster_id}.conf) has been generated in the current directory.  You will need to copy this file to your DNS (named) server manually and activate it using \"\$INCLUDE /var/named/${TF_VAR_cluster_id}.conf\" directly in the base domain zone file (${NAMED_ZONE}) found in the /var/named directory." >&2
  exit 1
fi

DNS_CONFIG_CHANGED="N"
diff ${TF_VAR_cluster_id}.conf /var/named/${TF_VAR_cluster_id}.conf >/dev/null
if [ $? -ne 0 ]; then
  [ -f /var/named/${TF_VAR_cluster_id}.conf ] && mv /var/named/${TF_VAR_cluster_id}.conf /var/named/${TF_VAR_cluster_id}.conf.bak
  cp ${TF_VAR_cluster_id}.conf /var/named/${TF_VAR_cluster_id}.conf
  DNS_CONFIG_CHANGED="Y"
fi

NUM=$(awk '/serial number/ {print $1}' /var/named/${NAMED_ZONE})
grep "^\$INCLUDE ./${TF_VAR_cluster_id}.conf" /var/named/${NAMED_ZONE} >/dev/null
if [ $? -ne 0 ]; then
  cp /var/named/${NAMED_ZONE} /var/named/${NAMED_ZONE}.bak.${NUM}
  echo "\$INCLUDE ./${TF_VAR_cluster_id}.conf" >>/var/named/${NAMED_ZONE}
  DNS_CONFIG_CHANGED="Y"
fi

if [ "$DNS_CONFIG_CHANGED" = "Y" ]; then
  cp /var/named/${NAMED_ZONE} /var/named/${NAMED_ZONE}.bak1.${NUM}
  NUM=$(($NUM + 1))
  sed -i -e "s/^\([[:space:]]\)\(.*\)\([[:space:]]\); serial number/                                ${NUM}      ; serial number/" /var/named/${NAMED_ZONE}
  systemctl restart named
fi

rm -f ${TF_VAR_cluster_id}.conf

