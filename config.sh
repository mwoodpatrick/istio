#################################################################################
# MANDATORY SETTINGS for some components. You need to customize these settings #
#################################################################################
#                                                                               #
# In some cases you see two options for the same variable, one of them in       #
# comments. You can always define the value directly in this file, but in some  #
# cases it is better to use an external file, best outside of the scope of a    #
# source control system such as git, so that you don't accidentally put secrets #
# into public places.                                                           #
#                                                                               #
#################################################################################

#
# FEATURE FLAGS: 
# You can enable services that need configuration, Grafana-Cloud and Slack,
# or services that are optional, like Goldilock. External environment settings 
# overwrite configuration here. 
# If you change a config here, it is recommended to restart the cluster with ./start.sh
# to have everything aligned as there are some dependencies (unless you know what you are doing :-))
#
export SLACK_ENABLE="no"
export GRAFANA_CLOUD_ENABLE="no"
export GOLDILOCKS_ENABLE="no"
export NGINX_ENABLE="yes"
export KUBERNETES_DASHBOARD_ENABLE="yes"
export ISTIO_ENABLE="no"
export KEDA_ENABLE="no"
export HPA_ENABLE="no"

#
# You can enable patching resource settings for objects that don't offer this per values.yaml or other means
#
export RESOURCEPATCH="no"
#export RESOURCEPATCH="yes"

#
# Projecthome: the environment variable PROJECTHOME must be set to the directory where this config.sh file is located.
if [ -z ${PROJECTHOME} ]; then
  echo "Please set the PROJECTHOME environment variable to the directory where the config file is."
  echo "use: export PROJECTHOME=/home/user/whereever"
  exit 1
fi

#
# SLACK
#
# SLACKWEBHOOK this is a URL like this: https://hooks.slack.com/services/DFE$$RFSFSZ/FSFRGRGRRQ/afsdfsjisjfijgsjdsfjfooj
# create one via https://api.slack.com/apps  (create new app and generate a webhook URL)
# You can insert the webhook value directly, but this may expose the secret to source control. A simple way to
# avoid this is to enter the values to a file external to the source control, as shown in the second line below. 
#
#export SLACKWEBHOOK="YOUR-WEBHOOK-URL-HERE"
export SLACKWEBHOOK=$(cat ${PROJECTHOME}/../.slack/SLACKWEBHOOK.url)

#
# Grafana Cloud settings. You need to pickup six details from your Grafana Cloud Portal: a numeric username 
#                         for Loki, a URL for Loki, a numeric user name for Prometheus, a organization 
#                         name and a API Key for "metric publisher" or better. Enter those either in this 
#                         config.sh file or (better?) store them externally and read dynamically. 
# 
export GRAFANA_CLOUD_ORG="YOURORGNAME"  # this is the grafana cloud organization that you created
export GRAFANA_CLOUD_METRICS_PUBLISHER_PASS="YOUR METRICS PUBLISHER API KEY"  # generated by Grafana Cloud Portal
export GRAFANA_CLOUD_INSTANCE_KEY="YOUR GRAFAN-CLOUD INSTANCE ADMIN API KEY"  # generated by Grafana Cloud Grafana Instance
export LOKI_METRICS_PUBLISHER_USER="YOUR_LOKI_USER"  # a number like 123456, determined by Grafana
export PROM_METRICS_PUBLISHER_USER="YOUR_PROM_USER"  # a number like 654321, determined by Grafana
export LOKI_METRICS_PUBLISHER_URL="https://logs-prod-us-central1.grafana.net"
export PROM_METRICS_PUBLISHER_URL="https://prometheus-prod-10-prod-us-central-0.grafana.net/api/prom/push"

#
# Instead of coding values in this file, it is an option to have secrets outside of this directory to avoid
# potential exposure via source control.
#
#export GRAFANA_CLOUD_ORG=$(cat ${PROJECTHOME}/../.grafana/GRAFANA_CLOUD_ORG.txt)
#export GRAFANA_CLOUD_METRICS_PUBLISHER_PASS=$(cat ${PROJECTHOME}/../.grafana/GRAFANA_CLOUD_METRICS_PUBLISHER_PASS.txt)
#export GRAFANA_CLOUD_INSTANCE_KEY=$(cat ${PROJECTHOME}/../.grafana/GRAFANA_CLOUD_INSTANCE_KEY.txt)
#export LOKI_METRICS_PUBLISHER_USER=$(cat ${PROJECTHOME}/../.grafana/LOKI_METRICS_PUBLISHER_USER.txt)
#export PROM_METRICS_PUBLISHER_USER=$(cat ${PROJECTHOME}/../.grafana/PROM_METRICS_PUBLISHER_USER.txt)
#export LOKI_METRICS_PUBLISHER_URL=$(cat ${PROJECTHOME}/../.grafana/LOKI_METRICS_PUBLISHER_URL.txt)
#export PROM_METRICS_PUBLISHER_URL=$(cat ${PROJECTHOME}/../.grafana/PROM_METRICS_PUBLISHER_URL.txt)


###################################################
# SETTINGS which you usually don't need to change #
###################################################

