# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "GoogleCodeSearchBuilder"
version = v"0.1.2"

# Collection of sources required to build GoogleCodeSearchBuilder
sources = [
    "https://github.com/google/codesearch.git" =>
    "4fe90b597ae534f90238f82c7b5b1bb6d6d52dff",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
GOLANG_VERSION=1.9.2
if [ "$target" == "x86_64-linux-gnu" ]; then     GOLANG_ARCH="linux-amd64";     GOLANG_SHA=de874549d9a8d8d8062be05808509c09a88a248e77ec14eb77453530829ac02b; elif [ "$target" == "i686-linux-gnu" ]; then     GOLANG_ARCH="linux-386";     GOLANG_SHA=574b2c4b1a248e58ef7d1f825beda15429610a2316d9cbd3096d8d3fa8c0bc1a; fi
GOLANG_URL="https://golang.org/dl/go${GOLANG_VERSION}.${GOLANG_ARCH}.tar.gz"
GOPATH=/go
export GOPATH
mkdir -p "$GOPATH/src" "$GOPATH/bin"
chmod -R 777 "$GOPATH"
PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
echo "PATH=$GOPATH/bin:/usr/local/go/bin:$PATH" >> /etc/environment
echo "GOPATH=/go" >> /etc/environment
wget -O go.tgz "$GOLANG_URL"
echo "${GOLANG_SHA} *go.tgz" | sha256sum -c -
tar -C /usr/local -xzf go.tgz
rm go.tgz
export PATH="/usr/local/go/bin:$PATH"
go version
/usr/local/go/bin/go get github.com/google/codesearch/cmd/csearch
/usr/local/go/bin/go get github.com/google/codesearch/cmd/cindex
mkdir -p $prefix/bin
cp /go/bin/cindex $prefix/bin/cindex
cp /go/bin/csearch $prefix/bin/csearch
exit

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc),
    Linux(:i686, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    ExecutableProduct(prefix, "csearch", :csearch),
    ExecutableProduct(prefix, "cindex", :cindex)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

