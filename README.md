# 🖊️ Excalidraw Self-Hosting with Collab Server

This project lets you self-host [Excalidraw](https://excalidraw.com/) along with its collaboration server using Docker. You can run it either:

* ✅ Locally with exposed ports, or
* 🚀 On Dokploy with built-in Traefik support via labels.

---

## 📦 Project Structure

```
.
├── .env                     # Defines default envs
├── .env.local               # Defines default envs for local
├── docker-compose.yml       # Defines services
├── excalidraw.Dockerfile    # Builds the frontend
└── collab.Dockerfile        # Builds the collab (WebSocket) server
```

---

## 🚀 Deploying with Dokploy

When deploying with [Dokploy](https://dokploy.com/), Traefik should automatically pick up routing rules from the labels defined in `docker-compose.yml`. No manual reverse proxy setup needed.

You should choose the compose service and import this repository as your source.

Make sure to pass all the environment variables you'd like to change at the environment tab. These are the required environment variables if you are deploying with dokploy:
```sh
EXCALIDRAW_DOMAIN=draw.example.com
COLLAB_DOMAIN=collab.example.com
VITE_APP_WS_SERVER_URL=wss://collab.example.com # Must be reachable from clients!!!
```

If you find that docker keeps caching your images with incorrect env, you can make use of an additional environment variable, **`CACHE_INVALIDATOR`**. Simply navigate to the environment variables tab again, and put a random value as the value of that variable in there, a nice one would be the current timestamp, as shown used in the section below for the same purpose.

> 🔁 The frontend must be configured to connect to the correct WebSocket URL (`VITE_APP_WS_SERVER_URL`) — typically `wss://collab.example.com`.

---

## 🧪 Local Self-Hosting

You can run the stack locally with port mappings:

```bash
docker compose --env-file .env.local up --build -d
```

* Frontend available at: [http://localhost:8080](http://localhost:8080)
* Collab server available at: [ws://localhost:8081](ws://localhost:8081)
- The --env-file flag is optional. By default it will use .env
- Remove -d flag if you want to run this stack in the foreground.

However if you find that docker keep caching your images, you can try:
```
CACHE_INVALIDATOR=$(date +%s) docker compose up --build --force-recreate
```
This prevents docker from reusing its cache, which might solve your problems, e.g. Changes in environment variables.

---

## 🧼 Stopping the stack
To stop the stack, simply
```bash
docker compose down
```
---
