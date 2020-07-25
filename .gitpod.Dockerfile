FROM gitpod/workspace-full
                    
USER root

### Helm3 ###
RUN mkdir -p /tmp/helm/ \
    && curl -fsSL https://get.helm.sh/helm-v3.0.3-linux-amd64.tar.gz | tar -xzvC /tmp/helm/ --strip-components=1 \
    && cp /tmp/helm/helm /usr/local/bin/helm \
    && rm -rf /tmp/helm/

### kubectl & letsencrypt ###
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    # really 'xenial'
    && add-apt-repository -yu "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    && apt-get install -yq kubectl=1.13.0-00 letsencrypt \
    && kubectl completion bash > /usr/share/bash-completion/completions/kubectl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

### Kops ###
# https://kops.sigs.k8s.io/getting_started/install/
RUN cd /tmp && \
    curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 && \
    chmod +x kops-linux-amd64 && \
    mv kops-linux-amd64 /usr/local/bin/kops

USER gitpod

### Google Cloud ###
# not installed via repository as then 'docker-credential-gcr' is not available
ARG GCS_DIR=/opt/google-cloud-sdk
ENV PATH=$GCS_DIR/bin:$PATH
RUN sudo chown gitpod: /opt \
    && mkdir $GCS_DIR \
    && curl -fsSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-245.0.0-linux-x86_64.tar.gz \
    | tar -xzvC /opt \
    && /opt/google-cloud-sdk/install.sh --quiet --usage-reporting=false --bash-completion=true \
    --additional-components docker-credential-gcr alpha beta \
    # needed for access to our private registries
    && docker-credential-gcr configure-docker

### AWS Cli ###
RUN python3 -m pip install --user awscli

# Install aws-iam-authenticator
RUN sudo curl -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator" \
    && sudo chmod +x ./aws-iam-authenticator \
    && sudo mkdir -p $HOME/.aws-iam \
    && sudo cp ./aws-iam-authenticator $HOME/.aws-iam/aws-iam-authenticator

# Install Terraform
RUN mkdir -p ~/.terraform \
    && cd ~/.terraform \
    && wget "https://releases.hashicorp.com/terraform/0.13.0-beta2/terraform_0.13.0-beta2_linux_amd64.zip" \
    && unzip terraform_0.13.0-beta2_linux_amd64.zip \
    && rm -f terraform_0.13.0-beta2_linux_amd64.zip \
    && printf "terraform -install-autocomplete\n" >>~/.bashrc

# Install some helper programs
RUN brew install shellharden shfmt shellcheck

ENV PATH=$PATH:$HOME/.aws-iam:$HOME/.terraform
