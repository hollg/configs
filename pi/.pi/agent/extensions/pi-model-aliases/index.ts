import { existsSync, readFileSync } from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getAgentDir } from "@earendil-works/pi-coding-agent";

type ModelDefinition = Record<string, unknown> & { id: string };
type ProviderDefinition = Record<string, unknown> & { models?: ModelDefinition[] };

interface AliasConfig {
  provider: string;
  aliasProvider?: string;
  aliases: Record<string, string>;
  defaultAlias?: string;
}

function loadConfig(): AliasConfig | undefined {
  const configPath = path.join(getAgentDir(), "model-aliases.json");
  if (!existsSync(configPath)) return undefined;

  try {
    const parsed = JSON.parse(readFileSync(configPath, "utf8")) as Partial<AliasConfig>;
    if (!parsed.provider || !parsed.aliases || typeof parsed.aliases !== "object") return undefined;
    return {
      provider: parsed.provider,
      aliasProvider: parsed.aliasProvider || "primary",
      aliases: parsed.aliases,
      defaultAlias: parsed.defaultAlias,
    };
  } catch (error) {
    console.error(`Failed to read ${configPath}:`, error);
    return undefined;
  }
}

function loadProvider(providerName: string): ProviderDefinition | undefined {
  const modelsPath = path.join(getAgentDir(), "models.json");
  if (!existsSync(modelsPath)) return undefined;

  try {
    const parsed = JSON.parse(readFileSync(modelsPath, "utf8")) as {
      providers?: Record<string, ProviderDefinition>;
    };
    return parsed.providers?.[providerName];
  } catch (error) {
    console.error(`Failed to read ${modelsPath}:`, error);
    return undefined;
  }
}

export default function (pi: ExtensionAPI): void {
  const config = loadConfig();
  if (!config) return;

  const source = loadProvider(config.provider);
  if (!source?.models?.length) {
    console.error(`Model alias source provider "${config.provider}" has no configured models.`);
    return;
  }

  const modelsById = new Map(source.models.map((model) => [model.id, model]));
  const aliases = Object.entries(config.aliases).map(([alias, modelId]) => {
    const sourceModel = modelsById.get(modelId);
    if (!sourceModel) {
      throw new Error(`Model alias "${alias}" points to unknown model "${modelId}".`);
    }

    return {
      ...sourceModel,
      name: alias,
    };
  });

  const aliasProvider = config.aliasProvider || "primary";
  pi.registerProvider(aliasProvider, {
    ...source,
    name: `${config.provider} model aliases`,
    models: aliases,
  });

  pi.on("session_start", async (_event, ctx) => {
    const alias = config.defaultAlias;
    if (!alias) return;

    const modelId = config.aliases[alias];
    const model = modelId ? ctx.modelRegistry.find(aliasProvider, modelId) : undefined;
    if (model) await pi.setModel(model);
  });

  pi.registerCommand("model-aliases", {
    description: "List configured model aliases",
    handler: async (_args, ctx) => {
      const lines = Object.entries(config.aliases).map(([alias, modelId]) => `${alias}: ${modelId}`);
      ctx.ui.notify(lines.join("\n"), "info");
    },
  });

  pi.registerCommand("model-alias", {
    description: "Switch to a configured model alias",
    handler: async (alias, ctx) => {
      const modelId = config.aliases[alias.trim()];
      if (!modelId) {
        ctx.ui.notify(`Unknown model alias "${alias.trim()}". Use /model-aliases.`, "error");
        return;
      }

      const model = ctx.modelRegistry.find(aliasProvider, modelId);
      if (!model) {
        ctx.ui.notify(`Could not find model for alias "${alias.trim()}".`, "error");
        return;
      }

      const changed = await pi.setModel(model);
      if (!changed) {
        ctx.ui.notify(`Could not select model alias "${alias.trim()}".`, "error");
        return;
      }

      ctx.ui.notify(`Using ${alias.trim()} (${modelId})`, "info");
    },
  });
}
