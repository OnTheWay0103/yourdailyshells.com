#!/bin/bash

# 获取当前日期，格式为YYYY-MM-DD
current_date=$(date +%Y-%m-%d)

# 查找一级子目录下的所有md文件，排除BEFORE.md和AFTER.md
find . -mindepth 2 -maxdepth 2 -type f -name "*.md" \
    -not -name "BEFORE.md" \
    -not -name "AFTER.md" | while read -r file; do
    
    # 获取文件名（不包含路径和扩展名）
    filename=$(basename "$file" .md)
    
    # 获取父目录路径
    parent_dir=$(dirname "$file")
    
    # 创建新目录名（在父目录下）
    new_dir="${parent_dir}/${current_date}_${filename}"
    
    # 创建新目录
    mkdir -p "$new_dir"
    
    # 移动文件到新目录并重命名为README.md
    mv "$file" "$new_dir/README.md"
    
    echo "已处理文件: $file -> $new_dir/README.md"
done 