# K3D Config
export CLUSTER="westie-dev" # Cluster name
export HTTPPORT=8080        # Port for HTTP access to Grafana/Prometheus/Alertmanager in this cluster
export ISTIOPORT=8081       # For for HTTP through Istio
[ -z ${KUBECONFIG} ] && export KUBECONFIG=~/.k3d/kubeconfig-${CLUSTER}.yaml   # the likely KUBECONFIG value

# IF there is HPA, KEDA is disabled here
[ "${HPA_ENABLE}" == "yes" ] && KEDA_ENABLE="no"

# Grafana Local instance password for admin account
# you can pick a password here, or have it an external file such as ${PROJECTHOME}/../.grafana/GRAFANA_LOCAL_ADMIN_PASS.txt
export GRAFANA_LOCAL_ADMIN_PASS="operator" 
#export GRAFANA_LOCAL_ADMIN_PASS=$(cat ${PROJECTHOME}/../.grafana/GRAFANA_LOCAL_ADMIN_PASS.txt)

# InfluxDB local instance password for admin account
# you can pick a InfluxDB password here, or have it in an external file, e.g. ${PROJECTHOME}/../.influx/INFLUXDB_LOCAL_ADMIN_PASSWORD.txt
export INFLUXDB_LOCAL_ADMIN_PASSWORD="password" 
#export INFLUXDB_LOCAL_ADMIN_PASSWORD=$(cat ${PROJECTHOME}/../.influxdb/INFLUXDB_LOCAL_ADMIN_PASSWORD.txt)

# Helm chart versions
# you can update when you know what you are doing 
INFLUXDBCHART="4.10.6"             # see https://artifacthub.io/packages/helm/influxdata/influxdb
INGRESSNGINXCHART="4.0.17"         # see https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
FLUENTBITCHART="0.19.19"           # see https://artifacthub.io/packages/helm/fluent/fluent-bit
KUBEPROMETHEUSSTACKCHART="30.1.0"  # see https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
PROMOPERATOR="0.53.1"              # This is for Prometheus' CRDs. The version must fit to the chart version above. 
				   # Also note that the CRDs are loaded by "./start.sh" and not by "./prom-deploy.sh". 
				   # "./start.sh" needs to be called when the PROMOPERATOR CRD version changes.
GOLDILOCKSCHART="5.2.0"            # see https://artifacthub.io/packages/helm/fairwinds-stable/goldilocks
KEDACHART="2.6.2"                  # see https://artifacthub.io/packages/helm/kedacore/keda
KUBERNETESDASHBOARDCHART="5.2.0"   # see https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard
NGINXCHART="9.7.6"                 # see https://artifacthub.io/packages/helm/bitnami/nginx
ISTIODCHART="1.12.2"               # see https://artifacthub.io/packages/helm/istio-official/istiod
ISTIOBASECHART="1.12.2"            # see https://artifacthub.io/packages/helm/istio-official/base
ISTIOGATEWAYCHART="1.12.2"         # see https://artifacthub.io/packages/helm/istio-official/gateway

# Path to AMTOOL if available. Extract from https://github.com/prometheus/alertmanager/releases
# This is optional, you don't need to install it. 
export AMTOOL=~/bin/amtool


##########################################
# Other settings you don't need to touch #
##########################################

# app and version from package.json
export APP=$(cat ${PROJECTHOME}/app/package.json | grep '^  \"name\":' | cut -d ' ' -f 4 | tr -d '",')         
export VERSION=$(cat ${PROJECTHOME}/app/package.json | grep '^  \"version\":' | cut -d ' ' -f 4 | tr -d '",') 

# Local InfluxDB port config
export INFLUXUIPORT=31080   # Web UI for Influx DB, use http://localhost:${INFLUXUIPORT}
export INFLUXPORT=31081     # Access port for InfluxDB itself (the web UI uses this port)

# Local Goldilocks dashboard port
export GOLDILOCKSPORT=31082 # access to the Goldilocks dashboard via http://localhost:${GOLDILOCKSPORT}

# environment vars for envsubst
ENVSUBSTVAR='$HTTPPORT $CLUSTER $APP $GRAFANA_LOCAL_ADMIN_PASS $SLACKWEBHOOK $AMTOOL $AMTOOLCONFIG $VERSION $INFLUXPORT $INFLUXUIPORT $GRAFANA_CLOUD_METRICS_PUBLISHER_PASS $LOKI_METRICS_PUBLISHER_URL $LOKI_METRICS_PUBLISHER_USER $PROM_METRICS_PUBLISHER_URL $PROM_METRICS_PUBLISHER_USER $GRAFANACLOUDPROM $GRAFANACLOUDLOGS $SLACK_OR_NULL $ISTIOPORT'

# amtool related settings
AMTOOLCONFIG=~/.config/amtool/config.yml
[ -x ${AMTOOL} ] && mkdir -p $(dirname ${AMTOOLCONFIG}) && cat ${PROJECTHOME}/prom/amtool-config.yaml.template | envsubst > ${AMTOOLCONFIG}

