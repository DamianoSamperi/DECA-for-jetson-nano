#FROM pytorch/pytorch:1.6.0-cuda10.1-cudnn7-devel
FROM nvcr.io/nvidia/l4t-pytorch:r32.7.1-pth1.10-py3
RUN sed -i '/kitware.com/d' /etc/apt/sources.list
RUN apt-get update && apt-get install -y wget curl git build-essential
RUN python3 -m pip install --upgrade pip
RUN pip3 install --upgrade setuptools scikit-build
ENV LANG C.UTF-8
ENV PYTHONIOENCODING=utf-8
RUN pip3 install --only-binary=:all: opencv-python==4.5.5.64 
RUN pip3 install scikit-image
#RUN pip3 uninstall scikit-image && pip3 install scikit-image>=0.15
# Miniconda
# ENV PATH="/root/miniconda3/bin:${PATH}"
# ARG PATH="/root/miniconda3/bin:${PATH}"
# RUN wget \
#     https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
#     && mkdir /root/.conda \
#     && bash Miniconda3-latest-Linux-x86_64.sh -b \
#     && rm -f Miniconda3-latest-Linux-x86_64.sh 

# RUN conda create -n xp
# SHELL ["conda", "run", "--no-capture-output", "-n", "xp", "/bin/bash", "-c"]
# RUN conda install python=3.7 \
#     && conda install -c conda-forge jupyterlab \
#     && conda init bash \
#     && echo "conda activate xp" >> ~/.bashrc

RUN pip3 install ipykernel jupyterlab jupyter_http_over_ws \
    && jupyter serverextension enable --py jupyter_http_over_ws

WORKDIR /workspace/DECA
COPY . .
RUN apt-get update && apt-get install -y \
    python3-pip \
    libopenblas-base \
    libopenmpi-dev \
    libomp-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpython3-dev \
    libopenblas-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    git \
    wget \
    && apt-get clean

# Install Cython (versione < 3 per compatibilità)
RUN pip3 install 'Cython<3'


# Download and install PyTorch 1.8.0 (precompiled wheel for Jetson Nano)
#RUN wget https://nvidia.box.com/shared/static/p57jwntv436lfrd78inwl7iml6p13fzh.whl -O torch-1.10.0-cp36-cp36m-linux_aarch64.whl \
#    && pip3 install torch-1.10.0-cp36-cp36m-linux_aarch64.whl \
#    && rm torch-1.10.0-cp36-cp36m-linux_aarch64.whl
#ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
#RUN ldconfig
# Clone and build torchvision v0.9.0
#RUN wget https://nvidia.box.com/shared/static/torchvision-0.11.0-cp36-cp36m-linux_aarch64.whl \
#    && pip3 install torchvision-0.11.0-cp36-cp36m-linux_aarch64.whl
# (Opzionale) Pillow downgrade se necessario
#RUN pip3 install 'pillow<7'

# Aggiungi qui il resto delle dipendenze se usi requirements.txt
RUN apt-get remove -y llvm llvm-6.0 llvm-dev || true
RUN apt-get update && \
    apt-get install -y wget gnupg software-properties-common && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 10
ENV LLVM_CONFIG=/usr/bin/llvm-config-10
RUN pip3 install --ignore-installed PyYAML==5.1.1
RUN pip3 install -r requirements.txt
RUN apt install -y nano unzip && pip3 install gdown
#RUN gdown --fuzzy "https://drive.google.com/uc?id=128EYVn7x3nZ96e3OfYGtR_es5-iQt3JJ" -O /workspace/DECA/data/deca_model.tar
# &  unzip /workspace/DECA/data/deca_model.zip -d /workspace/DECA/data/

RUN apt update && apt install -y gcc-7 g++-7
ENV CC=/usr/bin/gcc-7
ENV CXX=/usr/bin/g++-7
RUN wget https://github.com/waps101/AlbedoMM/releases/download/v1.0/albedoModel2020_FLAME_albedoPart.npz -P /workspace/DECA/data/
RUN mv /workspace/DECA/data/albedoModel2020_FLAME_albedoPart.npz /workspace/DECA/data/FLAME_albedo_from_BFM.npz
RUN gdown --id 1rp8kdyLPvErw2dTmqtjISRVvQLj6Yzje -O /workspace/DECA/data/deca_model.tar
#RUN tar -cvf /workspace/DECA/data/deca_model.tar -C /workspace/DECA/data FLAME2020 && \
#    rm -rf /workspace/DECA/data/deca_model.zip /workspace/DECA/data/FLAME2020

