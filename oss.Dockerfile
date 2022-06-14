FROM node:14-alpine as builder

ARG ACCESS_KEY_ID
ARG ACCESS_KEY_SECRET
ARG ENDPOINT
ENV PUBLIC_URL https://stone-bucket-1030.oss-cn-hangzhou.aliyuncs.com/

WORKDIR /code

# # 为了更好的缓存，把它放在前边
# RUN curl -o ossutilmac64 https://gosspublic.alicdn.com/ossutil/1.7.13/ossutilmac64 \
#   && chmod 755 ossutilmac64 \
#   && ./ossutilmac64 config -i $ACCESS_KEY_ID -k $ACCESS_KEY_SECRET -e $ENDPOINT

# 单独分离 package.json，是为了安装依赖可最大限度利用缓存
ADD package.json yarn.lock /code/
RUN yarn

ADD . /code
RUN npm run build && npm run oss:cli

# 选择更小体积的基础镜像
FROM nginx:alpine
ADD nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder code/build /usr/share/nginx/html