FROM node:18-alpine

RUN apk add --no-cache git

WORKDIR /excalidraw-room

RUN git clone --depth 1 https://github.com/excalidraw/excalidraw-room.git .

RUN yarn
RUN yarn build

EXPOSE 80

CMD ["yarn", "start"]
