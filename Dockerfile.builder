FROM archlinux:latest

# Update system and install build dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      base-devel \
      git \
      archiso \
      qemu-guest-agent \
      edk2-shell \
      dosfstools \
      libisoburn \
      squashfs-tools \
      grub \
      efibootmgr \
      mtools

# Create build directory
WORKDIR /build

# Copy in the Omarchy repo
COPY . /build/omarchy

WORKDIR /build/omarchy

# Default command for interactive shell
CMD ["/bin/bash"]
