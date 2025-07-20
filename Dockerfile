FROM nvcr.io/nvidia/l4t-pytorch:r32.7.1-pth1.10-py3

ENV LANG=C.UTF-8
ENV PYTHONIOENCODING=utf-8


# Install core dependencies and tools
RUN sed -i '/kitware.com/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    wget curl git build-essential \
    python3-pip nano unzip \
    g++-7 gcc-7 \
    libopenblas-base libopenmpi-dev libomp-dev \
    libjpeg-dev zlib1g-dev libpython3-dev \
    libavcodec-dev libavformat-dev libswscale-dev \
    software-properties-common gnupg && \
    rm -rf /var/lib/apt/lists/* 
ENV CC=/usr/bin/gcc-7
ENV CXX=/usr/bin/g++-7

# Install Python dependencies
RUN pip3 install --upgrade pip setuptools scikit-build && \
    pip3 install --only-binary=:all: opencv-python==4.5.5.64 && \
    pip3 install scikit-image ipykernel jupyterlab jupyter_http_over_ws 'Cython<3' && \
    pip3 install --ignore-installed PyYAML==5.1.1 PyYAML==5.1.1 && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 10
ENV LLVM_CONFIG=/usr/bin/llvm-config-10

WORKDIR /workspace/DECA

# Copy DECA project
COPY . .

# Install DECA Python requirements
RUN pip3 install -r requirements.txt

# Download required model files
RUN wget https://github.com/waps101/AlbedoMM/releases/download/v1.0/albedoModel2020_FLAME_albedoPart.npz -P /workspace/DECA/data/ && \
    mv /workspace/DECA/data/albedoModel2020_FLAME_albedoPart.npz /workspace/DECA/data/FLAME_albedo_from_BFM.npz && \
    pip3 install gdown && \
    gdown --id 1rp8kdyLPvErw2dTmqtjISRVvQLj6Yzje -O /workspace/DECA/data/deca_model.tar

# Remove unnecessary packages and clean cache (excluding model files)
RUN apt-get purge -y build-essential software-properties-common gnupg gcc-7 g++-7 git wget unzip nano && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /root/.cache /tmp/* ~/.cache/pip /var/tmp/*
