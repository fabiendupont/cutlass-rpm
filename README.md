# CUTLASS RPM Packages for CentOS Stream 9 and RHEL 9

This repository provides RPM spec files and automated builds for [NVIDIA CUTLASS](https://github.com/NVIDIA/cutlass) on CentOS Stream 9 and Red Hat Enterprise Linux 9 (via UBI) and compatible distributions.

## Overview

CUTLASS (CUDA Templates for Linear Algebra Subroutines) is a collection of CUDA C++ template abstractions for implementing high-performance matrix-matrix multiplication (GEMM) and related computations. This repository packages CUTLASS for easy installation on RHEL-based systems.

## Features

- **Modern GPU Support**: Optimized for Ampere, Ada, Hopper, and Blackwell architectures (compute capability 8.0+)
- **CUDA 12.4+ Ready**: Built for modern CUDA toolkit versions
- **Python 3.12 Support**: Includes CUTLASS Python interface and DSL components
- **Automated Builds**: GitHub Actions automatically build RPMs when new CUTLASS releases are published
- **Multiple Packages**: Modular packaging for different use cases

## Package Structure

The build produces four RPM packages:

| Package | Description |
|---------|-------------|
| `cutlass` | Main package with documentation and license |
| `cutlass-devel` | Development headers (core functionality - CUTLASS is header-only) |
| `cutlass-python` | Python 3.12 interface and DSL components |
| `cutlass-tools` | CUTLASS profiler and performance analysis utilities |
| `cutlass-examples` | Example programs and demonstrations |

## Requirements

### System Requirements
- **OS**: CentOS Stream 9, RHEL 9, or compatible (Rocky Linux, AlmaLinux, etc.)
- **Base Images**: Built and tested on both CentOS Stream 9 and Red Hat UBI 9
- **Architecture**: x86_64
- **GPU**: NVIDIA GPU with compute capability 8.0+ (Ampere or newer)

### Build Requirements
- CUDA Toolkit 12.4 or newer
- GCC 11.0 or newer
- CMake 3.18 or newer
- Python 3.12 (for Python components)

### Runtime Requirements
- NVIDIA GPU drivers compatible with CUDA 12.4+
- CUDA runtime 12.4+

## Installation

### From Hosted Repository (Recommended)

The easiest way to install CUTLASS is using our hosted YUM/DNF repository:

**Quick Setup (Automated):**
```bash
# Download and run the setup script
curl -fsSL https://fabiendupont.github.io/cutlass-rpm/setup-cutlass-repo.sh | sudo bash

# Then install packages based on the script's recommendations
sudo dnf install cutlass-devel-*modern-all*
```

**Manual Setup:**

**For CentOS Stream 9:**
```bash
# Add the repository
sudo tee /etc/yum.repos.d/cutlass.repo << 'EOF'
[cutlass-centos-stream-9]
name=CUTLASS for CentOS Stream 9
baseurl=https://fabiendupont.github.io/cutlass-rpm/repo/centos-stream-9
enabled=1
gpgcheck=0
EOF

# Update package cache
sudo dnf makecache

# Install packages for your GPU architecture
sudo dnf install cutlass-devel-*ampere-ada*     # RTX 30/40 series
sudo dnf install cutlass-devel-*hopper*         # H100/H200
sudo dnf install cutlass-devel-*blackwell*      # B100/B200, RTX 50
sudo dnf install cutlass-devel-*modern-all*     # All architectures
```

**For RHEL 9 / UBI-based systems:**
```bash
# Add the repository
sudo tee /etc/yum.repos.d/cutlass.repo << 'EOF'
[cutlass-rhel-ubi-9]
name=CUTLASS for RHEL UBI 9
baseurl=https://fabiendupont.github.io/cutlass-rpm/repo/rhel-ubi-9
enabled=1
gpgcheck=0
EOF

# Update package cache
sudo dnf makecache

# Install packages for your GPU architecture
sudo dnf install cutlass-devel-*ampere-ada*     # RTX 30/40 series
sudo dnf install cutlass-devel-*hopper*         # H100/H200
sudo dnf install cutlass-devel-*blackwell*      # B100/B200, RTX 50
sudo dnf install cutlass-devel-*modern-all*     # All architectures
```

**Complete development environment:**
```bash
# Install all components (devel + python + tools + examples)
sudo dnf install cutlass-*modern-all*
```

### From Pre-built RPMs

1. Download the latest RPMs from the [Releases](https://github.com/fabiendupont/cutlass-rpm/releases) page

2. Choose the appropriate base image variant:

   **For CentOS Stream 9:**
   ```bash
   # Install core development package
   sudo dnf install cutlass-devel-*centos-stream*.rpm
   
   # Install Python support
   sudo dnf install cutlass-python-*centos-stream*.rpm
   
   # Install profiler tools
   sudo dnf install cutlass-tools-*centos-stream*.rpm
   ```

   **For RHEL 9 / UBI-based systems:**
   ```bash
   # Install core development package
   sudo dnf install cutlass-devel-*rhel-ubi*.rpm
   
   # Install Python support
   sudo dnf install cutlass-python-*rhel-ubi*.rpm
   
   # Install profiler tools
   sudo dnf install cutlass-tools-*rhel-ubi*.rpm
   ```

### Building from Source

1. **Install build dependencies:**

   **On CentOS Stream 9:**
   ```bash
   # Install CUDA Toolkit 12.4+ first from NVIDIA
   # Then install build tools
   sudo dnf install rpm-build cmake gcc-c++ make git
   sudo dnf install epel-release
   sudo dnf config-manager --enable crb
   sudo dnf install python3.12-devel python3.12-pip python3.12-setuptools
   ```

   **On RHEL 9 / UBI:**
   ```bash
   # Install CUDA Toolkit 12.4+ first from NVIDIA
   # Enable EPEL for additional packages
   sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
   sudo dnf install rpm-build cmake gcc-c++ make git
   sudo dnf install python3.12-devel python3.12-pip python3.12-setuptools
   ```

2. **Clone and build:**
```bash
git clone https://github.com/fabiendupont/cutlass-rpm.git
cd cutlass-rpm

# Build the RPM
rpmbuild -ba cutlass.spec
```

3. **Install built packages:**
```bash
sudo dnf install ~/rpmbuild/RPMS/x86_64/cutlass-*.rpm
```

## Usage Examples

### C++ Development

```cpp
#include <cutlass/gemm/device/gemm.h>
#include <cutlass/util/host_tensor.h>

// Use CUTLASS for high-performance GEMM
// See examples in /usr/share/cutlass/examples/
```

### Python Interface

```python
import cutlass
import numpy as np

# Create a GEMM operation
plan = cutlass.op.Gemm(element=np.float16, layout=cutlass.LayoutType.RowMajor)

# Run computation
A, B, C, D = [np.ones((128, 128), dtype=np.float16) for i in range(4)]
plan.run(A, B, C, D)
```

### Performance Profiling

```bash
# Profile GEMM kernels
cutlass_profiler --kernels=cutlass_tensorop_s*gemm_f16_* --m=1024 --n=1024 --k=1024

# Exhaustive performance search
cutlass_profiler --kernels=sgemm --m=2048 --n=2048 --k=2048 --search-mode=best
```

## GPU Architecture Support

| Architecture | Compute Capability | Support Status |
|--------------|-------------------|----------------|
| Ampere | 8.0, 8.6 | ✅ Full Support |
| Ada Lovelace | 8.9 | ✅ Full Support |
| Hopper | 9.0a | ✅ Full Support + Architecture-Accelerated Features |
| Blackwell | 10.0a | ✅ Full Support + Latest Features |

## Automated Builds

This repository uses GitHub Actions to automatically:

1. **Monitor CUTLASS releases**: Watches the NVIDIA/cutlass repository for new releases
2. **Build RPMs**: Automatically builds packages when new versions are available
3. **Update repository**: Publishes built RPMs to the hosted YUM/DNF repository
4. **Create releases**: Also publishes built RPMs as GitHub releases
5. **Multi-architecture support**: Builds for different GPU target architectures

### Repository Features

- **Hosted Repository**: Packages are automatically published to `https://fabiendupont.github.io/cutlass-rpm/`
- **Web Interface**: Browse packages at the hosted repository URL
- **Automatic Updates**: New CUTLASS releases trigger automatic rebuilds
- **Multiple Variants**: Each release includes packages for different GPU architectures and base images

The build matrix includes:
- **Base Images**: CentOS Stream 9, Red Hat UBI 9
- **CUDA versions**: 12.4, 12.5, 12.6+
- **GPU architectures**: Ampere, Ada, Hopper, Blackwell
- **Python versions**: 3.12

## Configuration

### Custom GPU Architectures

To build for specific GPU architectures, modify the `CUTLASS_NVCC_ARCHS` setting in the spec file:

```spec
# Example: Build only for Hopper and Blackwell
-DCUTLASS_NVCC_ARCHS="90a;100a" \
```

### CUDA Version Compatibility

The spec file targets CUDA 12.4+ but can be adjusted for other versions by modifying the requirements section.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build locally
5. Submit a pull request

### Reporting Issues

Please report issues with:
- Build failures
- Package dependencies
- Installation problems
- Performance issues

## Versioning

This repository follows the CUTLASS versioning scheme:
- **Package version**: Matches CUTLASS release version (e.g., 3.9.2)
- **Package release**: Incremented for packaging changes (e.g., 3.9.2-2)

## License

- **CUTLASS**: BSD 3-Clause License (see [CUTLASS LICENSE](https://github.com/NVIDIA/cutlass/blob/main/LICENSE.txt))
- **Packaging**: MIT License (see [LICENSE](LICENSE))

## Links

- [NVIDIA CUTLASS](https://github.com/NVIDIA/cutlass) - Official CUTLASS repository
- [CUTLASS Documentation](https://nvidia.github.io/cutlass/) - Official documentation
- [CUDA Toolkit](https://developer.nvidia.com/cuda-downloads) - NVIDIA CUDA downloads
- [RHEL 9.6 Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9) - Red Hat documentation

## Acknowledgments

- NVIDIA Corporation for developing CUTLASS
- The CUTLASS community for contributions and feedback
- Red Hat for the excellent RPM packaging ecosystem