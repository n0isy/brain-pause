FROM alpine:3.20 AS build
RUN apk add --no-cache binutils
WORKDIR /src
COPY pause.S .
RUN as --64 -o pause.o pause.S \
 && ld -static -s -n --build-id=none --gc-sections -o pause pause.o

FROM scratch
COPY --from=build /src/pause /pause
STOPSIGNAL SIGTERM
ENTRYPOINT ["/pause"]
