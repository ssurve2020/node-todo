FROM bitnami/node:12.14.1-debian-10-r3

COPY . /app

RUN npm install --production

EXPOSE 8080
CMD ["node", "server.js"]
