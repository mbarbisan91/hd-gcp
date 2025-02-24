FROM golang:1.20 AS build
WORKDIR /app
COPY . .
RUN GOOS=linux GOARCH=amd64 go build -o server server.go

FROM gcr.io/distroless/base
WORKDIR /app
COPY --from=build /app/server .
EXPOSE 8080
CMD ["/app/server"]