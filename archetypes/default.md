---
date: '{{ .Date }}'
draft: true
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
tags: []
categories: []
comments: false
summary: "<Text>"
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false

cover:
    image: "<image path/url>" # image path/url
    caption: "<text>" # display caption under cover
    alt: "<alt text>" # alt text
    relative: false # when using page bundles set this to true
    responsiveImages: false # generation of responsive cover images
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---
