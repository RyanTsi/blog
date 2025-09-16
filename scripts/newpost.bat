@echo off
chcp 65001 > nul

set /p "postName=Input new post name: "

hugo new content content/posts/%postName%.md