# Grafana Cloud data sources constructed from the organization name 
export GRAFANACLOUDPROM="grafanacloud-${GRAFANA_CLOUD_ORG}-prom"
export GRAFANACLOUDLOGS="grafanacloud-${GRAFANA_CLOUD_ORG}-logs"


##########
# CHECKS #
##########
if [ "${SLACK_ENABLE}" == "yes" ]; then
  [ -z ${SLACKWEBHOOK} ] && echo "$0: missing SLACKWEBHOOK definition." && exit 1
  [ "${SLACKWEBHOOK}" == "YOUR-WEBHOOK-URL-HERE" ] && echo "$0: need to edit SLACKWEBHOOK customization." && exit 1
fi

if [ "${GRAFANA_CLOUD_ENABLE}" == "yes" ]; then
  [ -z ${GRAFANA_LOCAL_ADMIN_PASS} ] && echo "$0: missing GRAFANA_LOCAL_ADMIN_PASS definition." && exit 1
  [ -z ${GRAFANA_CLOUD_ORG} ] && echo "$0: missing GRAFANA_CLOUD_ORG definition." && exit 1
  [ -z ${GRAFANA_CLOUD_METRICS_PUBLISHER_PASS} ] && echo "$0: missing GRAFANA_CLOUD_METRICS_PUBLISHER_PASS definition." && exit 1
  #[ -z ${GRAFANA_CLOUD_INSTANCE_KEY} ] && echo "$0: missing GRAFANA_CLOUD_INSTANCE_KEY definition." && exit 1
  [ -z ${LOKI_METRICS_PUBLISHER_USER} ] && echo "$0: missing LOKI_METRICS_PUBLISHER_USER definition." && exit 1
  [ -z ${PROM_METRICS_PUBLISHER_USER} ] && echo "$0: missing PROM_METRICS_PUBLISHER_USER definition." && exit 1
  [ -z ${LOKI_METRICS_PUBLISHER_URL} ] && echo "$0: missing LOKI_METRICS_PUBLISHER_URL definition." && exit 1
  [ -z ${PROM_METRICS_PUBLISHER_URL} ] && echo "$0: missing PROM_METRICS_PUBLISHER_URL definition." && exit 1

  [ "${GRAFANA_CLOUD_ORG}" == "YOURORGNAME" ] && echo "$0: missing GRAFANA_CLOUD_ORG customization." && exit 1
  [ "${GRAFANA_CLOUD_METRICS_PUBLISHER_PASS}" == "YOUR METRICS PUBLISHER API KEY" ] && echo "$0: missing GRAFANA_CLOUD_METRICS_PUBLISHER_PASS customization." && exit 1
  [ "${LOKI_METRICS_PUBLISHER_USER}" == "YOUR_LOKI_USER" ] && echo "$0: missing LOKI_METRICS_LOKI_METRICS_PUBLISHER_USER customization." && exit 1
  [ "${PROM_METRICS_PUBLISHER_USER}" == "YOUR_PROM_USER" ] && echo "$0: missing PROM_METRICS_PUBLISHER_USER customization." && exit 1
  #[ "${GRAFANA_CLOUD_INSTANCE_KEY}" == "YOUR GRAFAN-CLOUD INSTANCE ADMIN API KEY" && echo "$0: missing GRAFANA_CLOUD_INSTANCE_KEY customization." && exit 1

fi

[ -z ${INFLUXDB_LOCAL_ADMIN_PASSWORD} ] && echo "$0: missing INFLUXDB_ADMIN_PASSWORD definition." && exit 1
[ -z ${APP} ] && echo "$0: missing APP definition." && exit 1
[ -z ${VERSION} ] && echo "$0: missing VERSION definition." && exit 1
[ -z ${INFLUXDBCHART} ] && echo "$0: missing INFLUXDBCHART definition." && exit 1
[ -z ${INGRESSNGINXCHART} ] && echo "$0: missing INGRESSNGINXCHART definition." && exit 1
[ -z ${FLUENTBITCHART} ] && echo "$0: missing FLUENTBITCHART definition." && exit 1
[ -z ${KUBEPROMETHEUSSTACKCHART} ] && echo "$0: missing KUBEPROMETHEUSSTACKCHART definition." && exit 1
[ -z ${PROMOPERATOR} ] && echo "$0: missing PROMOPERATOR definition." && exit 1
[ -z ${HTTPPORT} ] && echo "$0: missing HTTPPORT definition." && exit 1
[ -z ${CLUSTER} ] && echo "$0: missing CLUSTER definition." && exit 1
[ -z ${INFLUXUIPORT} ] && echo "$0: missing INFLUXUIPORT definition." && exit 1
[ -z ${INFLUXPORT} ] && echo "$0: missing INFLUXPORT definition." && exit 1

if [ "${GOLDILOCKS_ENABLE}" == "yes" ]; then
  [ -z ${GOLDILOCKSPORT} ] && echo "$0: missing GOLDILOCKSPORT definition." && exit 1	
fi

if [[ "$(which npx)" == "" ]]; then
  echo "config.sh: we need npx/node/npm installed. but there is no npx... nodejs not installed? "
  exit 1
fi
