#!/bin/sh

chmod +x /https/asg.dev.pfx
mkdir /data/Certificates
cp /https/asg.dev.pfx /data/Certificates/443.pfx
cp /https/asg.dev.pfx /data/Certificates/45341.pfx