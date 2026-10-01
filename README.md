# Roblox Decal Asset Catalog

Open-source Lua tools for searching free Roblox library decals.

MIT License.

## Files

| File | Description |
|------|-------------|
| `DecalCatalog.lua` | Module API for free-decal search / info / thumbnails |
| `DecalCatalogUI.lua` | In-game UI (executor script) with search, pages, copy |

## Features

### Module (`DecalCatalog.lua`)
- Search free decals via `InsertService:GetFreeDecals`
- Product info helpers
- Thumbnail URL helpers
- Batch enrich helpers

### UI (`DecalCatalogUI.lua`)
- Search bar with Lucide-style icons
- Result cards (thumbnail, name, asset id)
- Copy asset id to clipboard
- Pagination (up to 512 pages)
- Draggable window, smooth open animation
- Compact minimize (title bar only)
- Animated stroke gradients

## Requirements

- Roblox client with an executor that supports:
  - `InsertService:GetFreeDecals` (primary search)
  - Optional: `HttpGet` / `request` for catalog API fallbacks
  - Optional: `setclipboard` / `toclipboard` for copy

Studio Plugin / ModuleScript use works for the module alone (no executor).

## Quick start — UI

1. Open an executor in a Roblox session.
2. Paste and run the full contents of `DecalCatalogUI.lua`.
3. Type a keyword in the search box and press **Enter**.
4. Use the arrows to change page.
5. Click the copy icon on a card to copy the asset id.

## Quick start — Module

```lua
local DecalCatalog = require(path.to.DecalCatalog)

local results = DecalCatalog.SearchFree("car", 1)
for _, item in ipairs(results) do
    print(item.id, item.name)
end

local info = DecalCatalog.GetInfo(results[1].id)
print(info and info.Name)

local url = DecalCatalog.GetThumbnailUrl(results[1].id)
```

API shape may vary slightly by version; open `DecalCatalog.lua` for the exact exports.

## Search notes

1. Primary path: `InsertService:GetFreeDecals(query, page)`.
2. Fallbacks (page 1): catalog / library HTTP endpoints (Decal / Image types) when the executor allows HTTP.
3. Results are free library assets only — not the full paid marketplace catalog.
4. Rate limits and empty pages are normal on high page numbers or rare keywords.

## UI controls

| Control | Action |
|---------|--------|
| Search box + Enter | Run search from page 1 |
| Left / right arrows | Previous / next page |
| Copy icon | Copy asset id |
| Top-right icon | Minimize to compact bar / restore |
| Title bar | Drag window |

## License

MIT — free to use, modify, and redistribute.

```
MIT License

Copyright (c) 2026 Decal Catalog contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Disclaimer

This project targets free Roblox library assets for development and research.
Respect Roblox [Terms of Use](https://en.help.roblox.com/hc/en-us/articles/115004647846) and only use asset ids in experiences you are allowed to edit.
