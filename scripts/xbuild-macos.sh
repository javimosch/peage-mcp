#!/usr/bin/env bash
# Cross-compile peage-mcp to macOS (x86_64 or arm64) from Linux using zig + a
# zig-built static OpenSSL. Produces ./dist/peage-mcp-darwin-<arch> and a matching
# peage-mcp-darwin-<arch>.mcpb bundle.
#
# Why this is non-trivial: machin's runtime does TLS via OpenSSL (openssl/ssl.h) and
# the generated C is POSIX (works on macOS, NOT Windows — see machin#517). zig cross-
# compiles the POSIX C to Mach-O, but OpenSSL must be built for the Mac target. We build
# it with `no-asm` (portable) and link the extracted .o objects directly, because a
# GNU-ar archive's long-name table trips macOS lld ("unknown cpu architecture").
#
# Requires: zig (>=0.13), machin, curl, tar, ar, zip. Run from the repo root.
set -euo pipefail
cd "$(dirname "$0")/.."

ARCH="${1:-arm64}"                       # arm64 (Apple Silicon) | x86_64 (Intel)
case "$ARCH" in
  arm64|aarch64) ZTARGET=aarch64-macos; OSSL_TARGET=darwin64-arm64; TAG=arm64 ;;
  x86_64|x64)    ZTARGET=x86_64-macos;  OSSL_TARGET=darwin64-x86_64; TAG=x64 ;;
  *) echo "usage: $0 [arm64|x86_64]"; exit 2 ;;
esac

OSSL_VER=3.3.2
CACHE="${XBUILD_CACHE:-/tmp/peage-xbuild}"
OSSL_SRC="$CACHE/openssl-$OSSL_VER-$TAG"
OBJDIR="$CACHE/ossl-obj-$TAG"

mkdir -p "$CACHE" dist

# 1. Build static OpenSSL for the target (cached) ---------------------------------
if [ ! -f "$OSSL_SRC/libssl.a" ]; then
  echo ">> building OpenSSL $OSSL_VER for $ZTARGET (one-time, ~10 min)"
  [ -d "$OSSL_SRC" ] || { curl -sL "https://github.com/openssl/openssl/releases/download/openssl-$OSSL_VER/openssl-$OSSL_VER.tar.gz" \
      | tar xz -C "$CACHE" && mv "$CACHE/openssl-$OSSL_VER" "$OSSL_SRC"; }
  ( cd "$OSSL_SRC"
    CC="zig cc -target $ZTARGET" ./Configure "$OSSL_TARGET" no-asm no-shared no-tests no-docs no-apps >/dev/null
    make -j"$(nproc)" build_libs )
fi

# 2. Extract objects (link them directly; skip the incompatible ar archive) -------
if [ ! -d "$OBJDIR" ]; then
  mkdir -p "$OBJDIR"; ( cd "$OBJDIR" && ar x "$OSSL_SRC/libcrypto.a" && ar x "$OSSL_SRC/libssl.a" )
fi

# 3. Emit machin C + link for the Mac target --------------------------------------
echo ">> emitting C + linking peage-mcp-darwin-$TAG"
machin encode framework/machweb.src src/*.src 2>/dev/null > app.mfl || true
[ -s app.mfl ] || machin encode src/*.src > app.mfl
machin build app.mfl --emit-c > "$CACHE/app-$TAG.c"
ls "$OBJDIR"/*.o > "$CACHE/objs-$TAG.rsp"
zig cc -target "$ZTARGET" -w "$CACHE/app-$TAG.c" -I"$OSSL_SRC/include" @"$CACHE/objs-$TAG.rsp" \
  -o "dist/peage-mcp-darwin-$TAG"
file "dist/peage-mcp-darwin-$TAG"

# 4. Package the .mcpb bundle (manifest + this arch's binary) ----------------------
PKG="$CACHE/pkg-$TAG"; rm -rf "$PKG"; mkdir -p "$PKG"
cp manifest.json "$PKG/"
cp "dist/peage-mcp-darwin-$TAG" "$PKG/peage-mcp"
python3 - "$PKG/manifest.json" "$TAG" <<'PY'
import json,sys
m=json.load(open(sys.argv[1])); tag=sys.argv[2]
m["compatibility"]={"platforms":["darwin"],"runtimes":{}}
m["version"]=m.get("version","0.1.2")
json.dump(m,open(sys.argv[1],"w"),indent=2)
PY
( cd "$PKG" && zip -q -r "$OLDPWD/dist/peage-mcp-darwin-$TAG.mcpb" manifest.json peage-mcp )
echo ">> built dist/peage-mcp-darwin-$TAG and dist/peage-mcp-darwin-$TAG.mcpb"
echo ">> NOTE: cross-compiled — smoke-test on a real Mac (\`./peage-mcp version\`) before publishing."
