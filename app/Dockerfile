# Multi-Stage Dockerfile
# ----
# This first stage will install all dependencies and build the application 
FROM node:12.17.0-alpine
WORKDIR /usr
COPY package.json ./
COPY tsconfig.json ./
COPY src ./src
RUN ls -a
RUN npm install
RUN npm run build

# Stage 2 where the application acutaly runs. Only production deps are being
# installed. This can drastically reduce the size of the image.
FROM node:12.17.0-alpine
WORKDIR /usr
COPY package.json ./
RUN npm install --only=production
COPY --from=0 /usr/dist .
CMD ["node","app.js"]