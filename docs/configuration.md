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
