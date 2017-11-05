FROM node:8-slim

WORKDIR /code

ADD ./package.json .
RUN npm install

ADD ./elm-package.json .
RUN npm run elm_install

ADD ./webpack.config.js .

CMD ["npm", "start"]