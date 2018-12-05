#!/bin/sh
set -x
cat blog.sql blog_data.sql blog_dump.sql | mysql -t -u root -p | tee blog.txt
