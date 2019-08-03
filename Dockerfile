
#build stage
FROM golang:alpine AS builder
WORKDIR /app
COPY . .
WORKDIR /app/backend/server
RUN apk add --no-cache git
RUN go get -d -v ./...
RUN go build -v -o app

#final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/backend/server/app /app
RUN mkdir -p temp
ENTRYPOINT ./app
EXPOSE 8080
