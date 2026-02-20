FROM rockylinux:9

ARG TARGETARCH

RUN echo "tsflags=nodocs" >> /etc/dnf/dnf.conf

RUN dnf update -y && \
    dnf clean all && \
    rm -rf /var/cache/yum

RUN /usr/bin/crb enable && \
    dnf install -y epel-release && \
	rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm && \
    dnf clean all && \
    rm -rf /var/cache/yum

RUN dnf -y swap curl-minimal curl && \
	dnf install -y \
        python3 \
		python3-pip \
        ca-certificates \
        wget \
        git \
        iputils \
        jq \
	azure-cli && \
    dnf clean all && \
    rm -rf /var/cache/yum

RUN dnf install -y \
		podman \
		podman-docker && \
    dnf clean all && \
    rm -rf /var/cache/yum

RUN dnf install -y --disablerepo=packages-microsoft-com-prod \
    	dotnet-sdk-6.0 \
        dotnet-sdk-8.0 \
		dotnet-sdk-10.0 && \
    dnf clean all && \
    rm -rf /var/cache/yum

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$TARGETARCH/kubectl" && \
	install kubectl /usr/bin/kubectl && \
	rm -rf kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
	HELM_INSTALL_DIR=/usr/bin sh ./get_helm.sh && \
	rm -rf get_helm.sh

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]
