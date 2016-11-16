#!/bin/bash
#Title : wildfly_service.sh
#Description : The script to configure Wildfly-10.1.* STANDALONE in RHEL 7.*
#Original script: https://github.com/MiguelPazo/wildfly_service

# Specify the destination location
INSTALL_DIR=/etc
WILDFLY_FULL_DIR=/etc/wildfly-10.1.0.Final
WILDFLY_DIR=$INSTALL_DIR/wildfly
         
WILDFLY_USER="wildfly"
WILDFLY_SERVICE="wildfly"
         
WILDFLY_STARTUP_TIMEOUT=240
WILDFLY_SHUTDOWN_TIMEOUT=30
         
# Creating link, user and change directory owner
echo "Creating link, user and change directory owner..."
ln -s $WILDFLY_FULL_DIR/ $WILDFLY_DIR
useradd -s /sbin/nologin $WILDFLY_USER
chown -R $WILDFLY_USER:$WILDFLY_USER $WILDFLY_DIR
chown -R $WILDFLY_USER:$WILDFLY_USER $WILDFLY_FULL_DIR

# Creating service
echo "Registering Wildfly as service..."
cp $WILDFLY_DIR/docs/contrib/scripts/init.d/wildfly-init-redhat.sh /etc/init.d/$WILDFLY_SERVICE
WILDFLY_SERVICE_CONF=/etc/default/wildfly.conf

chmod 755 /etc/init.d/$WILDFLY_SERVICE

if [ ! -z "$WILDFLY_SERVICE_CONF" ]; then
echo "Configuring service..."
echo JBOSS_HOME=\"$WILDFLY_DIR\" > $WILDFLY_SERVICE_CONF
echo JBOSS_USER=$WILDFLY_USER >> $WILDFLY_SERVICE_CONF
echo JBOSS_MODE=standalone >> $WILDFLY_SERVICE_CONF
echo JBOSS_CONFIG=standalone.xml >> $WILDFLY_SERVICE_CONF
echo STARTUP_WAIT=$WILDFLY_STARTUP_TIMEOUT >> $WILDFLY_SERVICE_CONF
echo SHUTDOWN_WAIT=$WILDFLY_SHUTDOWN_TIMEOUT >> $WILDFLY_SERVICE_CONF
fi

echo "Creating backup config files..."
cp $WILDFLY_DIR/standalone/configuration/standalone.xml $WILDFLY_DIR/standalone/configuration/standalone.xml.bk
cp $WILDFLY_DIR/bin/standalone.conf $WILDFLY_DIR/bin/standalone.conf.bk
cp $WILDFLY_DIR/standalone/configuration/mgmt-users.properties $WILDFLY_DIR/standalone/configuration/mgmt-users.properties.bk
cp $WILDFLY_DIR/standalone/configuration/application-users.properties $WILDFLY_DIR/standalone/configuration/application-users.properties.bk
cp $WILDFLY_DIR/domain/configuration/mgmt-users.properties $WILDFLY_DIR/domain/configuration/mgmt-users.properties.bk
cp $WILDFLY_DIR/domain/configuration/application-users.properties $WILDFLY_DIR/domain/configuration/application-users.properties.bk


echo "Starting Wildfly"
service $WILDFLY_SERVICE start
chkconfig --add wildfly
chkconfig --level 2345 wildfly on

echo "Done."