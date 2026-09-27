# Pi model aliases

This extension gives Pi stable model names that can map to different providers and model IDs on each machine.

## Configure it

Create the ignored local config beside this extension:

```bash
cp ~/.pi/agent/model-aliases.json.example ~/.pi/agent/model-aliases.json
```

Use this shape:

```json
{
  "provider": "local-provider-name",
  "aliasProvider": "primary",
  "defaultAlias": "balanced",
  "aliases": {
    "fast": "provider-model-id",
    "balanced": "provider-model-id",
    "powerful": "provider-model-id"
  }
}
```

`provider` must name a provider in `~/.pi/agent/models.json`. The extension copies its provider configuration and exposes the aliases through `aliasProvider`. Provider credentials and model IDs stay in ignored local files.

`defaultAlias` is optional. When set, the extension selects that alias at session start. This is the supported way to configure an aliased default.

## Use aliases

Select an alias from an interactive session:

```text
/model-alias fast
```

List the configured aliases:

```text
/model-aliases
```

Named agents can select aliases with the provider-qualified form:

```yaml
model: primary/fast
```

The provider-qualified form matters because Pi resolves a model name without a provider against all available providers.

## Important limitation

Do not set this in Pi's shared `settings.json`:

```json
"defaultModel": "balanced"
```

Pi resolves `defaultModel` as an exact model ID before extensions can resolve aliases. Use `defaultAlias` in the ignored local alias config instead.

## Provider configuration

The source provider must be configured in `~/.pi/agent/models.json`. The extension copies its provider settings and models, then gives the configured models alias names without changing their model IDs.
