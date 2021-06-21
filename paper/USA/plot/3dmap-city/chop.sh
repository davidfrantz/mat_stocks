#!/bin/bash

ls *.png | parallel convert {} -gravity North -chop 0x500  {.}.jpg
ls *.jpg | parallel convert {} -gravity South -chop 0x250  {}
ls *.jpg | parallel convert {} -gravity West  -chop 350x0  {}
ls *.jpg | parallel convert {} -gravity East  -chop 300x0  {}

exit 0

