#!/usr/bin/env bash
# Download geoserver extensions and other resources


function create_dir() {
DATA_PATH=$1

if [[ ! -d ${DATA_PATH} ]];
then
    echo "Creating" ${DATA_PATH}  "directory"
    mkdir -p ${DATA_PATH}
else
    echo ${DATA_PATH} "exists - skipping creation"
fi
}

resources_dir="/tmp/resources"
create_dir ${FOOTPRINTS_DATA_DIR}
create_dir ${resources_dir}
pushd ${resources_dir}


create_dir /plugins

pushd /plugins
#Extensions
# Download all other plugins to keep for activating using env variables
cp /tmp/stable_plugins.txt .

for plugin in `cat stable_plugins.txt`;do
  url="${STABLE_PLUGIN_URL}/geoserver-${GS_VERSION}-${plugin}.zip"
  if curl --output /dev/null --silent --head --fail "${url}"; then
      echo "URL exists: ${url}"
      wget --progress=bar:force:noscroll -c --no-check-certificate "${url}" -O ${plugin}.zip
    else
      echo "URL does not exist: ${url}"
  fi
done

# Download community modules

create_dir /community_plugins
pushd /community_plugins

cp /tmp/community_plugins.txt .

for plugin in `cat community_plugins.txt`;do
  url="https://build.geoserver.org/geoserver/${GS_VERSION:0:5}x/community-latest/geoserver-${GS_VERSION:0:4}-SNAPSHOT-${plugin}.zip"
  if curl --output /dev/null --silent --head --fail "${url}"; then
      echo "URL exists: ${url}"
      wget --progress=bar:force:noscroll -c --no-check-certificate "${url}" -O ${plugin}.zip
    else
      echo "URL does not exist: ${url}"
  fi
done

create_dir ${resources_dir}/plugins

pushd ${resources_dir}/plugins
#Extensions

array=(geoserver-$GS_VERSION-vectortiles-plugin.zip geoserver-$GS_VERSION-wps-plugin.zip geoserver-$GS_VERSION-printing-plugin.zip \
geoserver-$GS_VERSION-libjpeg-turbo-plugin.zip geoserver-$GS_VERSION-control-flow-plugin.zip \
geoserver-$GS_VERSION-pyramid-plugin.zip geoserver-$GS_VERSION-gdal-plugin.zip )
for i in "${array[@]}"
do
    url="https://sourceforge.net/projects/geoserver/files/GeoServer/${GS_VERSION}/extensions/${i}/download"
    if curl --output /dev/null --silent --head --fail "${url}"; then
      echo "URL exists: ${url}"
      wget --progress=bar:force:noscroll -c --no-check-certificate ${url} -O /tmp/resources/plugins/${i}
    else
      echo "URL does not exist: ${url}"
    fi;
done

create_dir gdal
pushd gdal

wget --progress=bar:force:noscroll -c --no-check-certificate \
http://demo.geo-solutions.it/share/github/imageio-ext/releases/1.1.X/1.1.15/native/gdal/gdal-data.zip
popd
wget --progress=bar:force:noscroll -c --no-check-certificate \
http://demo.geo-solutions.it/share/github/imageio-ext/releases/1.1.X/1.1.29/native/gdal/linux/gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz

popd

# Install libjpeg-turbo for that specific geoserver GS_VERSION
if [[ ! -f /tmp/resources/libjpeg-turbo-official_1.5.3_amd64.deb ]]; then \
    wget --progress=bar:force:noscroll -c --no-check-certificate \
    https://sourceforge.net/projects/libjpeg-turbo/files/1.5.3/libjpeg-turbo-official_1.5.3_amd64.deb \
    -P ${resources_dir};\
    fi; \
    cd ${resources_dir} && \
    dpkg -i libjpeg-turbo-official_1.5.3_amd64.deb

