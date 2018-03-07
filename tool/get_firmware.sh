#!/usr/bin/env bash

read -p "Please input your username:" username

#Firmwares are placed in mail.shannon-data.com (ip: 192.168.0.6)
rsync -ave ssh $username@192.168.0.6:/home/shannon/public_html/firmwares .
