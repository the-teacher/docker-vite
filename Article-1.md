# Vite, Yarn and Vue with Docker

Today I'm starting learning a new project and its' frontend part. I should say I never worked with Vue before and I need to make a playground to experiment with it and learn it from practice.

My first idea is to setup a Docker container with some specific versions of Javascript based tools and play with the code a bit. Later I can extend my experience on a real project.

Let's start.

### Step 1. Create a Project

`mkdir docker-vite` and `cd docker-vite`

### Step 2. Create Project's structure

```
├── README.md
├── Vite.Dockerfile
├── docker-compose.yml
└── shell
    └── build.sh
```

`shell` folder will contain some shell helpers to automate some routine processes. Like build a docker image or push an image to `hub.docker.com`

### Step 3. Prepare a Docker Image

In `Vite.Dockerfile` I have the following

Original image I found here [jitesoft/node-yarn](https://hub.docker.com/r/jitesoft/node-yarn)

```Dockerfile
# VITE | NODE 20 + YARN 3.5+
FROM --platform=$BUILDPLATFORM jitesoft/node-yarn:20

ARG TARGETARCH
ARG BUILDPLATFORM

RUN echo "$BUILDPLATFORM" > /BUILDPLATFORM
RUN echo "$TARGETARCH" > /TARGETARCH

RUN yarn set version berry
RUN mkdir -p /home/app
WORKDIR /home/app

EXPOSE 4000

CMD ["/bin/sh"]
```

### Step 4. Building the Image

Now I'm building the image

```bash
docker build \
  -t iamteacher/vite:arm64 \
  -f Vite.Dockerfile \
  --build-arg BUILDPLATFORM="linux/arm64" \
  --build-arg TARGETARCH="arm64" \
  .
```

**console output is:**

```bash
the-teacher@macbook docker-vite:: $ docker build \
>   -t iamteacher/vite:arm64 \
>   -f Vite.Dockerfile \
>   --build-arg BUILDPLATFORM="linux/arm64" \
>   --build-arg TARGETARCH="arm64" \
>   .
[+] Building 0.1s (10/10) FINISHED
 => [internal] load build definition from Vite.Dockerfile                                                               0.0s
 => => transferring dockerfile: 42B                                                                                     0.0s
 => [internal] load .dockerignore                                                                                       0.0s
 => => transferring context: 2B                                                                                         0.0s
 => [internal] load metadata for docker.io/jitesoft/node-yarn:20                                                        0.0s
 => [1/6] FROM docker.io/jitesoft/node-yarn:20                                                                          0.0s
 => CACHED [2/6] RUN echo "linux/arm64" > /BUILDPLATFORM                                                                0.0s
 => CACHED [3/6] RUN echo "arm64" > /TARGETARCH                                                                         0.0s
 => CACHED [4/6] RUN yarn set version berry                                                                             0.0s
 => CACHED [5/6] RUN mkdir -p /home/app                                                                                 0.0s
 => CACHED [6/6] WORKDIR /home/app                                                                                      0.0s
 => exporting to image                                                                                                  0.0s
 => => exporting layers                                                                                                 0.0s
 => => writing image sha256:d99d23d1ac58af0fad10c7c0868e7bb7f4d1636e7627f999a9e7b2a1f071e328                            0.0s
 => => naming to docker.io/iamteacher/vite:arm64
```

### Step 5. Simple Image Building Automatization

To make re-building process simpler I create a bash file that I'm going to use later

`shell/build.sh`

```bash
# Run from the root of the project
#
# source shell/build.sh

docker build \
  -t iamteacher/vite:arm64 \
  -f Vite.Dockerfile \
  --build-arg BUILDPLATFORM="linux/arm64" \
  --build-arg TARGETARCH="arm64" \
  .

docker build \
  -t iamteacher/vite:amd64 \
  -f Vite.Dockerfile \
  --build-arg BUILDPLATFORM="linux/amd64" \
  --build-arg TARGETARCH="amd64" \
  .
```

### Step 6. Checking the Image and Software

Let's jump in to the container and check if it works correctly.


```bash
docker run -ti iamteacher/vite:arm64
```

### Step 7. In the Container

```bash
/home/app # pwd
/home/app

/home/app # node -v
v20.0.0

/home/app # yarn -v
3.5.0

/home/app # npm -v
9.6.4

/home/app # exit
```

### Step 8. Docker compose

Now it is time for writing `docker-compose.yml`.

For now I have nothing to run with `node` in my project. I want just to start a container, link with my current folder and initiate a `node` project.

```yml
# docker compose -f docker-compose.yml up

version: '3.9'

name: vite_docker

services:
  # Port: 4000
  vite:
    tty: true
    image: iamteacher/vite:arm64
    ports:
      - 4000:4000
    volumes:
      - .:/home/app
```

And now let's run the container with using `docker compose`

```bash
docker-vite:: $ docker compose -f docker-compose.yml up
[+] Running 1/0
 ⠿ Container vite_docker-vite-1  Created                                                                                0.0s
Attaching to vite_docker-vite-1
```

### Step 9. Initiate Yarn/Vue Project

```bash
$ docker exec -ti vite_docker-vite-1 sh
```

Now we are inside the container. Let's check that container is linked to our `HOST filesystem`.

Yes, inside the container we see all files of our project.

Command: `ls`

```bash
/home/app # ls
  README.md
  Vite.Dockerfile
  docker-compose.yml
  shell
```

Command: `yarn create vite`

```bash
/home/app # yarn create vite

➤ YN0000: ┌ Resolution step
➤ YN0000: └ Completed in 5s 66ms
➤ YN0000: ┌ Fetch step
➤ YN0013: │ create-vite@npm:4.2.0 can't be found in the cache and will be fetched from the remote registry
➤ YN0000: └ Completed in 0s 407ms
➤ YN0000: ┌ Link step
➤ YN0000: │ ESM support for PnP uses the experimental loader API and is therefore experimental
➤ YN0000: └ Completed
➤ YN0000: Done with warnings in 5s 520ms
```

- Project name: `vite-project`
- Framework: `Vue`
- Variant: `TypeScript`

```bash
✔ Project name: … vite-project
? Select a framework: › - Use arrow-keys. Return to submit.
    Vanilla
❯   Vue
    React
    Preact
    Lit
    Svelte
    Others
```

```
? Select a variant: › - Use arrow-keys. Return to submit.
    JavaScript
❯   TypeScript
    Customize with create-vue ↗
    Nuxt ↗
```

On this step I have the following error:

```bash
LibzipError [Libzip Error]: Can't open file: No file descriptors available
    at ZipFS.makeLibzipError (/tmp/xfs-eed97368/dlx-1414/.pnp.cjs:1675:25)
    at new ZipFS (/tmp/xfs-eed97368/dlx-1414/.pnp.cjs:1650:20)
    at ZipOpenFS.getZipSync (/tmp/xfs-eed97368/dlx-1414/.pnp.cjs:3840:18)
    at ZipOpenFS.makeCallSync (/tmp/xfs-eed97368/dlx-1414/.pnp.cjs:3720:17)
    at ZipOpenFS.readdirSync (/tmp/xfs-eed97368/dlx-1414/.pnp.cjs:3613:17)
    at VirtualFS.readdirSync (/tmp/xfs-eed97368/dlx-1414/.pnp.cjs:2861:24)
    at PosixFS.readdirSync (/tmp/xfs-eed97368/dlx-1414/.pnp.cjs:2861:24)
    at NodePathFS.readdirSync (/tmp/xfs-eed97368/dlx-1414/.pnp.cjs:2861:24)
    at Jr (file:///root/.yarn/berry/cache/create-vite-npm-4.2.0-11226b5ec8-8.zip/node_modules/create-vite/dist/index.mjs:49:180)
    at process.processTicksAndRejections (node:internal/process/task_queues:95:5) {
  code: 'ZIP_ER_OPEN'
}
```

### Step 10. Second Attempt

After having the error I'm trying to rerun the create command. This time everything goes successfully.

```bash
/home/app # yarn create vite
```

```bash
✔ Project name: … vite-project
✔ Select a framework: › Vue
✔ Select a variant: › TypeScript

Scaffolding project in /home/app/vite-project...

Done. Now run:

  cd vite-project
  yarn
  yarn dev
```

```bash
/home/app # ls -al vite-project/
total 28
drwxr-xr-x   12 root     root           384 Apr 20 10:30 .
drwxr-xr-x    9 root     root           288 Apr 20 10:27 ..
-rw-r--r--    1 root     root           253 Apr 20 10:30 .gitignore
drwxr-xr-x    3 root     root            96 Apr 20 10:30 .vscode
-rw-r--r--    1 root     root          1527 Apr 20 10:30 README.md
-rw-r--r--    1 root     root           362 Apr 20 10:30 index.html
-rw-r--r--    1 root     root           381 Apr 20 10:30 package.json
drwxr-xr-x    3 root     root            96 Apr 20 10:30 public
drwxr-xr-x    8 root     root           256 Apr 20 10:30 src
-rw-r--r--    1 root     root           488 Apr 20 10:30 tsconfig.json
-rw-r--r--    1 root     root           184 Apr 20 10:30 tsconfig.node.json
-rw-r--r--    1 root     root           157 Apr 20 10:30 vite.config.ts
```

### Step 11. The issue with `yarn .lock`

When I do

```bash
  cd vite-project
  yarn
```

I see the following:

```bash
Usage Error: The nearest package directory (/home/app/vite-project) doesn't seem to be part of the project declared in /.

- If / isn't intended to be a project, remove any yarn.lock and/or package.json file there.
- If / is intended to be a project, it might be that you forgot to list home/app/vite-project in its workspace configuration.
- Finally, if / is fine and you intend home/app/vite-project to be treated as a completely separate project (not even a workspace), create an empty yarn.lock file in it.
```

I use the last one option - creating an empty `yarn.lock`

Command: `touch yarn.lock`

```
  touch yarn.lock
  yarn install
```

Now I see:

```bash
/home/app/vite-project # yarn install
➤ YN0000: ┌ Resolution step
➤ YN0061: │ sourcemap-codec@npm:1.4.8 is deprecated: Please use @jridgewell/sourcemap-codec instead
➤ YN0032: │ fsevents@npm:2.3.2: Implicit dependencies on node-gyp are discouraged
➤ YN0061: │ @npmcli/move-file@npm:2.0.1 is deprecated: This functionality has been moved to @npmcli/fs
➤ YN0002: │ @volar/vue-typescript@npm:1.3.19 doesn't provide typescript (p5c1ac), requested by @volar/typescript
➤ YN0000: │ Some peer dependencies are incorrectly met; run yarn explain peer-requirements <hash> for details, where <hash> is the six-letter p-prefixed code
➤ YN0000: └ Completed in 3s 997ms
➤ YN0000: ┌ Fetch step
➤ YN0013: │ which@npm:2.0.2 can't be found in the cache and will be fetched from the remote registry
➤ YN0013: │ wide-align@npm:1.1.5 can't be found in the cache and will be fetched from the remote registry
➤ YN0013: │ wrappy@npm:1.0.2 can't be found in the cache and will be fetched from the remote registry
➤ YN0013: │ yallist@npm:4.0.0 can't be found in the cache and will be fetched from the remote registry
➤ YN0013: │ typescript@npm:4.9.5 can't be found in the cache and will be fetched from the remote registry
➤ YN0000: └ Completed in 29s 909ms
➤ YN0000: ┌ Link step
➤ YN0000: │ ESM support for PnP uses the experimental loader API and is therefore experimental
➤ YN0007: │ esbuild@npm:0.17.17 must be built because it never has been before or the last one failed
➤ YN0000: └ Completed in 1s 70ms
➤ YN0000: Done with warnings in 35s 8ms
```

### Step 12. Running VITE

Now I'm running VITE:

Command: `yarn dev`

```bash
# yarn dev

  VITE v4.3.0  ready in 604 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h to show help
```

From it I decide I need to change the port and expose my app. Let's try the following:

Command: `yarn dev --host --port 4000`

```
# yarn dev --host --port 4000

  VITE v4.3.0  ready in 584 ms

  ➜  Local:   http://localhost:4000/
  ➜  Network: http://172.22.0.2:4000/
```

Great! It's alive!


![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/oe94y4tpr2z14ot6xu2b.png)

We can stop the project. `CMD+C`

### Step 13. Updating `docker-compose.yml`

Now, when we have a VITE project and it works I want to update my `docker-compose.yml` to make things more adjusted to each other.

I add a new line

```
command: yarn dev --host --port 4000
```

and also change `volumes` section

```
volumes:
  - ./vite-project:/home/app
```

For now `docker-compose.yml` looks so:

```bash
# docker compose -f docker-compose.yml up

version: '3.9'

name: vite_docker

services:
  # Port: 4000
  vite:
    tty: true
    image: iamteacher/vite:arm64
    command: yarn dev --host --port 4000
    ports:
      - 4000:4000
    volumes:
      - ./vite-project:/home/app
```

### Step 14. Running and saving the results

I'm going to run the project one more time to check if everything goes well.

```bash

$ docker compose -f docker-compose.yml up

[+] Running 1/1
 ⠿ Container vite_docker-vite-1

vite_docker-vite-1  |   VITE v4.3.0  ready in 619 ms
vite_docker-vite-1  |
vite_docker-vite-1  |   ➜  Local:   http://localhost:4000/
vite_docker-vite-1  |   ➜  Network: http://172.22.0.2:4000/
vite_docker-vite-1  |   ➜  press h to show help
```

The project is available on `http://localhost:4000` without any additional actions.

Let's add some lines in `.gitignore`

```bash
node_modules
.yarn
```

And save with git and push to github -- [docker-vite](https://github.com/the-teacher/docker-vite)

### UPD

If you want to integrate your Vite project into an existed App, you probably need to have a `manifest.json` file.

To have it you should add `--manifest` flag when you compile `production` build, or add the same flag in `vite.config.ts`

```js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

const viteConfig = defineConfig({
  build: {
    manifest: true
  },
  plugins: [vue()],
})

export default viteConfig
```
