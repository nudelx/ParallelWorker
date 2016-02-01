#!/bin/sh

while [ true ]; do  sleep 1; clear ; ps aux  | grep -v grep  | grep -w Z ; done
