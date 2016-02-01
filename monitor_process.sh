#!/bin/sh

while [ true ] ; do  sleep 1 ;clear; ps -ef | grep -v grep | grep -v vim| grep ruby ; done