# This stage is responsible for holding onto
# your config without copying it directly into
# the final image
FROM scratch AS stage-files
COPY ./files /files


# Bins to install
# These are basic tools that are added to all images.
# Generally used for the build process. We use a multi
# stage process so that adding the bins into the image
# can be added to the ostree commits.
FROM scratch AS stage-bins
COPY --from=ghcr.io/sigstore/cosign/cosign:v2.4.3 /ko-app/cosign /bins/cosign
COPY --from=ghcr.io/blue-build/cli:latest-installer \
  /out/bluebuild /bins/bluebuild
# Keys for pre-verified images
# Used to copy the keys into the final image
# and perform an ostree commit.
#
# Currently only holds the current image's
# public key.
FROM scratch AS stage-keys
COPY cosign.pub /keys/AuroraMax-GameHack.pub


# Main image
FROM ghcr.io/ublue-os/aurora@sha256:b82e4a4002d178cf7de6263c0991bf7a304c47b4f6b0a4cfc2c35394d4317ed9 AS AuroraMax-GameHack
ARG RECIPE=recipe.yml
ARG IMAGE_REGISTRY=localhost
ARG CONFIG_DIRECTORY="/tmp/files"
ARG MODULE_DIRECTORY="/tmp/modules"
ARG IMAGE_NAME="AuroraMax-GameHack"
ARG BASE_IMAGE="ghcr.io/ublue-os/aurora"
ARG FORCE_COLOR=1
ARG CLICOLOR_FORCE=1
ARG RUST_LOG_STYLE=always
# Key RUN
RUN --mount=type=bind,from=stage-keys,src=/keys,dst=/tmp/keys \
  mkdir -p /etc/pki/containers/ \
  && cp /tmp/keys/* /etc/pki/containers/ \
  && ostree container commit

# Bin RUN
RUN --mount=type=bind,from=stage-bins,src=/bins,dst=/tmp/bins \
  mkdir -p /usr/bin/ \
  && cp /tmp/bins/* /usr/bin/ \
  && ostree container commit
RUN --mount=type=bind,from=ghcr.io/blue-build/nushell-image:default,src=/nu,dst=/tmp/nu \
  mkdir -p /usr/libexec/bluebuild/nu \
  && cp -r /tmp/nu/* /usr/libexec/bluebuild/nu/ \
  && ostree container commit
RUN --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:v0.9.12,src=/scripts/,dst=/scripts/ \
  /scripts/pre_build.sh

# Module RUNs
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/rpm-ostree:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:v0.9.12,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-AuroraMax-GameHack-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-AuroraMax-GameHack-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'rpm-ostree' '{"type":"rpm-ostree@latest","repos":[],"install":["gamescope","gamescope-session","mangohud","vkBasalt","gamemode","steam-devices","antimicrox","bottles","corectrl","piper"],"remove":[]}'
# "joystickwake","lutris"              <-- Temporarily Removed: COPR Repo not enabled (yet!)
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/default-flatpaks:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:v0.9.12,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-AuroraMax-GameHack-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-AuroraMax-GameHack-latest,sharing=locked \
# --> Added Lutris here as Flatpak, instead
  /tmp/scripts/run_module.sh 'default-flatpaks' '{"type":"default-flatpaks@latest","notify":true,"system":{"install":["com.valvesoftware.Steam","com.heroicgameslauncher.hgl","net.davidotek.pupgui2","net.lutris.Lutris","com.github.Matoking.protontricks"]}}'
# "io.github.benjamimgois.goverlay"    <-- Temporarily Removed: Flatpak not found (so far!)
# RUN \
# --mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
# --mount=type=bind,from=ghcr.io/blue-build/modules/systemd:latest,src=/modules,dst=/tmp/modules,rw \
# --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:v0.9.12,src=/scripts/,dst=/tmp/scripts/ \
#   --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-AuroraMax-GameHack-latest,sharing=locked \
#   --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-AuroraMax-GameHack-latest,sharing=locked \
#   /tmp/scripts/run_module.sh 'systemd' '{"type":"systemd@latest","system":{"enabled":["gamemoded.service"]}}'   <-- Temporarily Removed: Service not in current image (researching!)
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/files:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:v0.9.12,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-AuroraMax-GameHack-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-AuroraMax-GameHack-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'files' '{"type":"files@latest","files":[{"source":"usr","destination":"/usr"}]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/bling:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:v0.9.12,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-AuroraMax-GameHack-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-AuroraMax-GameHack-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'bling' '{"type":"bling@latest","install":["1password"]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/signing:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:v0.9.12,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-AuroraMax-GameHack-latest,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-AuroraMax-GameHack-latest,sharing=locked \
  /tmp/scripts/run_module.sh 'signing' '{"type":"signing@latest"}'

RUN --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:v0.9.12,src=/scripts/,dst=/scripts/ \
  /scripts/post_build.sh

# Labels are added last since they cause cache misses with buildah
LABEL org.blue-build.build-id="20d45189-56f8-4dd3-b2a1-88928fcf78e6"
LABEL org.opencontainers.image.title="AuroraMax-GameHack"
LABEL org.opencontainers.image.description="Gaming-focused Universal Blue custom image based on Aurora"
LABEL org.opencontainers.image.source=""
LABEL org.opencontainers.image.base.digest="sha256:b82e4a4002d178cf7de6263c0991bf7a304c47b4f6b0a4cfc2c35394d4317ed9"
LABEL org.opencontainers.image.base.name="ghcr.io/ublue-os/aurora:latest"
LABEL org.opencontainers.image.created="2025-05-28T03:01:27.200569243+00:00"
LABEL io.artifacthub.package.readme-url=https://raw.githubusercontent.com/blue-build/cli/main/README.md
