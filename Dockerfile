FROM dr.api.no/amedia/go-app:1.12.5-0 AS build_base

RUN mkdir -p /app/build
WORKDIR /app/build

COPY go.mod .
COPY go.sum .
RUN go mod download

FROM build_base AS build

WORKDIR /app/build
COPY --from=build_base /app/build .
COPY . .

ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOARCH amd64

RUN go build -a -installsuffix cgo -o /app/bin/falaffel .

# ----------------------------------------------------
# Release stage
# ----------------------------------------------------

FROM alpine:3.10 AS release

ENV LC_ALL=en_US.UTF-8
ENV LC_LANG=en_US.UTF-8
ENV LC_LANGUAGE=en_US.UTF-8

# Copy the application binary over
COPY --from=build /app/bin/ /app/bin

WORKDIR /app
ENTRYPOINT ["/app/bin/falaffel"]

EXPOSE 8080
