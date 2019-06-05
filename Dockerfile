FROM ubuntu:18.04
MAINTAINER Bamboo/Atlassian

ENV BAMBOO_VERSION=6.8.3

ENV DOWNLOAD_URL=https://packages.atlassian.com/maven-closedsource-local/com/atlassian/bamboo/atlassian-bamboo-agent-installer/${BAMBOO_VERSION}/atlassian-bamboo-agent-installer-${BAMBOO_VERSION}.jar
ENV BAMBOO_USER=bamboo
ENV BAMBOO_GROUP=bamboo
ENV BAMBOO_USER_HOME=/home/${BAMBOO_USER}
ENV BAMBOO_AGENT_HOME=${BAMBOO_USER_HOME}/bamboo-agent-home
ENV AGENT_JAR=${BAMBOO_USER_HOME}/atlassian-bamboo-agent-installer.jar
ENV SCRIPT_WRAPPER=${BAMBOO_USER_HOME}/runAgent.sh
ENV INIT_BAMBOO_CAPABILITIES=${BAMBOO_USER_HOME}/init-bamboo-capabilities.properties
ENV BAMBOO_CAPABILITIES=${BAMBOO_AGENT_HOME}/bin/bamboo-capabilities.properties

ENV KANIKO_VERSION=0.6.0
ENV KUBECTL_VERSION=1.12
ENV KANIKO_DOWNLOAD_URL=https://acs-cicd.oss-cn-hangzhou.aliyuncs.com/kaniko/v${KANIKO_VERSION}/kaniko
ENV KUBECTL_DOWNLOAD_URL=https://acs-cicd.oss-cn-hangzhou.aliyuncs.com/kubectl/v${KUBECTL_VERSION}/kubectl
ENV KANIKO_BIN=/usr/bin/kaniko
ENV KUBECTL_BIN=/usr/bin/kubectl

RUN apt-get update -y && \
    apt-get upgrade -y && \
    # please keep Java version in sync with JDK capabilities below
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y curl && \
    apt-get install -y maven && \
    apt-get install -y git


RUN addgroup ${BAMBOO_GROUP} && \
     adduser --home ${BAMBOO_USER_HOME} --ingroup ${BAMBOO_GROUP} --disabled-password ${BAMBOO_USER}

RUN curl -L --output ${AGENT_JAR} ${DOWNLOAD_URL}
RUN curl -L --output ${KANIKO_BIN} ${KANIKO_DOWNLOAD_URL}
RUN curl -L --output ${KUBECTL_BIN} ${KUBECTL_DOWNLOAD_URL}
COPY bamboo-update-capability.sh  ${BAMBOO_USER_HOME}/bamboo-update-capability.sh 
COPY runAgent.sh ${SCRIPT_WRAPPER} 

RUN chmod +x ${BAMBOO_USER_HOME}/bamboo-update-capability.sh && \
    chmod +x ${SCRIPT_WRAPPER} && \
    chmod +x /usr/bin/kaniko && \
    chmod +x /usr/bin/kubectl && \
    mkdir -p ${BAMBOO_USER_HOME}/bamboo-agent-home/bin && \
    mkdir -p /kaniko

RUN chown -R ${BAMBOO_USER} ${BAMBOO_USER_HOME}
RUN chown -R ${BAMBOO_USER} /kaniko

#USER ${BAMBOO_USER}
USER root

RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.jdk.JDK 1.8" /usr/lib/jvm/java-1.8-openjdk/bin/java
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.mvn3.Maven 3.3" /usr/share/maven
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.git.executable" /usr/bin/git

WORKDIR ${BAMBOO_USER_HOME}

ENTRYPOINT ["./runAgent.sh"]
