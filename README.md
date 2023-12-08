# Docker Commands

## Docker build command

```
docker build -t <imagename> -f Dockerfile.dev .
```

-t 
: names the image

-f
: uses the specified docker file

## Docker run command to test the image
```
docker run --rm -it -p externalport:internalport <imagename>:<tag> 
```

## Docker compose command
```
docker compose  -f "simple-budget\docker-compose.yml" up -d db seq identity 
```
# SQL Server

## Connect SSMS
Server name: 127.0.0.1,3106
login: sa
password: from ENV file