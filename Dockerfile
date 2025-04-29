# Stage 1: Build Angular App
FROM node:18.13 AS build-stage

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
