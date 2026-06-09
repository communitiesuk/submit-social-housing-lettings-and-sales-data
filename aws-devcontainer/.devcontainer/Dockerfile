FROM homebrew/brew

RUN brew install aws-vault && brew install awscli
RUN if [ "$(dpkg --print-architecture)" = "arm64" ]; then \
      ARCH="ubuntu_arm64"; \
    else \
      ARCH="ubuntu_64bit"; \
    fi && \
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/${ARCH}/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    sudo dpkg -i session-manager-plugin.deb

ENV AWS_VAULT_BACKEND=file
ENV AWS_VAULT_FILE_DIR=./vault
ENV AWS_CONFIG_FILE=./config
