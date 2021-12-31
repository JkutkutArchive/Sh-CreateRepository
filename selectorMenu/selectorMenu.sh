#!/bin/sh

templates=$(ls -d ../templates/* | sed 's/.+\/$//g');

echo "$templates";
