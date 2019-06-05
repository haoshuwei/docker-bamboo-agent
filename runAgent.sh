#!/bin/bash
#if [ -z ${1+x} ]; then
#    echo "Please run the Docker image with Bamboo URL as the first argument"
#    exit 1
#fi
if [ ! -f ${BAMBOO_CAPABILITIES} ]; then
    cp ${INIT_BAMBOO_CAPABILITIES} ${BAMBOO_CAPABILITIES}
fi

if [ -z ${SECURITY_TOKEN+x} ]; then   
    BAMBOO_SECURITY_TOKEN_PARAM=
else 
    BAMBOO_SECURITY_TOKEN_PARAM="-t ${SECURITY_TOKEN}"
fi 

BAMBOO_SERVER_URL_PARAM=''
if [ -n "$BAMBOO_SERVER_URL" ]; then
    BAMBOO_SERVER_URL_PARAM="${BAMBOO_SERVER_URL}"
fi

java ${VM_OPTS} -jar ${AGENT_JAR} ${BAMBOO_SERVER_URL_PARAM}/agentServer/ ${BAMBOO_SECURITY_TOKEN_PARAM}
