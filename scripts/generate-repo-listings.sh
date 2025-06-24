#!/bin/bash

# Generate directory listings for each repository
set -e

echo "Generating repository listings..."

for repo_dir in repo/centos-stream-9 repo/rhel-ubi-9; do
    repo_name=$(basename "$repo_dir")
    echo "Creating index for $repo_name..."
    
    cat > "$repo_dir/index.html" << REPO_INDEX_EOF
<!DOCTYPE html>
<html>
<head>
    <title>CUTLASS RPM Repository - $repo_name</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1000px; margin: 0 auto; padding: 20px; }
        .header { background: #0066cc; color: white; padding: 15px; border-radius: 5px; }
        .package-list { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .package-item { padding: 8px; margin: 5px 0; background: white; border-radius: 3px; }
        .back-link { margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>CUTLASS RPM Repository</h1>
        <h2>$repo_name</h2>
    </div>
    
    <div class="back-link">
        <a href="../">← Back to main repository</a>
    </div>
    
    <div class="package-list">
        <h3>📦 Binary Packages (x86_64)</h3>
REPO_INDEX_EOF
    
    # Add binary packages
    if [ -d "$repo_dir/x86_64" ]; then
        ls "$repo_dir/x86_64"/*.rpm 2>/dev/null | while read rpm; do
            if [ -f "$rpm" ]; then
                filename=$(basename "$rpm")
                size=$(stat -c%s "$rpm" | numfmt --to=iec)
                echo "        <div class=\"package-item\"><a href=\"x86_64/$filename\">$filename</a> ($size)</div>" >> "$repo_dir/index.html"
            fi
        done
    fi
    
    cat >> "$repo_dir/index.html" << REPO_SOURCE_START_EOF
    </div>
    
    <div class="package-list">
        <h3>📄 Source Packages (SRPMS)</h3>
REPO_SOURCE_START_EOF
    
    # Add source packages
    if [ -d "$repo_dir/SRPMS" ]; then
        ls "$repo_dir/SRPMS"/*.rpm 2>/dev/null | while read rpm; do
            if [ -f "$rpm" ]; then
                filename=$(basename "$rpm")
                size=$(stat -c%s "$rpm" | numfmt --to=iec)
                echo "        <div class=\"package-item\"><a href=\"SRPMS/$filename\">$filename</a> ($size)</div>" >> "$repo_dir/index.html"
            fi
        done
    fi
    
    cat >> "$repo_dir/index.html" << REPO_INDEX_END_EOF
    </div>
    
    <p><strong>Repository metadata:</strong> <a href="repodata/">repodata/</a></p>
</body>
</html>
REPO_INDEX_END_EOF

done

echo "Repository listings generated"