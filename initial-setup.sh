#!/bin/sh

CURRENT_VERSION="0.0.18"
NEW_VERSION="1.0.0"

YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# navigate to root of the workspace
cd ..

#
# sed -i 's/original/new/g' file.txt
#
# Explanation:
#
#     sed = Stream EDitor
#     -i = in-place (i.e. save back to the original file)
#
#     The command string:
#         s = the substitute command
#         original = a regular expression describing the word to replace (or just the word itself)
#         new = the text to replace it with
#         g = global (i.e. replace all and not just the first occurrence)
#
#     file.txt = the file name
#

echo -e "${YELLOW}Removing packages Folder${NC}"
rm -rf ./packages

echo -e "${YELLOW}Creating packages Folder${NC}"
mkdir packages

# build redirect middleware
echo -e "${YELLOW}Building Redirect Middleware NuGet package${NC}"
dotnet build ./redirect/src/asg.redirect/asg.redirect.csproj -c Debug

# build DbMigrator
echo -e "${YELLOW}Building DbMigrator NuGet package${NC}"
dotnet build ./dbMigrator/src/asg.dbmigrator/asg.dbmigrator.csproj -c Debug

rm dockerlog1.txt
rm dockerlog2.txt
rm dockerlog3.txt
rm dockerlog4.txt
rm dockerlog5.txt
rm dockerlog6.txt

### Identity DB Migrator
echo -e "${YELLOW}Building Identity Db Migrator - Base image${NC}"
docker build -t simplebudget/identity/dbmigrator:${NEW_VERSION} -f ./identity/src/asg.identity.data.migrator/containers/dockerfile.dev . >> dockerlog1.txt
echo -e "${YELLOW}Identity Db Migrator image: identity/dbmigrator:${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating base image version${NC}"
sed -i "s/$CURRENT_VERSION/$NEW_VERSION/g" ./identity/src/asg.identity.data.migrator/containers/migrate/dockerfile.dev

echo -e "${YELLOW}Building Identity Db Migrator - Migrate image${NC}"
docker build -t simplebudget/identity/dbmigrator:migrate-${NEW_VERSION} -f ./identity/src/asg.identity.data.migrator/containers/migrate/dockerfile.dev . >> dockerlog2.txt
echo -e "${YELLOW}Identity Db Migrator image: identitydbmigrator:migrate-${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating docker-compose.yml - DbMigrator Migrate${NC}"
CURRENT_MIGRATE_IMAGE_NAME="simplebudget\/identity\/dbmigrator:migrate-${CURRENT_VERSION}"
NEW_MIGRATE_IMAGE_NAME="simplebudget\/identity\/dbmigrator:migrate-${NEW_VERSION}"
sed -i "s/$CURRENT_MIGRATE_IMAGE_NAME/$NEW_MIGRATE_IMAGE_NAME/g" ./simple-budget/docker-compose.yml

echo -e "${YELLOW}Updating base image version${NC}"
sed -i "s/$CURRENT_VERSION/$NEW_VERSION/g" ./identity/src/asg.identity.data.migrator/containers/watch/dockerfile.dev

echo -e "${YELLOW}Building Identity Db Migrator - Watch image${NC}"
docker build -t simplebudget/identity/dbmigrator:watch-${NEW_VERSION} -f ./identity/src/asg.identity.data.migrator/containers/watch/dockerfile.dev . >> dockerlog3.txt
echo -e "${YELLOW}Identity Db Migrator image: identitydbmigrator:watch-${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating docker-compose.yml - DbMigrator Watch${NC}"
CURRENT_WATCH_IMAGE_NAME="simplebudget\/identity\/dbmigrator:watch-${CURRENT_VERSION}"
NEW_WATCH_IMAGE_NAME="simplebudget\/identity\/dbmigrator:watch-${NEW_VERSION}"
sed -i "s/$CURRENT_WATCH_IMAGE_NAME/$NEW_WATCH_IMAGE_NAME/g" ./simple-budget/docker-compose.yml

### Identity

echo -e "${YELLOW}Building Identity image${NC}"
docker build -t simplebudget/identity:${NEW_VERSION} -f ./identity/src/asg.identity/containers/dockerfile.dev . >> dockerlog4.txt
echo -e "${YELLOW}Identity image: identity:${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating docker-compose.yml - Identity${NC}"
CURRENT_IDENTITY_IMAGE_NAME="simplebudget\/identity:${CURRENT_VERSION}"
NEW_IDENTITY_IMAGE_NAME="simplebudget\/identity:${NEW_VERSION}"
sed -i "s/$CURRENT_IDENTITY_IMAGE_NAME/$NEW_IDENTITY_IMAGE_NAME/g" ./simple-budget/docker-compose.yml

