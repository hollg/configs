# Agent Instructions

## Node.js / nvm

Node.js is managed via [nvm](https://github.com/nvm-sh/nvm) and is **not** available in non-interactive shells by default.

Before running any `node`, `npm`, or `npx` command, prefix it with the nvm bootstrap:

```sh
export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && <your command here>
```

Example:

```sh
export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm run build
```
