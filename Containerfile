ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-aurora}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-41}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS auroramax

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

# Copy any custom files
COPY files /

# Install additional gaming-related packages
RUN rpm-ostree install \
    gamescope \
    mangohud \
    vkBasalt \
    gamemode \
    gamescope-session \
    steam-devices \
    joystickwake \
    antimicrox \
    && \
    systemctl enable gamemoded.service && \
    rpm-ostree cleanup -m && \
    ostree container commit

# Set up proper metadata
RUN bootc container lint