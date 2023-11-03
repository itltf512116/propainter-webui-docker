# propainter-webui-docker
propainter-webui的docker部署【示例Dockerfile未经过优化】

***

```shell
# 1. 首先clone Propainter-Webui
git clone https://github.com/halfzm/ProPainter-Webui.git

## 这里使用的是propainter-webui代码库，这个项目里面内嵌了propainter，
## 如果内嵌的propainter代码不是最新的，可以之间使用挂载的形式重新把最新的代码挂载进去
## github: https://github.com/sczhou/ProPainter

# 2. 下载依赖：
https://cdn-media.huggingface.co/frpc-gradio-0.2/frpc_linux_amd64 # 下载完成后的使用参考Dockerfile

# 3. 下载镜像文件，参照 https://github.com/halfzm/ProPainter-Webui#prepare-pretrained-models 里面的说明准备好两个目录：
/ProPainter-Webui/ckpt
/ProPainter-Webui/weights # 这两个目录通过挂载卷的形式挂载到容器内部

# 下载 https://huggingface.co/bert-base-uncased 放到ckpt里面：/ProPainter-Webui/ckpt/bert-base-uncased

# 4. 解决CPU Mode only问题
git clone https://github.com/IDEA-Research/GroundingDINO.git
cd GroundingDINO && python setup.py build
# 编译完成之后，找到文件 _C.cpython-310-x86_64-linux-gnu.so 放到目录/ProPainter-Webui/groundingdino中

# 5. 修改/ProPainter-Webui/requirements.txt，注释掉下面两行
torch==2.0.1+cu117
torchvision==0.15.2+cu117

# 6.打包镜像
docker build -t propainter-ui:v1.2 .

# 7.启动docker时设置环境变量 CUDA_HOME=/usr/local/cuda，可以参考docker-compose.yml
```