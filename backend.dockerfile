# build backend
FROM golang:1.25 AS go-builder

WORKDIR /app

# Copy headers + built library from previous stage
COPY --from=core-builder /core/include/*.h /usr/local/include/
COPY --from=core-builder /core/build/*.so /usr/local/lib/

RUN ldconfig

COPY backend/go.mod backend/go.sum ./
RUN go mod download

COPY backend/. .

RUN CGO_ENABLED=1 GOOS=linux go build -o app ./cmd/api

# minimal runtime
FROM debian:bookworm-slim

WORKDIR /app

# Only runtime deps
COPY --from=go-builder /usr/local/lib/*.so /usr/local/lib/
COPY --from=go-builder /app/app .

RUN ldconfig

EXPOSE 6969

CMD ["./app"]