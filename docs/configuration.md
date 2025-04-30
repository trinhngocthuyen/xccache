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
