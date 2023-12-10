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
docker-compose -f "docker-compose.yml" up -d api 
```
# SQL Server

## Connect SSMS
Server name: 127.0.0.1,3106
login: sa
password: from ENV file

# Git

## Enable prune behaviour for every fetch
[StackOverflow](https://stackoverflow.com/a/68049939/2426627)

```
git config --global fetch.prune true
```

## Ignore updates to environment variable files

to get git to ignore updates to file
```
git update-index --skip-worktree identity.env
```

to enable git to capture updates to the file
```
git update-index --no-skip-worktree identity.env
```

Execute git-skip-worktree-envs.sh to tell git to ignore all the env files. 
```
sh git-skip-worktree-envs.sh
```

like wise, execute the git-no-skip-worktree-envs script to tell git to capture changes.

```
sh git-no-skip-worktree-envs.sh
```