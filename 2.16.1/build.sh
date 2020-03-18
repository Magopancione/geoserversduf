#/bin/sh

# Create plugins folder if does not exist
if [ ! -d ./resources ]
then
    mkdir ./resources
fi

if [ ! -d ./resources/plugins ]
then
    mkdir ./resources/plugins
fi

GS_VERSION=2.16.1
GS_VERSION_EXT=2.16

# Add in selected plugins.  Comment out or modify as required
if [ ! -f resources/plugins/geoserver-control-flow-plugin.zip ]
then
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-control-flow-plugin.zip -O resources/plugins/geoserver-control-flow-plugin.zip
fi
if [ ! -f resources/plugins/geoserver-inspire-plugin.zip ]
then
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-inspire-plugin.zip -O resources/plugins/geoserver-inspire-plugin.zip
fi
if [ ! -f resources/plugins/geoserver-monitor-plugin.zip ]
then
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-monitor-plugin.zip -O resources/plugins/geoserver-monitor-plugin.zip
fi
if [ ! -f resources/plugins/geoserver-css-plugin.zip ]
then
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-css-plugin.zip -O resources/plugins/geoserver-css-plugin.zip
fi
if [ ! -f resources/plugins/geoserver-ysld-plugin.zip ]
then
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-ysld-plugin.zip -O resources/plugins/geoserver-ysld-plugin.zip
fi
#if [ ! -f resources/plugins/geoserver-gdal-plugin.zip ]
#then
#    wget -c http://netix.dl.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-gdal-plugin.zip -O resources/plugins/geoserver-gdal-plugin.zip
#fi
if [ ! -f resources/plugins/geoserver-sldservice-plugin.zip ]
then
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-sldservice-plugin.zip -O resources/plugins/geoserver-sldservice-plugin.zip
fi


#if [ ! -f resources/plugins/geoserver-sldservice-plugin.zip ]
#then
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/${GS_VERSION}/extensions/geoserver-${GS_VERSION}-sld
service-plugin.zip -O resources/plugins/geoserver-sldservice-plugin.zip
wget -c https://build.geoserver.org/geoserver/${GS_VERSION_EXT}.x/community-latest/geoserver-${GS_VERSION_EXT}-SNAPSHOT-activeMQ-broker-plugin.zip   -O resources/plugins/geoserver-SNAPSHOT-activeMQ-broker-plugin.zip 
wget -c https://build.geoserver.org/geoserver/${GS_VERSION_EXT}.x/community-latest/geoserver-${GS_VERSION_EXT}-SNAPSHOT-jms-cluster-plugin.zip -O resources/plugins/geoserver-SNAPSHOT-jms-cluster-plugin.zip
wget -c https://github.com/bourgesl/marlin-renderer/releases/download/v0_9_4_1_jdk9/marlin-0.9.4.1-Unsafe-OpenJDK9.jar  -O  resources/plugins/marlin-Unsafe-OpenJDK9.jar

#fi

#docker build --build-arg TOMCAT_EXTRAS=false -t thinkwhere/geoserver .
## Note: disabling GWC may conflict with plugins in 2.9+ that have this as a dependency
#docker build --build-arg DISABLE_GWC=true --build-arg TOMCAT_EXTRAS=false -t thinkwhere/geoserver .
