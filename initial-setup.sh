#!/bin/sh

CURRENT_VERSION="1.0.0"
NEW_VERSION="1.1.0"
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MainFunction() 
{
    cd ..
    # DeletePreviousOutput
    # BuildLocalNugetPackages
    # BuildDockerImages
    StartDockerServices
    StartFirefox
}

DeletePreviousOutput() {
    if [ -e output.log ]
    then        
        echo -e "${YELLOW}Deleting output.log${NC}"
        rm output.log
    else        
        echo -e "${YELLOW}output.log not found${NC}"
    fi
}

BuildLocalNugetPackages() {
    RemovePackagesFolder
    BuildPackage "Redirect Middleware" "./redirect/src/asg.redirect/asg.redirect.csproj" "./redirect/src/asg.redirect/bin/"
    BuildPackage "DbMigrator" "./dbMigrator/src/asg.dbmigrator/asg.dbmigrator.csproj" "./dbMigrator/src/asg.dbmigrator/bin/"
}

RemovePackagesFolder() {
    echo -e "${YELLOW}Removing packages Folder${NC}"
    rm -rf ./packages

    echo -e "${YELLOW}Creating packages Folder${NC}"
    mkdir packages
}

BuildPackage() {
    echo -e "${YELLOW}Building $1 NuGet package ${NC}"
    dotnet clean $2 -c Debug >> output.log
    dotnet build $2 -c Debug >> output.log
}

BuildDockerImages() {
    BuildDockerImage "simplebudget/identity:${NEW_VERSION}" "./identity/src/asg.identity/containers/dockerfile.dev"       
    UpdateDockerCompose "Identity Image" "simplebudget\/identity"

    BuildDockerImage "simplebudget/identity/dbmigrator:${NEW_VERSION}" "./identity/src/asg.identity.data.migrator/containers/dockerfile.dev"
    
    UpdateBaseImageVersion ./identity/src/asg.identity.data.migrator/containers/migrate/dockerfile.dev
    BuildDockerImage "simplebudget/identity/dbmigrator:migrate-${NEW_VERSION}" "./identity/src/asg.identity.data.migrator/containers/migrate/dockerfile.dev"
    UpdateDockerCompose "Identity Db Migrator Migrate Image" "simplebudget\/identity\/dbmigrator:migrate-"

    UpdateBaseImageVersion ./identity/src/asg.identity.data.migrator/containers/watch/dockerfile.dev
    BuildDockerImage "simplebudget/identity/dbmigrator:watch-${NEW_VERSION}" "./identity/src/asg.identity.data.migrator/containers/watch/dockerfile.dev"
    UpdateDockerCompose "Identity Db Migrator Watch Image" "simplebudget\/identity\/dbmigrator:watch-"

    BuildDockerImage "simplebudget/api:${NEW_VERSION}" "./api/src/simple-budget.api/containers/dockerfile.dev"   
    UpdateDockerCompose "Api Image" "simplebudget\/api"

    BuildDockerImage "simplebudget/api/dbmigrator:${NEW_VERSION}" "./api/src/simple-budget.api.data.migrator/containers/dockerfile.dev"
    
    UpdateBaseImageVersion ./api/src/simple-budget.api.data.migrator/containers/migrate/dockerfile.dev
    BuildDockerImage "simplebudget/api/dbmigrator:migrate-${NEW_VERSION}" "./api/src/simple-budget.api.data.migrator/containers/migrate/dockerfile.dev"
    UpdateDockerCompose "Api Db Migrator Migrate Image" "simplebudget\/api\/dbmigrator:migrate-"

    UpdateBaseImageVersion ./api/src/simple-budget.api.data.migrator/containers/watch/dockerfile.dev
    BuildDockerImage "simplebudget/api/dbmigrator:watch-${NEW_VERSION}" "./api/src/simple-budget.api.data.migrator/containers/watch/dockerfile.dev"
    UpdateDockerCompose "Api Db Migrator Watch Image" "simplebudget\/api\/dbmigrator:watch-"

    BuildDockerImage "simplebudget/bff:${NEW_VERSION}" "./bff/src/simple-budget.bff/containers/dockerfile.dev"  
    UpdateDockerCompose "BFF Image" "simplebudget\/bff" 
}

# $1 - Image name for logging
# $2 - path to file
BuildDockerImage() {
    echo -e "${YELLOW}Starting to build image: $1${NC}"
    docker build -t $1 -f $2 . >> output.log 2>&1
    echo -e "${YELLOW}image: $1 built.${NC}"
}

UpdateBaseImageVersion() {
    echo -e "${YELLOW}Updating base image version - $1${NC}"
    sed -i "s/$CURRENT_VERSION/$NEW_VERSION/g" $1
}

#simplebudget\/identity\/dbmigrator:migrate
UpdateDockerCompose() {    
    echo -e "${YELLOW}Updating Docker-Compose.yml $1 ${NC}"
    CURRENT_MIGRATE_IMAGE_NAME="$2:${CURRENT_VERSION}"
    NEW_MIGRATE_IMAGE_NAME="$2:${NEW_VERSION}"
    sed -i "s/$CURRENT_MIGRATE_IMAGE_NAME/$NEW_MIGRATE_IMAGE_NAME/g" ./simple-budget/docker-compose.yml    
}

StartDockerServices() {
    echo -e "${YELLOW}Starting Docker Services ${NC}"
    cd simple-budget
    docker-compose up -d --wait
}

StartFirefox() {
    echo -e "${YELLOW}Starting Web browser ${NC}"
    #start firefox https://localhost:3100 https://localhost:3101/swagger https://localhost:3102/swagger https://localhost:3103
    start firefox https://localhost:3101/swagger https://localhost:3102/swagger https://localhost:3103 https://localhost:3104
}

MainFunction