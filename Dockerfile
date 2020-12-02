FROM ubuntu:18.04
#16.04
# 18.04

#####
# Install docker 19.03
#####
# V16
#RUN apt-get update
#RUN apt-get install curl wget -y
#RUN curl -sSL https://get.docker.com/ | sed 's/docker-ce/docker-ce=18.03.0~ce-0~ubuntu/' | sh

# 18
#RUN apt-get update && apt-get install -y \
#    apt-transport-https \
#    ca-certificates \
#    curl \
#    gnupg-agent \
#    software-properties-common
#RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#RUN add-apt-repository \
#   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) \
#   stable"
#RUN apt-get update && apt-get install -y \
#   docker-ce=5:19.03.12~3-0~ubuntu-bionic \
#   docker-ce-cli=5:19.03.12~3-0~ubuntu-bionic \
#   containerd.io=1.2.13-2

# Vtest
RUN apt-get update
RUN apt-get remove docker docker-engine docker.io
RUN apt install -y docker.io

RUN apt-get install curl wget -y
RUN apt-get update && apt-get install -y gnupg2

#####
# Install nvidia-container-toolkit
#####
RUN curl -fsSL https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
RUN curl -fsSL https://nvidia.github.io/nvidia-docker/ubuntu18.04/nvidia-docker.list \
    | tee /etc/apt/sources.list.d/nvidia-docker.list

RUN apt-get update && apt-get install -y nvidia-container-toolkit

####
# Install nvidia-docker
####
RUN curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  apt-key add -

RUN curl -s -L https://nvidia.github.io/nvidia-docker/$(. /etc/os-release;echo $ID$VERSION_ID)/nvidia-docker.list | \
  tee /etc/apt/sources.list.d/nvidia-docker.list
RUN apt-get update
RUN apt-get install -y nvidia-docker2

#####
# Install entr which is a file watching library
#####
RUN apt-get install -y entr

#####
# Install python 3.8 and pip3
#####
#RUN apt-get install -y python3.8 python3-pip
RUN apt-get install -y python3-pip

# Move into our worker directory, so we're not in /
WORKDIR /worker/

# Install Python stuff we need to listen to the queue
COPY requirements.txt /worker/requirements.txt
RUN pip3 install -r requirements.txt
# pip3

# Copy our actual code
COPY *.py /worker/
COPY detailed_result_put.sh /worker/

# Run it
CMD celery -A worker worker -l info -Q compute-worker -n compute-worker%h -Ofast -Ofair --concurrency=1
