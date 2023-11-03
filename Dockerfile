FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND noninteractive

RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && tee /etc/apt/sources.list <<-'EOF'
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
EOF

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y libgl1 libglib2.0-0 wget git git-lfs python3-pip python-is-python3 && rm -rf /var/lib/apt/lists/*


## 这里使用的是propainter-webui代码库，这个项目里面内嵌了propainter，
## 如果内嵌的propainter代码不是最新的，可以之间使用挂载的形式重新把最新的代码挂载进去
## github: https://github.com/sczhou/ProPainter

COPY ./ProPainter-Webui /ProPainter-Webui

WORKDIR /ProPainter-Webui

RUN  pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip config set install.trusted-host pypi.tuna.tsinghua.edu.cn \
    && pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 \
    && pip install -r requirements.txt

RUN pip install opencv-contrib-python gradio==3.50.2 scikit-image addict yapf pycocotools timm supervision einops av spatial-correlation-sampler
# 将需要用到的模型文件挂载到/ProPainter-Webui/ProPainter/weight

# 下载 https://cdn-media.huggingface.co/frpc-gradio-0.2/frpc_linux_amd64
COPY frpc_linux_amd64 frpc_linux_amd64_v0.2
RUN mv frpc_linux_amd64_v0.2 /usr/local/lib/python3.10/dist-packages/gradio \
    && chmod +x /usr/local/lib/python3.10/dist-packages/gradio/frpc_linux_amd64_v0.2

# 如果ProPainter-Webui/groundingdino目录下没有_C.cpython-310-x86_64-linux-gnu.so文件
# 可以打开https://github.com/IDEA-Research/GroundingDINO/tree/main
# 然后在linux下执行python setup.py build
# 在build目录下找到_C.cpython-310-x86_64-linux-gnu.so文件复制到目录

CMD [ "python","app.py" ]