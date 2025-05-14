[< Knowledge Base](README.md)

# ⚙️ Configuration

The behavior of xccache can be controlled via a `xccache.yml` configuration file under the root project directory. Example: [xccache.yml](/examples/xccache.yml).

Following are some available configurations.

### `ignore_local`
- Default: `false`
- Whether to ignore local packages.

### `ignore`
- Default: `[]`
- Swift package targets to ignore, in patterns.
```yml
ignore:
  - core-utils/*
```
> [!NOTE]
> These patterns apply to targets, not products.

### `keep_pkgs_in_project`
- Default: `false`
- Whether to keep or remove packages from xcodeproj. By default, packages managed by xccache will be removed from xcodeproj in order to reduce time for package resolution in Xcode.

### `ignore_build_errors`
- Default: `false`
- Whether to ignore build errors in `xccache build`. This option might be useful when building multiple targets and one of them fails, with this option as `true`, the tool still continues building other targets.

### `default_sdk`
- Default: `iphonesimulator`
- The default sdk to use. Valid values: `iphonesimulator`, `iphoneos`, `macos`, `appletvos`, `appletvsimulator`, `watchos`, `watchsimulator`, `xros`, `xrsimulator`.

### `remote`
- The remote cache configuration (using Git, S3, etc.).

NOTE: This configuration is per build/install configuration (debug/release), as follows.

**Using Git**
```yml
remote:
  debug: # remote cache config for debug & release
    git: git@github.com/org/cache
```

**Using S3**
```yml
remote:
  debug: # remote cache config for debug
    git: https://github.com/trinhngocthuyen/.cache.git
  release: # remote cache config for release
    s3:
      uri: "s3://xccache/binaries"
      creds: "path/to/aws_creds.json"
```
- `s3:uri`: The S3 URI, ex. `s3://xccache/binaries`
- `s3:creds`: The path to the json credentials (default: `~/.xccache/s3.creds.json`). This json contains the access key id and secret access key as follows:
```json
{
  "access_key": "YOUR_KEY_ID",
  "secret_access_key": "YOUR_ACCESS_KEY"
}
```
