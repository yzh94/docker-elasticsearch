#!/bin/bash
echo 'ls -alh --color=auto $@' > /bin/l;chmod +x /bin/l
cd /data/elk/elasticsearch

if [ "" == "$http_port" ]; then
	http_port=9200
fi


#/sbin/ifconfig |grep "addr:"
#if [ $? -eq 0 ] ; then
#        if [ "$ip_range" != "" ]; then
#                node_name=`/sbin/ifconfig |grep "inet addr"|grep "$ip_range"|grep -v docker|awk -F : '{print $2}' |awk '{print $1}'| head -n 1 `
#        else
#                node_name=`/sbin/ifconfig |grep "inet addr"|grep -v docker|awk -F : '{print $2}' |awk '{print $1}'|grep -v "^172.17.0"|grep -v "^172.19.0"|grep -v "^172.16"|grep -v "^10.244"|head -n 1 `
#        fi
#else
#        if [ "$ip_range" != "" ]; then
#                node_name=`/sbin/ifconfig |grep "inet "|grep "$ip_range"|grep -v docker|awk '{print $2}'|awk '{print $1}'|head -n 1`
#        else
#                node_name=`/sbin/ifconfig |grep "inet "|grep -v docker|awk '{print $2}'|awk '{print $1}'|grep -v "^172.17.0"|grep -v "^172.1.0"|grep -v "^172.16"|grep -v "^10.244"|head -n 1`
#        fi
#fi

node_name=`/sbin/ifconfig |grep "inet "|grep "$ip_range"|grep -v docker|awk '{print $2}'|awk '{print $1}'|head -n 1`


sed -i 's/hot/'"${node_attrs}"'/' config/elasticsearch.yml
sed -i 's/unicasthosts/'"${unicast_hosts}"'/'     config/elasticsearch.yml
sed -i 's/master.hosts/'"${master_hosts}"'/'     config/elasticsearch.yml
sed -i 's/my-application/'"${cluster_name}"'/' config/elasticsearch.yml
sed -i 's/9200/'"${http_port}"'/' config/elasticsearch.yml
sed -i 's/node-1/'"${node_name}"'/' config/elasticsearch.yml
#20200317
rm -rf /usr/java

#20180613
if [ 1 -lt "$Xms" ]; then
	sed -i 's@Xms1g@Xms'"${Xms}"'g@g' 	 config/jvm.options
fi
if [ 1 -lt "$Xmx" ]; then
	sed -i 's@Xmx1g@Xmx'"${Xmx}"'g@g' 	 config/jvm.options
fi


if [ "$uid" == "" ]; then
	uid=1015
fi
if [ -f /data/elk/elasticsearch/data/uid ]; then
	uid=`cat /data/elk/elasticsearch/data/uid`
fi
groupadd elk -g $uid
useradd elk -g $uid -u $uid
chown  elk.elk -R /home/elk /data/elk /data/supervisor/logs

#sed -i "s/^NAME=.*/NAME=${name}/g"                   /data/cardmgr/report-etcd.sh
#sed -i "s/^PORT_HTTP=.*/PORT_HTTP=${http}/g"         /data/cardmgr/report-etcd.sh
#sed -i "s/^GROUP=.*/GROUP=${group}/g"                /data/cardmgr/report-etcd.sh
#sed -i "s/{{main_program}}/cardmgr/g"                /data/cardmgr/supervisord.conf


#ls -alh /data/elk/ /data/elk/elasticsearch


cat >>/etc/security/limits.d/20-nproc.conf <<E
elk soft nproc unlimited
elk hard nproc unlimited
E
#cat >>/etc/security/limits.d/20-nproc.conf <<E
#elk soft nproc unlimited
#elk hard nproc unlimited
#E


export JAVA_HOME=/data/elk/elasticsearch/jdk

chmod 777  -R /data/elk/

ulimit -u 10240
#start script
/usr/bin/supervisord -c /data/elk/supervisord.conf
#su - elk -c "sh  /data/elk/elasticsearch/bin/start.sh" 
tail -f /data/elk/elasticsearch/bin/elasticsearch-env
