load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "emsdk",
    sha256 = "bbea764c57af830e761f1fb8600d42dc303aa63ffd43647694eda5b8b757b469",
    strip_prefix = "emsdk-3.1.35/bazel",
    url = "https://github.com/emscripten-core/emsdk/archive/refs/tags/3.1.35.tar.gz",
)

load("@emsdk//:deps.bzl", emsdk_deps = "deps")

emsdk_deps()

load("@emsdk//:emscripten_deps.bzl", emsdk_emscripten_deps = "emscripten_deps")

emsdk_emscripten_deps(emscripten_version = "3.1.35")

load("@emsdk//:toolchains.bzl", "register_emscripten_toolchains")

register_emscripten_toolchains()

## Android

http_archive(
    name = "build_bazel_rules_android",
    sha256 = "cd06d15dd8bb59926e4d65f9003bfc20f9da4b2519985c27e190cddc8b7a7806",
    strip_prefix = "rules_android-0.1.1",
    urls = ["https://github.com/bazelbuild/rules_android/archive/v0.1.1.zip"],
)

load("@build_bazel_rules_android//android:rules.bzl", "android_sdk_repository")

android_sdk_repository(
    name = "androidsdk",
    api_level = 31,
)

http_archive(
    name = "rules_android_ndk",
    sha256 = "3fa4a58f4df356bca277219763f91c64f33dcc59e10843e9762fc5e7947644f9",
    strip_prefix = "rules_android_ndk-63fa7637902fb1d7db1bf86182e939ed3fe98477",
    url = "https://github.com/bazelbuild/rules_android_ndk/archive/63fa7637902fb1d7db1bf86182e939ed3fe98477.zip",
)

load("@rules_android_ndk//:rules.bzl", "android_ndk_repository")

android_ndk_repository(
    name = "androidndk",
)

register_toolchains("@androidndk//:all")
