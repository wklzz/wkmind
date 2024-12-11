# 开发环境
FROM node:16-alpine as development
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# 生产环境
FROM node:16-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Nginx服务
FROM nginx:alpine as production
COPY --from=build /app/dist /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"] 