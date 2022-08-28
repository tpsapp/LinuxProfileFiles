#!/bin/bash
echo Mounting SAPPNAS...
mkdir -p ~/SAPPNAS
sudo mount //192.168.0.134/backup ~/SAPPNAS -o user=admin,gid=tpsapp,uid=tpsapp
