FROM --platform=linux/amd64 eclipse-temurin:8-jre-alpine

WORKDIR /app

# 复制应用程序和配置文件
COPY target/helloworld_jdk8.jar .
COPY src/main/resources/app.yml .

# 定义可在构建时设置的数据库相关参数
ARG DB_HOST=111.111.111.111
ARG DB_PORT=3306
ARG DB_NAME=test
ARG DB_USER=root
ARG DB_PASSWORD=root

# 安装必要的工具（用于替换配置文件中的占位符）
RUN apk add --no-cache gettext

# 生成配置文件并替换占位符
RUN envsubst < app.yml > app.yml

# 暴露端口
EXPOSE 8086

# 设置环境变量
ENV SPRING_CONFIG_LOCATION=app.yml

# 启动应用程序
ENTRYPOINT ["java", "-jar", "helloworld_jdk8.jar"]

# 导出镜像tar

# docker build -t helloworld:latest .
# docker save -o helloworld.tar helloworld:latest
