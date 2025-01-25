FROM node:23.6-alpine3.20

WORKDIR /var/www/exp_backend

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8706

CMD [ "npm", "start" ]