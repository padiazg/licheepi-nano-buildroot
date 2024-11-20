# use this to iterate on changes to config without rebuilding the entire
# image from scratch; ensure to clean the right stamps/folders to correctly
# trigger rebuild with Buildroot
ARG BASE_IMAGE=unframework/licheepi-nano-buildroot
ARG BASE_VERSION=latest
ARG BUILDROOT_BASE=/root
ARG BR2_CONFIGFILE=licheepi_nano_spiflash_defconfig

FROM $BASE_IMAGE:$BASE_VERSION AS local
ARG BUILDROOT_BASE
ARG BR2_CONFIGFILE

# copy newest version of local files
WORKDIR $BUILDROOT_BASE/licheepi-nano
COPY board/ board/
COPY configs/ configs/
COPY \
    Config.in \
    external.desc \
    external.mk \
    ./
RUN chmod +x board/licheepi_nano/post-image.sh
RUN ln -sf $BUILDROOT_BASE/buildroot/output/host/bin/genimage /usr/bin/genimage

# reset Buildroot config and trigger Linux kernel rebuild
WORKDIR $BUILDROOT_BASE/buildroot
RUN BR2_EXTERNAL=$BUILDROOT_BASE/licheepi-nano make $BR2_CONFIGFILE
RUN cd output/build/uboot-custom/ && rm .stamp_built .stamp_*installed
RUN cd output/build/linux-custom && rm .stamp_dotconfig .stamp_configured .stamp_built .stamp_*installed
RUN cd output/build/host-uboot-tools-2021.07 && rm .stamp_built .stamp_*installed
RUN cd output/build/linux-firmware-20221214/ && rm .stamp_built .stamp_*installed

# re-run build
RUN make

# expose built image files in standalone root folder
FROM scratch AS localout
ARG BUILDROOT_BASE
COPY --from=local $BUILDROOT_BASE/buildroot/output/images/ .
