ARG BUILDER_IMAGE=swift
ARG RUNTIME_IMAGE=swift

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev && \
    rm -r /var/lib/apt/lists/*

ARG SWIFTLINT_REVISION=master
RUN git clone --branch ${SWIFTLINT_REVISION} https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    swift build --configuration release -Xswiftc -static-stdlib -Xlinker -lCFURLSessionInterface -Xlinker -lCFXMLInterface -Xlinker -lcurl -Xlinker -lxml2 && \
    mv `swift build --configuration release -Xswiftc -static-stdlib --show-bin-path`/swiftlint /usr/bin && \
    cd .. && \
    rm -rf SwiftLint

FROM ${RUNTIME_IMAGE}

LABEL maintainer "Angel Aviel Domaoan <dev.tenshiamd@gmail.com>"

COPY --from=builder /usr/bin/swiftlint /usr/bin

RUN swiftlint version

CMD ["swiftlint"]
