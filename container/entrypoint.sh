#!/bin/sh

update-ca-certificates #update the certificates for the container
dotnet nuget add source /app/packages -n local # add local source
sh ./src/entrypoint.sh