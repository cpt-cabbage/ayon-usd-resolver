FROM rockylinux:9

# Install build dependencies
RUN dnf install -y \
        gcc \
        gcc-c++ \
        cmake \
        make \
        git \
        python3-devel \
        openssl-devel \
    && dnf clean all

WORKDIR /workspace

CMD ["bash"]
