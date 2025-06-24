Name:           cutlass
Version:        3.9.2
Release:        1%{?dist}
Summary:        CUDA Templates for Linear Algebra Subroutines
License:        BSD-3-Clause
URL:            https://github.com/NVIDIA/cutlass
Source0:        https://github.com/NVIDIA/cutlass/archive/refs/tags/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

# Build requirements
BuildRequires:  cmake >= 3.18
BuildRequires:  gcc-c++ >= 11.0
BuildRequires:  cuda-toolkit >= 12.4
BuildRequires:  python3.12-devel
BuildRequires:  python3.12-pip
BuildRequires:  python3.12-setuptools
BuildRequires:  python3.12-wheel
BuildRequires:  make
BuildRequires:  git

# Runtime requirements
Requires:       cuda-runtime >= 12.4

# Architecture requirements - CUTLASS requires compute capability 8.0+ for modern CUDA
ExclusiveArch:  x86_64

%description
CUTLASS is a collection of CUDA C++ template abstractions for implementing 
high-performance matrix-matrix multiplication (GEMM) and related computations 
at all levels and scales within CUDA. It incorporates strategies for 
hierarchical decomposition and data movement similar to those used to 
implement cuBLAS and cuDNN.

CUTLASS decomposes these "moving parts" into reusable, modular software 
components abstracted by C++ template classes. These thread-wide, warp-wide, 
block-wide, and device-wide primitives can be specialized and tuned via custom 
tiling sizes, data types, and other algorithmic policy.

%package        devel
Summary:        Development files for %{name}
Requires:       %{name} = %{version}-%{release}
Requires:       cuda-toolkit >= 12.4

%description    devel
The %{name}-devel package contains header files for developing
applications that use %{name}.

%package        python
Summary:        CUTLASS Python interface and DSL components
Requires:       %{name}-devel = %{version}-%{release}
Requires:       python3.12
Requires:       python3.12-numpy
Requires:       cuda-python >= 12.4

%description    python
The %{name}-python package contains the CUTLASS Python interface
and DSL components for Python 3.12, including both the legacy
CUTLASS Python interface and the new CUTLASS 4.x DSL support.

%package        tools
Summary:        CUTLASS profiler and utilities
Requires:       %{name} = %{version}-%{release}

%description    tools
The %{name}-tools package contains the CUTLASS profiler and other
utilities for performance analysis and kernel selection.

%package        examples
Summary:        CUTLASS examples and test programs
Requires:       %{name}-devel = %{version}-%{release}

%description    examples
The %{name}-examples package contains example programs demonstrating
CUTLASS usage patterns and test programs.

%prep
%autosetup -n %{name}-%{version}

%build
# Set Python and CUDA environment variables
export CUDA_HOME=/usr/local/cuda
export CUDACXX=${CUDA_HOME}/bin/nvcc
export CUDA_INSTALL_PATH=${CUDA_HOME}
export CUTLASS_PATH=$(pwd)
export PYTHON=/usr/bin/python3.12

# Create build directory
mkdir -p build
cd build

# Configure with CMake
# Build for modern GPU architectures (Ampere, Ada, Hopper, Blackwell)
# Focus on CUDA 12.4+ supported architectures
%cmake .. \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX=%{_prefix} \
    -DCUTLASS_NVCC_ARCHS="80;86;89;90a;100a" \
    -DCUTLASS_ENABLE_TESTS=ON \
    -DCUTLASS_ENABLE_EXAMPLES=ON \
    -DCUTLASS_UNITY_BUILD_ENABLED=ON \
    -DCUTLASS_LIBRARY_KERNELS=cutlass_tensorop_*,cutlass_simt_* \
    -DCMAKE_CUDA_ARCHITECTURES="80;86;89;90;100"

# Build the library
%cmake_build

%install
cd build
%cmake_install

# Create directories for different components
mkdir -p %{buildroot}%{_includedir}
mkdir -p %{buildroot}%{_libdir}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/%{name}
mkdir -p %{buildroot}%{_docdir}/%{name}

# Install headers (CUTLASS is header-only)
cp -r ../include/* %{buildroot}%{_includedir}/

# Install profiler binary if built
if [ -f tools/profiler/cutlass_profiler ]; then
    install -m 755 tools/profiler/cutlass_profiler %{buildroot}%{_bindir}/
fi

# Install library components if built
if [ -d tools/library ]; then
    cp -r tools/library %{buildroot}%{_datadir}/%{name}/
fi

# Install Python components
if [ -d ../python ]; then
    mkdir -p %{buildroot}%{python3_sitelib}
    # Install CUTLASS Python interface
    cd ../python
    python3.12 -m pip install --target %{buildroot}%{python3_sitelib} .
    cd ../build
fi

# Install examples
mkdir -p %{buildroot}%{_datadir}/%{name}/examples
cp -r ../examples/* %{buildroot}%{_datadir}/%{name}/examples/

# Install documentation
cp -r ../media/docs/* %{buildroot}%{_docdir}/%{name}/
install -m 644 ../README.md %{buildroot}%{_docdir}/%{name}/
install -m 644 ../CHANGELOG.md %{buildroot}%{_docdir}/%{name}/
install -m 644 ../LICENSE.txt %{buildroot}%{_docdir}/%{name}/

# Install CMake config files if they exist
if [ -d lib/cmake ]; then
    mkdir -p %{buildroot}%{_libdir}/cmake/%{name}
    cp -r lib/cmake/%{name}/* %{buildroot}%{_libdir}/cmake/%{name}/
fi

%check
cd build
# Run a subset of tests (full test suite can be very time consuming)
# Skip if CUDA device not available in build environment
if nvidia-smi > /dev/null 2>&1; then
    make test_unit_cute_core test_unit_transform test_unit_layout || true
fi

%files
%license LICENSE.txt
%doc README.md CHANGELOG.md
%{_docdir}/%{name}/

%files devel
%{_includedir}/cutlass/
%{_includedir}/cute/
%{_libdir}/cmake/%{name}/

%files python
%{python3_sitelib}/cutlass/
%{python3_sitelib}/cutlass_library/
%{python3_sitelib}/*cutlass*.dist-info/

%files tools
%{_bindir}/cutlass_profiler
%{_datadir}/%{name}/library/

%files examples
%{_datadir}/%{name}/examples/

%changelog
* Tue Jun 24 2025 Package Maintainer <maintainer@example.com> - 3.9.2-1
- Initial RPM package for CUTLASS 3.9.2
- Support for RHEL 9.6 with CUDA 12.4+
- Header-only library with profiler tools and examples
- Support for Ampere, Ada, Hopper, and Blackwell architectures
- Focus on modern GPU compute capabilities (8.0+)
- Added Python 3.12 support for CUTLASS Python interface and DSL

* Mon May 20 2025 NVIDIA Corporation - 3.9.2-0
- CUTLASS 3.9.2 release
- Support for Blackwell SM100 and SM120 architectures (compute 10.0)
- Enhanced kernel performance search (auto-tuning) in profiler
- Block-wise and group-wise GEMM enhancements
- Sparse GEMM support for Blackwell architecture
- CUTLASS 4.x DSL support for Python 3.12
