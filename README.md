# Roblox Decal Asset Catalog

Pure Lua module for searching and inspecting free Roblox decals (library assets).

Open source. MIT License.

## What it does

- Search free decals by keyword using `InsertService:GetFreeDecals`
- Fetch asset metadata via `MarketplaceService:GetProductInfo`
- Generate thumbnail URLs and `rbxassetid://` URIs
- Optional enrichment (name, creator, description, price, etc.)

No external proxies required for the core search path.

## Install

1. Copy `DecalCatalog.lua` into your place (ServerScriptService, ReplicatedStorage, or a ModuleScript).
2. Require it:

```lua
local DecalCatalog = require(path.to.DecalCatalog)
