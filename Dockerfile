FROM public.ecr.aws/amazonlinux/amazonlinux:2023-minimal

ARG TARGETARCH

LABEL org.opencontainers.image.title="AWS Emulator" \
      org.opencontainers.image.description="Automated multi-arch container image for the official AWS Emulator" \
      org.opencontainers.image.url="https://github.com/Roslaan001/aws-emulator-docker" \
      org.opencontainers.image.source="https://github.com/Roslaan001/aws-emulator-docker" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN if [ "$TARGETARCH" = "arm64" ]; then \
      ARCH="aarch64"; \
    else \
      ARCH="x86_64"; \
    fi && \
    rpm -i https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/latest/aws-emulator-${ARCH}.rpm && \
    mkdir -p /home/emulator && chown -R 1000:1000 /home/emulator

USER 1000
ENV HOME=/home/emulator
EXPOSE 9297
ENTRYPOINT ["aws-emulator"]
CMD ["-b", "0.0.0.0", "-p", "9297", "-a", "off", "-t", "off"]
