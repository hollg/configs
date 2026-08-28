---
name: wave
description: Use the `wave` CLI to send ad-hoc HTTP requests and to author/run YAML request collections for testing local or remote APIs. Invoke whenever you need to exercise an HTTP endpoint from the shell (smoke-test a running server, replay a saved request, verify a fix with a known payload) instead of reaching for `curl` or `httpie`. Covers: collection layout under `.wave/`, headers vs. body syntax (`key:value` vs. `key=value`), `${var}` and `${env:VAR}` interpolation, `--form` bodies, CLI-overrides-collection merging, and verbose output for assertions.
---

# wave

`wave` is a Rust HTTP CLI. Prefer it over `curl` for anything you'd otherwise want to re-run, because requests can be saved as YAML collections checked in alongside the API they exercise.

## Binary

Use the `wave` on `PATH` (Homebrew installs it to `/opt/homebrew/bin/wave`). If it isn't found, ask the user to install it with `brew install make-wave/tap/wave`. Sanity check with `wave --version`.

## One-shot requests

```
wave <method> <url> [params...] [-v]
```

- Methods: `get`, `post`, `put`, `patch`, `delete`.
- `<url>`: scheme is optional; `wave` defaults to `http://` if missing. `localhost[:port]` is accepted.
- Params after the URL are positional and mixed:
  - `Key:Value` → request **header**.
  - `key=value` → **body** field (JSON object by default).
- `--form` on `post`/`put`/`patch` switches the body to `application/x-www-form-urlencoded` and sets `Content-Type` automatically.
- `-v` / `--verbose` prints status + all response headers + body. Default output is status + body only (headers also show on 4xx/5xx).

Examples:
```
wave get https://httpbin.org/get Accept:application/json
wave post localhost:8080/users Authorization:Bearer123 name=alice age=30
wave post localhost:8080/login --form username=alice password=hunter2
wave delete https://api.example.com/users/42 -v
```

Type inference for body values: integers, floats, and `true`/`false` become JSON numbers/booleans; everything else is a string. So `age=30` sends `"age": 30`, not `"age": "30"`.

## Collections

Collections live in `.wave/<name>.yaml` (or `.yml`) **relative to the current working directory**. Run with:

```
wave -c <collection> <request> [overrides...] [-v]
# or the long form
wave collection <collection> <request> [overrides...] [-v]
```

The collection name is the file name without extension. `wave -c test get-user` loads `.wave/test.yaml` (falling back to `.wave/test.yml`) and runs the request named `get-user`.

### Collection YAML

```yaml
variables:
  base_url: http://localhost:8080
  user_id: 42

requests:
  - name: get-user
    method: GET
    url: ${base_url}/users/${user_id}
    headers:
      Authorization: Bearer ${env:API_TOKEN}
      Accept: application/json

  - name: create-user
    method: POST
    url: ${base_url}/users
    headers:
      Content-Type: application/json
    body:
      json:
        name: Alice
        email: alice@example.com
        age: 30

  - name: login
    method: POST
    url: ${base_url}/login
    body:
      form:
        username: alice
        password: hunter2
```

Rules:
- `${name}` resolves from the file's `variables:` block.
- `${env:NAME}` resolves from the process environment at run time. Missing env vars error out — don't paper over with empty strings.
- `body:` is either `json:` **or** `form:`, never both (the parser rejects it). For JSON bodies, `Content-Type: application/json` is added automatically if you didn't set it.
- `method:` must be a valid HTTP verb; `GET`/`DELETE` ignore `body:`.

### Overriding from the CLI

Trailing `key:value` / `key=value` params on `wave -c ...` are merged into the saved request:
- Headers with the same name are replaced; new headers are appended.
- Body fields with the same key are replaced (with the CLI's type inference applied); new fields are appended.

`--var key=value` is used to overwrite a `variable` defined in the collection for the current request

Use this to vary one input across runs without editing YAML:

```
wave -c users create-user name=bob age=25
wave -c users get-user Authorization:Bearer$(cat .token)
```

## Testing workflow

When a task says "verify this endpoint" or "test the API":

1. **Check for an existing collection.** `ls .wave/` first. If a collection covers the endpoint, run it — don't re-author. Collections are the canonical record of expected requests for whatever project you're in.
2. **Make sure the target server is running.** Start it the way that project documents if it isn't already up. The collection's `base_url` tells you which host/port to expect.
3. **Run the request** with `-v` so you can see status and headers. Default output hides headers on 2xx, which is fine for green-path checks but unhelpful when debugging.
4. **Assert on the response by reading the output.** `wave` prints status with color and pretty-prints JSON bodies. There's no built-in assertion mode — for pass/fail logic, parse the body yourself (e.g. `wave -c api get-user | jq ...`) or check the exit code (non-zero = network/CLI error, not HTTP status).
5. **If the request doesn't exist yet, add it to an existing collection** rather than creating a one-off `.yaml`. Group requests by the API they target (one collection per service). Use `variables:` for `base_url` and anything you'd otherwise repeat.

A 4xx/5xx response is **not** a CLI failure — `wave` exits 0 and prints the body. Read the output before declaring success.

## Common pitfalls

- **Wrong file location.** `.wave/` must be in the directory you invoke `wave` from, not in the project root. `cd` first.
- **Forgetting the scheme on a non-default port.** `wave get localhost:8080/health` works (scheme auto-added), but `wave get 8080/health` does not — bare ports without a host fail validation.
- **Quoting body values with spaces.** Shell quoting rules apply: `wave post ... 'message=hello world'`.
- **Headers vs body confusion.** `Auth:Bearer foo` is a header. `auth=Bearer foo` is a body field. Mistaking one for the other silently produces the wrong request — the CLI doesn't warn.
- **`${env:VAR}` resolution is at run time.** Export the var in the shell that runs `wave`, or pass it inline: `API_TOKEN=xyz wave -c api get-user`.
- **CLI type inference can surprise you.** `wave -c api create-user id=007` sends `"id": 7` (parsed as int). Force a string by making it non-numeric (`id=user007`) or edit the collection YAML where the type is explicit.

## When to reach for something else

- Need to script multi-step flows with response-to-request data passing (auth → call → assert)? `wave` doesn't chain. Drive it from a shell script with `jq`, or use a proper test framework.
- Need streaming, websockets, or large file upload? Out of scope — use `curl`.
- Building a real test suite that asserts on response contents? Write it in the project's test language; `wave` is for interactive verification and reproducible canned requests, not for CI assertions.
