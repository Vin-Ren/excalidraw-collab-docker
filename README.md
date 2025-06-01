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

### Directly Building on Dokploy
> [!WARNING]
> Directly building on dokploy might result in your machine becoming unresponsive in lower spec systems (Tested in a VPS with 2 cores and 4 GB ram).

When deploying with [Dokploy](https://dokploy.com/), Traefik should automatically pick up routing rules from the labels defined in `docker-compose.yml`. No manual reverse proxy setup needed.

You should choose the compose service and import this repository as your source.

Make sure to pass all the environment variables you'd like to change at the environment tab. These are the required environment variables if you are deploying with dokploy:
```sh
EXCALIDRAW_DOMAIN=draw.example.com
COLLAB_DOMAIN=collab.example.com
VITE_APP_WS_SERVER_URL=wss://collab.example.com # Must be reachable from clients!!!
```
> 🔁 The frontend must be configured to connect to the correct WebSocket URL (`VITE_APP_WS_SERVER_URL`) — typically `wss://collab.example.com`.


If you find that docker keeps caching your images with incorrect env, you can make use of an additional environment variable, **`CACHE_INVALIDATOR`**. Simply navigate to the environment variables tab again, and put a random value as the value of that variable in there, a nice one would be the current timestamp, as shown used in the section below for the same purpose.


### Building on Local, Avoid Build on Dokploy
While the configurations above are enough to set you up and running, your dokploy hosting machine could froze due to high load during excalidraw's docker image build. To avoid this, this project also comes with another docker compose file to use. Below we will go through how to build on your local machine, uploading it to an registry, and setting it up on dokploy.

#### 1. Building Locally
Change the existing `.env` file, these values should correspond to your deployment to be:
```sh
EXCALIDRAW_DOMAIN=draw.example.com
COLLAB_DOMAIN=collab.example.com
VITE_APP_WS_SERVER_URL=wss://collab.example.com # Must be reachable from clients!!!
```

Then run this to build the image:
```sh
docker compose build --no-cache
```

After building, run `docker images` and you should see a new image entry:
```
REPOSITORY                              TAG       IMAGE ID       CREATED             SIZE
....
excalidraw-collab-docker-excalidraw     latest    abcdef012345   1 minutes ago      93.4MB
....
``` 

We are interested in the image named `excalidraw-collab-docker-excalidraw`. This might be different if you cloned this repository with a different directory name, however, the image name should have `-excalidraw` as its suffix.

Then depending on where you'd like to upload this, either a public or a private registry, the procedure of login could be different. Here I'll give an example of using dockerhub.

Register yourself on dockerhub first. Then navigate to `Account Settings > Personal access token`, then create one and follow the instructions there to log in on your local device.

We give a tag for this image, to be pushable to dockerhub, simply follow the format `<your-docker-hub-username>/<image-name>:latest` like below:
```sh
docker tag excalidraw-collab-docker-excalidraw vinren/excalidraw-collab:latest
```

Then push that image to docker hub like so
```sh
docker push vinren/excalidraw-collab:latest
```

Your excalidraw image is now up on dockerhub as!


Now we need to use that image for deployment on dokploy.
Create a new Compose Service, then select your fork of this repository and change `Compose Path` from `./docker-compose.yml` to `./docker-compose-self-built.yml`.

To reference your uploaded image, go to the environment tab, and add a new line `EXCALIDRAW_IMAGE=<your-uploaded-image-tag>`, which in my case is `EXCALIDRAW_IMAGE=vinren/excalidraw-collab:latest`.

Now simply click on Deploy, and while we wait, we'll set up the DNS. Go to the Domains tab, click on Add Domain, and pick a service and their supposed domains according to your `EXCALIDRAW_DOMAIN` and `COLLAB_DOMAIN` variables when building these images, both of these will be running at port 80, and generate certs adjusts to your deployments.

Voila, your self-hosted Excalidraw with collab server is up and running!

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
