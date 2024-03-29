#!/bin/sh

CURRENT_VERSION="1.10.0"
NEW_VERSION="1.12.0"
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MainFunction() 
{
    cd ..
    DeleteFolders
    DeletePreviousOutput
    BuildLocalNugetPackages
    BuildDockerImages
    StartVsCode
}
DeleteFolders() {
    echo -e "${YELLOW}Cleaning up bin and obj folders${NC}"
    find . -type d -name bin -prune -exec -rm -rf {} \; >> output.log 2>&1
    find . -type d -name obj -prune -exec -rm -rf {} \; >> output.log 2>&1
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
    BuildDockerImage "simplebudget/react-ui:${NEW_VERSION}" "./ui.react/Dockerfile.dev"
    UpdateDockerCompose "UI.React Image" "simplebudget\/react-ui:" 

    BuildDockerImage "simplebudget/bff:${NEW_VERSION}" "./bff/src/simple-budget.bff/containers/dockerfile.dev"  
    UpdateDockerCompose "BFF Image" "simplebudget\/bff:" 

    BuildDockerImage "simplebudget/api:${NEW_VERSION}" "./api/src/simple-budget.api/containers/dockerfile.dev"   
    UpdateDockerCompose "Api Image" "simplebudget\/api:"

    BuildDockerImage "simplebudget/identity:${NEW_VERSION}" "./identity/src/asg.identity/containers/dockerfile.dev"       
    UpdateDockerCompose "Identity Image" "simplebudget\/identity:"

    BuildDockerImage "simplebudget/identity/dbmigrator:${NEW_VERSION}" "./identity/src/asg.identity.data.migrator/containers/dockerfile.dev"
    BuildDockerImage "simplebudget/api/dbmigrator:${NEW_VERSION}" "./api/src/simple-budget.api.data.migrator/containers/dockerfile.dev"
    
    UpdateBaseImageVersion ./identity/src/asg.identity.data.migrator/containers/migrate/dockerfile.dev
    BuildDockerImage "simplebudget/identity/dbmigrator-migrate:${NEW_VERSION}" "./identity/src/asg.identity.data.migrator/containers/migrate/dockerfile.dev"
    UpdateDockerCompose "Identity Db Migrator Migrate Image" "simplebudget\/identity\/dbmigrator-migrate:"

    UpdateBaseImageVersion ./identity/src/asg.identity.data.migrator/containers/watch/dockerfile.dev
    BuildDockerImage "simplebudget/identity/dbmigrator-watch:${NEW_VERSION}" "./identity/src/asg.identity.data.migrator/containers/watch/dockerfile.dev"
    UpdateDockerCompose "Identity Db Migrator Watch Image" "simplebudget\/identity\/dbmigrator-watch:"

    
    UpdateBaseImageVersion ./api/src/simple-budget.api.data.migrator/containers/migrate/dockerfile.dev
    BuildDockerImage "simplebudget/api/dbmigrator-migrate:${NEW_VERSION}" "./api/src/simple-budget.api.data.migrator/containers/migrate/dockerfile.dev"
    UpdateDockerCompose "Api Db Migrator Migrate Image" "simplebudget\/api\/dbmigrator-migrate:"

    UpdateBaseImageVersion ./api/src/simple-budget.api.data.migrator/containers/watch/dockerfile.dev
    BuildDockerImage "simplebudget/api/dbmigrator-watch:${NEW_VERSION}" "./api/src/simple-budget.api.data.migrator/containers/watch/dockerfile.dev"
    UpdateDockerCompose "Api Db Migrator Watch Image" "simplebudget\/api\/dbmigrator-watch:"
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

UpdateDockerCompose() {    
    echo -e "${YELLOW}Updating Docker-Compose.yml $1 ${NC}"
    CURRENT_MIGRATE_IMAGE_NAME="$2${CURRENT_VERSION}"
    NEW_MIGRATE_IMAGE_NAME="$2${NEW_VERSION}"
    sed -i "s/$CURRENT_MIGRATE_IMAGE_NAME/$NEW_MIGRATE_IMAGE_NAME/g" ./simple-budget/docker-compose.yml    
}

StartVsCode() {
    echo -e "${YELLOW}Starting VsCode SimpleBudget multi-root workspace${NC}"
    echo -e "${YELLOW}use launch-services.sh to start docker services${NC}"
    cd simple-budget
    code SimpleBudget.code-workspace
}

MainFunction