FROM node:8-slim as asset_builder

WORKDIR /code

ADD ./package.json .
RUN npm install

ADD ./elm-package.json .
RUN npm run elm_install

ADD ./webpack.config.js .
COPY ./assets /code/assets

RUN npm run prodrun

FROM arm32v7/nginx

COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=asset_builder ./code/dist /usr/share/nginx/html
