#!/bin/sh

CONFIG=/opt/storm/conf/storm.yaml

### zookeeper
if [ -n "${ZOOKEEPERS}" ]
then
	echo "ZooKeeper: ${ZOOKEEPERS}"
	for i in ${ZOOKEEPERS//,/ }
	do
		ZK_STR="${ZK_STR}\n    - \"${i%:*}\""
	done
	sed -i -e "s/.*\(storm\.zookeeper\.servers\):.*/\1:${ZK_STR}/g" ${CONFIG}
elif [ `env | grep -c 2181_TCP_ADDR` -gt 0 ]
then
	# get zookeeper address from env.
	for i in `env | grep 2181_TCP_ADDR | cut -d = -f 2`
	do
		ZK_STR="${ZK_STR}\n    - \"${i}\""
		ZK_STR2="${ZK_STR2},${i}:2181"
	done
	echo "ZooKeeper: ${ZK_STR2:1}"
	sed -i -e "s/.*\(storm\.zookeeper\.servers\):.*/\1:${ZK_STR}/g" ${CONFIG}
fi

sleep 10

### nimbus host
if [ -n "${NIMBUS}" ]
then
	echo "Nimbus: ${NIMBUS}"
	sed -i -e "s/.*\(nimbus\.host\):.*/\1: \"${NIMBUS}\"/g" ${CONFIG}
else
	echo "Nimbus: this container (`hostname -i`)."
	sed -i -e "s/.*\(nimbus\.host\):.*/\1: \"`hostname -i`\"/g" ${CONFIG}
fi

### local.hostname
echo "storm.local.hostname: `hostname -i`" >> ${CONFIG}

### role
if [ -n "${ROLE}" ]
then
	case ${ROLE} in
		nimbus|n)
			/opt/storm/bin/storm nimbus &
			sleep 60
			tail -f /opt/storm/logs/nimbus.log
			;;
		supervisor|s)
			/opt/storm/bin/storm supervisor &
			sleep 60
			touch /opt/storm/logs/worker-{6700,6701,6702,6703}.log
			tail -f /opt/storm/logs/supervisor.log /opt/storm/logs/worker-670*.log
			;;
		ui|u)
			/opt/storm/bin/storm ui
			;;
		*)
			echo "[ERROR] ${ROLE} not found." >&2
			exit 1
			;;
	esac
fi

exec $@
# EOF
