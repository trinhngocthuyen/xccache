[< Knowledge Base](README.md)

# 🤝 Contributing

You are more than welcome to contribute to the project in various ways:
- Implement features
- Fix bugs
- Write tests
- Write documentation

The following section describes the development workflow when contributing to the project.

## Development Workflow

**Step 1. Clone the project**

```sh
git clone https://github.com/trinhngocthuyen/xccache.git && cd xccache
```

**Step 2. Install dependencies**

```sh
make install
```

**Step 3. Make changes**

You can try out your changes with the example project at `examples`.

**Step 4. Format changes**

This project is using `pre-commit` (which is installed in step 2) to lint & format changes.\
By default, pre-commit auto lints and formats your changes. Therefore, make sure step 2 succeeded.\
In case you want to trigger the format, simply run `make format`.

**Step 5: Commit changes and create pull requests**

### xccache-proxy

[xccache-proxy](https://github.com/trinhngocthuyen/xccache-proxy) is an internal tool (at: tools/xccache-proxy) used for generating proxy packages (to manipulate cache).

Its binary is downloaded from remote, to `libexec/.download/<version>/xccache-proxy`. When there's a binary at `libexec/.local/xccache-proxy`, this binary is picked up for the execution.

Using the local xccache-proxy binary is preferred for local development. If you're making changes in xccache-proxy and want to test against this repo (xccache), simply build the binary by:
```sh
make proxy.build
```
