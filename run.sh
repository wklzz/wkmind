#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Vue Mind Map project...${NC}"

# 检查docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo -e "${YELLOW}Docker is not running. Starting Docker...${NC}"
    # 这里可以添加启动 Docker 的命令，不同系统可能不同
    # Linux: systemctl start docker
    # MacOS: open -a Docker
fi

# 停止并删除已存在的容器
echo -e "${YELLOW}Cleaning up existing containers...${NC}"
docker-compose down

# 重新构建并启动容器
echo -e "${YELLOW}Building and starting containers...${NC}"
docker-compose up --build -d

# 等待服务启动
echo -e "${YELLOW}Waiting for service to start...${NC}"
sleep 5

# 获取本地IP地址
if [[ "$OSTYPE" == "darwin"* ]]; then
    # MacOS
    LOCAL_IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
else
    # Linux
    LOCAL_IP=$(hostname -I | awk '{print $1}')
fi

echo -e "${GREEN}Vue Mind Map is running!${NC}"
echo -e "${GREEN}You can access it at:${NC}"
echo -e "${GREEN}http://localhost:8080${NC}"
echo -e "${GREEN}http://$LOCAL_IP:8080${NC}"

# 显示容器日志
echo -e "${YELLOW}Showing container logs (Ctrl+C to exit):${NC}"
docker-compose logs -f 