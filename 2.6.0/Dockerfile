FROM ubuntu:14.04


####################
# JAVA
####################

ENV JAVA_HOME		/usr/lib/jvm/java-7-openjdk-amd64

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jdk && \
    rm -rf /var/lib/apt/lists/*



####################
# HADOOP
####################

ENV HADOOP_VERSION	2.6.0
ENV HADOOP_HOME		/usr/local/hadoop
ENV HADOOP_OPTS		-Djava.library.path=/usr/local/hadoop/lib/native
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV PATH		$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget libzip2 libsnappy1 libssl-dev && \
    wget http://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    apt-get remove -y wget && \
    rm -rf /var/lib/apt/lists/* && \
    tar -zxf /hadoop-$HADOOP_VERSION.tar.gz && \
    rm /hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION /usr/local/hadoop && \
    mkdir -p /usr/local/hadoop/logs


# Overwrite default HADOOP configuration files with our config files
COPY conf  $HADOOP_HOME/etc/hadoop/

# Formatting HDFS
RUN mkdir -p /data/dfs/data /data/dfs/name /data/dfs/namesecondary && \
    hdfs namenode -format
VOLUME /data


####################
# OOZIE
####################

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl zip perl maven && \
    curl http://archive.apache.org/dist/oozie/4.1.0/oozie-4.1.0.tar.gz -o oozie-4.1.0.tar.gz && \
    tar -zxf oozie-4.1.0.tar.gz && \
    sed -i'' -e 's/<hadoop.version>1.1.1<\/hadoop.version>/<hadoop.version>2.3.0<\/hadoop.version>/g' oozie-4.1.0/pom.xml && \
    perl -0777 -i'' -pe 's/<requireJavaVersion>(?<whitespace>[\s]*)<version>1.6<\/version>/<requireJavaVersion>$+{whitespace}<version>1.7<\/version>/g' oozie-4.1.0/pom.xml && \
    MAVEN_OPTS='-Xmx1024m -XX:MaxPermSize=128m' oozie-4.1.0/bin/mkdistro.sh -P hadoop-2 -DskipTests && \
    cp -R oozie-4.1.0/distro/target/oozie-4.1.0-distro/oozie-4.1.0 /usr/local/ && \
    mkdir /usr/local/oozie-4.1.0/libext && \
    cp -R oozie-4.1.0/hadooplibs/hadoop-2/target/hadooplibs/hadooplib-2.3.0.oozie-4.1.0/* /usr/local/oozie-4.1.0/libext/ && \
    rm -rf oozie-4.1.0* && \
    curl http://archive.cloudera.com/gplextras/misc/ext-2.2.zip -o /usr/local/oozie-4.1.0/libext/ext-2.2.zip && \
    /usr/local/oozie-4.1.0/bin/oozie-setup.sh prepare-war && \
    /usr/local/oozie-4.1.0/bin/ooziedb.sh create -sqlfile oozie.sql -run

# Add configuration file so that it points to HDFS
ADD conf/oozie-site.xml /usr/local/oozie-4.1.0/conf/oozie-site.xml

ADD start-oozie.sh /usr/local/bin/start-oozie.sh


####################
# PORTS
####################
#
# http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.3.0/bk_HDP_Reference_Guide/content/reference_chap2.html
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_ports_cdh5.html
# http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/core-default.xml
# http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml

# HDFS: NameNode (NN):
#	 8020 = fs.defaultFS			(IPC / File system metadata operations)
#						(9000 is also frequently used alternatively)
#	 8022 = dfs.namenode.servicerpc-address	(optional port used by HDFS daemons to avoid sharing RPC port)
#       50070 = dfs.namenode.http-address	(HTTP  / NN Web UI)
#	50470 = dfs.namenode.https-address	(HTTPS / Secure UI)
# HDFS: DataNode (DN):
#	50010 = dfs.datanode.address		(Data transfer)
#	50020 = dfs.datanode.ipc.address	(IPC / metadata operations)
#	50075 = dfs.datanode.http.address	(HTTP  / DN Web UI)
#	50475 = dfs.datanode.https.address	(HTTPS / Secure UI)
# HDFS: Secondary NameNode (SNN)
#	50090 = dfs.secondary.http.address	(HTTP / Checkpoint for NameNode metadata)
# HDFS: HttpFS
#   14000 = conf/httpfs-env.sh's HTTPFS_HTTP_PORT
#   14001 = conf/httpfs-env.sh's HTTPFS_ADMIN_PORT
# YARN: ResourceManager:
#    8088 = yarn.resourcemanager.webapp.address
# YARN: NodeManager:
#    8042 = yarn.nodemanager.webapp.address
# MR: JobHistoryServer:
#   19888 = mapreduce.jobhistory.webapp.address
# OOZIE: Oozie:
#   11000 = OOZIE_HTTP_PORT in oozie-env.sh
EXPOSE 9000 50070 50010 50020 50075 50090 14000 14001 8088 8042 8188 19888 11000



CMD ["hdfs"]
