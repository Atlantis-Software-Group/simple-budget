#!/bin/sh

MainFunction() 
{
    cd ..
    StartDockerServices
    StartFirefox
}

StartDockerServices() {
    echo -e "${YELLOW}Starting Docker Services ${NC}"
    cd simple-budget
    docker-compose up -d --wait
}

StartFirefox() {
    echo -e "${YELLOW}Starting Web browser ${NC}"
    start firefox https://localhost:3100 https://localhost:3101/swagger https://localhost:3102/swagger https://localhost:3103 https://localhost:3104
}

MainFunction