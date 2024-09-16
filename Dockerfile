ARG GO_VERSION=1.22.3
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION} AS build
WORKDIR /src

RUN --mount=type=cache,target=/go/pkg/mod/ \
	--mount=type-bind,target=, \
	CGO_ENABLED=0 GOARCH=$TARGETARCH go build -o /bin/server .

ARG UID=10001
RUN adduser \
	--disabled-password \
	--gecos "" \
	--home "/nonexistent" \
	--shell "/sbin/nologin" \
	--no-create-home \
	--uid "${UID}" \
	appuser
USER appuser

COPY --from-build /bin/server /bin
COPY ./migrations ./migrations
COPY ./templates ./templates
COPY ./static ./static

ENV MIGRATRIONS_URL=file://migrations

EXPOSE 8080

ENTRYPOINT [ "/bin/server" ]
