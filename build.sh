#!/bin/sh
# shellcheck disable=SC3043,SC2086,SC2164,SC2103,SC2046

get_sources() {
  git clone $BUILD_REPO --single-branch -b $GITHUB_REF_NAME openwrt
}

echo_version() {
  echo "[=============== openwrt version ===============]"
  cd openwrt && git log -1 && cd -
  echo
  echo "[=============== configs version ===============]"
  cd configs && git log -1 && cd -
}

build_firmware() {
  cd openwrt

  ./scripts/feeds update -a
  ./scripts/feeds install -a

  cp ${GITHUB_WORKSPACE}/configs/${BUILD_PROFILE} .config
  make -j$(nproc) V=w || make -j1 V=sc || exit 1

  cd -
}

package_binaries() {
  local bin_dir="openwrt/bin"
  local tarball="${BUILD_PROFILE}.tar.gz"
  tar -zcvf $tarball -C $bin_dir $(ls $bin_dir -1)
}

get_sources
echo_version
build_firmware
package_binaries
