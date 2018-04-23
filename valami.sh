#!/bin/sh
clear
sed -n '/\/bin\/bash/p' /etc/passwd | cut -d: -f1 | wc -l