pushd /tmp/

 if [[ ! -f ${resources_dir}/jai-1_1_3-lib-linux-amd64.tar.gz ]]; then \
    wget --progress=bar:force:noscroll -c --no-check-certificate \
    http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz \
    -P ${resources_dir};\
    fi; \
    if [[ ! -f ${resources_dir}/jai_imageio-1_1-lib-linux-amd64.tar.gz ]]; then \
    wget --progress=bar:force:noscroll -c --no-check-certificate \
    http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz \
    -P ${resources_dir};\
    fi; \
    mv ./resources/jai-1_1_3-lib-linux-amd64.tar.gz ./ && \
    mv ./resources/jai_imageio-1_1-lib-linux-amd64.tar.gz ./ && \
    gunzip -c jai-1_1_3-lib-linux-amd64.tar.gz | tar xf - && \
    gunzip -c jai_imageio-1_1-lib-linux-amd64.tar.gz | tar xf - && \

    mv /tmp/jai-1_1_3/lib/*.jar ${JAVA_HOME} && \
    mv /tmp/jai-1_1_3/lib/*.so ${JAVA_HOME} && \
    mv /tmp/jai_imageio-1_1/lib/*.jar ${JAVA_HOME} && \
    mv /tmp/jai_imageio-1_1/lib/*.so ${JAVA_HOME} && \
    rm /tmp/jai-1_1_3-lib-linux-amd64.tar.gz && \
    rm -r /tmp/jai-1_1_3 && \
    rm /tmp/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    rm -r /tmp/jai_imageio-1_1

pushd ${CATALINA_HOME}

# A little logic that will fetch the geoserver war zip file if it
# is not available locally in the resources dir
if [[ ! -f /tmp/resources/geoserver-${GS_VERSION}.zip ]]; then \
    if [[ "${WAR_URL}" == *\.zip ]]
    then
        destination=/tmp/resources/geoserver-${GS_VERSION}.zip
        wget --progress=bar:force:noscroll -c --no-check-certificate ${WAR_URL} -O ${destination};
        unzip /tmp/resources/geoserver-${GS_VERSION}.zip -d /tmp/geoserver
    else
        destination=/tmp/geoserver/geoserver.war
        mkdir -p /tmp/geoserver/ && \
        wget --progress=bar:force:noscroll -c --no-check-certificate ${WAR_URL} -O ${destination};
    fi;\
    fi; \
    unzip /tmp/geoserver/geoserver.war -d ${CATALINA_HOME}/webapps/geoserver \
    && cp -r ${CATALINA_HOME}/webapps/geoserver/data/user_projections ${GEOSERVER_DATA_DIR} \
    && cp -r ${CATALINA_HOME}/webapps/geoserver/data/security ${GEOSERVER_DATA_DIR} \
    && cp -r ${CATALINA_HOME}/webapps/geoserver/data ${CATALINA_HOME} \
    && rm -rf /tmp/geoserver


# A little logic that will fetch the geowebcache war zip file if it
# is not available locally in the resources dir
if [[ ! -f /tmp/resources/geowebcache-${GWC_VERSION}.zip ]]; then \
    if [[ "${GWC_WAR_URL}" == *\.zip ]]
    then
        destination=/tmp/resources/geowebcache-${GWC_VERSION}.zip
        wget --progress=bar:force:noscroll -c --no-check-certificate ${GWC_WAR_URL} -O ${destination};
        unzip /tmp/resources/geowebcache-${GWC_VERSION}.zip -d /tmp/geowebcache
    else
        destination=/tmp/geowebcache/geowebcache.war
        mkdir -p /tmp/geowebcache/ && \
        wget --progress=bar:force:noscroll -c --no-check-certificate ${GWC_WAR_URL} -O ${destination};
    fi;\
    fi; \
unzip /tmp/geowebcache/geowebcache.war -d ${CATALINA_HOME}/webapps/geowebcache 



# Install any plugin zip files in resources/plugins
if ls /tmp/resources/plugins/*.zip > /dev/null 2>&1; then \
      for p in /tmp/resources/plugins/*.zip; do \
        unzip $p -d /tmp/gs_plugin \
        && mv /tmp/gs_plugin/*.jar ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/ \
        && rm -rf /tmp/gs_plugin; \
      done; \
    fi; \
    if ls /tmp/resources/plugins/*gdal*.tar.gz > /dev/null 2>&1; then \
    mkdir /usr/local/gdal_data && mkdir /usr/local/gdal_native_libs; \
    unzip /tmp/resources/plugins/gdal/gdal-data.zip -d /usr/local/gdal_data && \
    mv /usr/local/gdal_data/gdal-data/* /usr/local/gdal_data && rm -rf /usr/local/gdal_data/gdal-data && \
    tar xzf /tmp/resources/plugins/gdal192-Ubuntu12-gcc4.6.3-x86_64.tar.gz -C /usr/local/gdal_native_libs; \
    fi;
# Install Marlin render
if [[ ! -f ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/marlin-sun-java2d.jar ]]; then \
  wget --progress=bar:force:noscroll -c --no-check-certificate \
  https://github.com/bourgesl/marlin-renderer/releases/download/v0_9_4_2_jdk9/marlin-0.9.4.2-Unsafe-OpenJDK9.jar \
  -O ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/marlin-0.9.4.2-Unsafe-OpenJDK9.jar;
fi



if [[ ! -f ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/sqljdbc.jar ]]; then \
  wget --progress=bar:force:noscroll -c --no-check-certificate \
  https://clojars.org/repo/com/microsoft/sqlserver/sqljdbc4/4.0/sqljdbc4-4.0.jar \
  -O ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/sqljdbc.jar;
fi

if [[ ! -f ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/jetty-servlets.jar ]]; then \
  wget --progress=bar:force:noscroll -c --no-check-certificate \
  https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-servlets/9.4.21.v20190926/jetty-servlets-9.4.21.v20190926.jar \
  -O ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/jetty-servlets.jar;
fi

if [[ ! -f ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/jetty-util.jar ]]; then \
  wget --progress=bar:force:noscroll -c --no-check-certificate \
  https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util/9.4.21.v20190926/jetty-util-9.4.21.v20190926.jar \
  -O ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/jetty-util.jar;
fi


# Overlay files and directories in resources/overlays if they exist
rm -f /tmp/resources/overlays/README.txt && \
    if ls /tmp/resources/overlays/* > /dev/null 2>&1; then \
      cp -rf /tmp/resources/overlays/* /; \
    fi;

# install Font files in resources/fonts if they exist
if ls /tmp/resources/fonts/*.ttf > /dev/null 2>&1; then \
      cp -rf /tmp/resources/fonts/*.ttf /usr/share/fonts/truetype/; \
	fi;

# Optionally remove Tomcat manager, docs, and examples
if [[ "${TOMCAT_EXTRAS}" =~ [Fa][Ll][Ss][Ee] ]]; then \
    rm -rf ${CATALINA_HOME}/webapps/ROOT && \
    rm -rf ${CATALINA_HOME}/webapps/docs && \
    rm -rf ${CATALINA_HOME}/webapps/examples && \
    rm -rf ${CATALINA_HOME}/webapps/host-manager && \
    rm -rf ${CATALINA_HOME}/webapps/manager; \
  fi;

# Delete resources after installation
rm -rf /tmp/resources