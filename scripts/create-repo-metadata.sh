#!/bin/bash

# Create RPM repository metadata and web pages
set -e

echo "Creating repository metadata..."

# Create metadata for CentOS Stream 9 repository
createrepo_c repo/centos-stream-9/

# Create metadata for RHEL UBI 9 repository  
createrepo_c repo/rhel-ubi-9/

# Generate main repository overview HTML
cat > repo/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CUTLASS RPM Repository</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { background: #0066cc; color: white; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .repo-section { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .code-block { background: #2d3748; color: #e2e8f0; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .gpu-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; margin: 20px 0; }
        .gpu-card { background: white; padding: 15px; border-radius: 5px; border-left: 4px solid #0066cc; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 10px; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 CUTLASS RPM Repository</h1>
        <p>High-performance CUDA linear algebra packages for CentOS Stream 9 and RHEL 9</p>
    </div>

    <div class="warning">
        <strong>⚠️ Requirements:</strong> NVIDIA GPU with compute capability 8.0+, CUDA 12.4+, and appropriate drivers.
    </div>

    <div class="repo-section">
        <h2>📦 Repository Setup</h2>
        
        <h3>For CentOS Stream 9:</h3>
        <div class="code-block">
sudo tee /etc/yum.repos.d/cutlass.repo &lt;&lt; 'REPO_EOF'
[cutlass-centos-stream-9]
name=CUTLASS for CentOS Stream 9
baseurl=https://fabiendupont.github.io/cutlass-rpm/repo/centos-stream-9
enabled=1
gpgcheck=0
REPO_EOF

sudo dnf makecache
        </div>

        <h3>For RHEL 9 / UBI-based systems:</h3>
        <div class="code-block">
sudo tee /etc/yum.repos.d/cutlass.repo &lt;&lt; 'REPO_EOF'
[cutlass-rhel-ubi-9]
name=CUTLASS for RHEL UBI 9
baseurl=https://fabiendupont.github.io/cutlass-rpm/repo/rhel-ubi-9
enabled=1
gpgcheck=0
REPO_EOF

sudo dnf makecache
        </div>
    </div>

    <div class="repo-section">
        <h2>🎯 GPU Architecture Packages</h2>
        <div class="gpu-grid">
            <div class="gpu-card">
                <h4>🔥 Ampere + Ada</h4>
                <p><strong>GPUs:</strong> RTX 30/40 series, A100, A10</p>
                <p><strong>Compute:</strong> 8.0, 8.6, 8.9</p>
                <div class="code-block">sudo dnf install cutlass-*ampere-ada*</div>
            </div>
            <div class="gpu-card">
                <h4>⚡ Hopper</h4>
                <p><strong>GPUs:</strong> H100, H200</p>
                <p><strong>Compute:</strong> 9.0a (arch-accelerated)</p>
                <div class="code-block">sudo dnf install cutlass-*hopper*</div>
            </div>
            <div class="gpu-card">
                <h4>🚀 Blackwell</h4>
                <p><strong>GPUs:</strong> B100, B200, RTX 50 series</p>
                <p><strong>Compute:</strong> 10.0a (latest features)</p>
                <div class="code-block">sudo dnf install cutlass-*blackwell*</div>
            </div>
            <div class="gpu-card">
                <h4>🌟 Modern All</h4>
                <p><strong>GPUs:</strong> All modern architectures</p>
                <p><strong>Compute:</strong> 8.0, 8.6, 8.9, 9.0a, 10.0a</p>
                <div class="code-block">sudo dnf install cutlass-*modern-all*</div>
            </div>
        </div>
    </div>

    <div class="repo-section">
        <h2>📋 Available Packages</h2>
        <ul>
            <li><strong>cutlass-devel</strong> - Header files and development components (main package)</li>
            <li><strong>cutlass-python</strong> - Python 3.12 interface and DSL components</li>
            <li><strong>cutlass-tools</strong> - Performance profiler and utilities</li>
            <li><strong>cutlass-examples</strong> - Example programs and demonstrations</li>
        </ul>
    </div>

    <div class="repo-section">
        <h2>🔍 Quick Install Examples</h2>
        
        <h3>Complete Development Environment:</h3>
        <div class="code-block">
# For RTX 40 series on CentOS Stream 9
sudo dnf install cutlass-devel-*centos-stream*ampere-ada* \
                 cutlass-python-*centos-stream*ampere-ada* \
                 cutlass-tools-*centos-stream*ampere-ada*

# For H100 on RHEL 9
sudo dnf install cutlass-devel-*rhel-ubi*hopper* \
                 cutlass-python-*rhel-ubi*hopper* \
                 cutlass-tools-*rhel-ubi*hopper*
        </div>

        <h3>Python Development Only:</h3>
        <div class="code-block">
# Installs both devel (headers) and python components
sudo dnf install cutlass-python-*modern-all*
        </div>
    </div>

    <div class="repo-section">
        <h2>📚 Documentation &amp; Links</h2>
        <ul>
            <li><a href="https://github.com/fabiendupont/cutlass-rpm">📁 Repository Source</a></li>
            <li><a href="https://github.com/NVIDIA/cutlass">🔗 NVIDIA CUTLASS</a></li>
            <li><a href="https://nvidia.github.io/cutlass/">📖 CUTLASS Documentation</a></li>
            <li><a href="https://developer.nvidia.com/cuda-downloads">⬇️ CUDA Downloads</a></li>
        </ul>
    </div>

    <div class="repo-section">
        <h2>📊 Repository Contents</h2>
        <p><strong>Last Updated:</strong> $(date -u)</p>
        <ul>
            <li><a href="centos-stream-9/">📁 CentOS Stream 9 Packages</a></li>
            <li><a href="rhel-ubi-9/">📁 RHEL UBI 9 Packages</a></li>
        </ul>
    </div>

    <footer style="margin-top: 40px; text-align: center; color: #666;">
        <p>🤖 Automatically updated by GitHub Actions | 📄 Built from <a href="https://github.com/fabiendupont/cutlass-rpm">fabiendupont/cutlass-rpm</a></p>
    </footer>
</body>
</html>
HTML_EOF

echo "Main index page created"