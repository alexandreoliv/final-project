FROM node:23.6-alpine3.20

WORKDIR /var/www/exp_frontend

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]