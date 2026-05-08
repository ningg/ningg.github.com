#!/bin/bash

# 不使用 --incremental：增量构建在新增/改动 _posts 时，有时不会重生成依赖
# site.posts 的页面（例如首页），浏览器里会像“还是旧列表”。需要全量重编时用下面一行：
bundle exec jekyll clean && bundle exec jekyll serve

# bundle exec jekyll serve
