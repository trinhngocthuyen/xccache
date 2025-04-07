# Workflows
## Initial Setup
```sh
xccache init
```
This command generates a `xccache.lock` file that keeps track of packages and dependencies in your projects. This lockfile is also being used for *rolling back caches* (from binaries to sources).