### Api DB Migrator - Base Image
echo -e "${YELLOW}Building Api Db Migrator - Base image${NC}"
docker build -t simplebudget/api/dbmigrator:${NEW_VERSION} -f ./api/src/simple-budget.api.data.migrator/containers/dockerfile.dev . >> dockerlog1.txt
echo -e "${YELLOW}Api Db Migrator image: api/dbmigrator:${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating base image version${NC}"
sed -i "s/$CURRENT_VERSION/$NEW_VERSION/g" ./api/src/simple-budget.api.data.migrator/containers/migrate/dockerfile.dev

### Api DB Migrator - Migrate Image
echo -e "${YELLOW}Building Api Db Migrator - Migrate image${NC}"
docker build -t simplebudget/api/dbmigrator:migrate-${NEW_VERSION} -f ./api/src/simple-budget.api.data.migrator/containers/migrate/dockerfile.dev . >> dockerlog2.txt
echo -e "${YELLOW}Api Db Migrator image: apidbmigrator:migrate-${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating docker-compose.yml - DbMigrator Migrate${NC}"
CURRENT_MIGRATE_IMAGE_NAME="simplebudget\/api\/dbmigrator:migrate-${CURRENT_VERSION}"
NEW_MIGRATE_IMAGE_NAME="simplebudget\/api\/dbmigrator:migrate-${NEW_VERSION}"
sed -i "s/$CURRENT_MIGRATE_IMAGE_NAME/$NEW_MIGRATE_IMAGE_NAME/g" ./simple-budget/docker-compose.yml

### Api DB Migrator - Watch Image
echo -e "${YELLOW}Updating base image version${NC}"
sed -i "s/$CURRENT_VERSION/$NEW_VERSION/g" ./api/src/simple-budget.api.data.migrator/containers/watch/dockerfile.dev

echo -e "${YELLOW}Building Identity Db Migrator - Watch image${NC}"
docker build -t simplebudget/identity/dbmigrator:watch-${NEW_VERSION} -f ./api/src/simple-budget.api.data.migrator/containers/watch/dockerfile.dev . >> dockerlog3.txt
echo -e "${YELLOW}API Db Migrator image: apidbmigrator:watch-${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating docker-compose.yml - DbMigrator Watch${NC}"
CURRENT_WATCH_IMAGE_NAME="simplebudget\/api\/dbmigrator:watch-${CURRENT_VERSION}"
NEW_WATCH_IMAGE_NAME="simplebudget\/api\/dbmigrator:watch-${NEW_VERSION}"
sed -i "s/$CURRENT_WATCH_IMAGE_NAME/$NEW_WATCH_IMAGE_NAME/g" ./simple-budget/docker-compose.yml

### API
echo -e "${YELLOW}Building API image${NC}"
docker build -t simplebudget/api:${NEW_VERSION} -f ./api/src/simple-budget.api/containers/dockerfile.dev . >> dockerlog5.txt
echo -e "${YELLOW}Api image: simplebudget/api:${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating docker-compose.yml - Api${NC}"
CURRENT_IDENTITY_IMAGE_NAME="simplebudget\/api:${CURRENT_VERSION}"
NEW_IDENTITY_IMAGE_NAME="simplebudget\/api:${NEW_VERSION}"
sed -i "s/$CURRENT_IDENTITY_IMAGE_NAME/$NEW_IDENTITY_IMAGE_NAME/g" ./simple-budget/docker-compose.yml

### BFF

echo -e "${YELLOW}Building BFF image${NC}"
docker build -t simplebudget/bff:${NEW_VERSION} -f ./bff/src/simple-budget.bff/containers/dockerfile.dev . >> dockerlog6.txt
echo -e "${YELLOW}BFF image: simplebudget/bff:${NEW_VERSION} is ready. ${NC}"

echo -e "${YELLOW}Updating docker-compose.yml - BFF${NC}"
CURRENT_IDENTITY_IMAGE_NAME="simplebudget\/bff:${CURRENT_VERSION}"
NEW_IDENTITY_IMAGE_NAME="simplebudget\/bff:${NEW_VERSION}"
sed -i "s/$CURRENT_IDENTITY_IMAGE_NAME/$NEW_IDENTITY_IMAGE_NAME/g" ./simple-budget/docker-compose.yml

cd simple-budget
echo -e "${YELLOW}Starting services${NC}"
docker-compose up -d bff

echo -e "${YELLOW}Launching VsCode Multi-root workspace${NC}"
code SimpleBudget.code-workspace

echo -e "${YELLOW}Launching Firefox${NC}"
#start firefox https://localhost:3100 https://localhost:3101/swagger https://localhost:3102/swagger https://localhost:3103
start firefox https://localhost:3101/swagger https://localhost:3102/swagger https://localhost:3103 https://localhost:3104