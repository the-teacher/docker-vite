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

# docker run -ti iamteacher/vite:arm64 bash
# uname -m => aarch64

# docker run -ti iamteacher/vite:amd64 bash
# uname -m => x86_64
