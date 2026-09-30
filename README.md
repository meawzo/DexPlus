<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Roblox Decal Asset Catalog</title>
<style>
body{font-family:system-ui,-apple-system,sans-serif;max-width:720px;margin:2rem auto;padding:0 1.25rem;line-height:1.55;color:#1a1a1a;background:#fafafa}
h1{font-size:1.75rem;margin-bottom:.25rem}
h2{font-size:1.2rem;margin-top:2rem;border-bottom:1px solid #ddd;padding-bottom:.3rem}
code,pre{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:.9em}
pre{background:#111;color:#e8e8e8;padding:1rem;overflow-x:auto;border-radius:6px}
.tag{display:inline-block;background:#e8f0fe;color:#1a56db;font-size:.75rem;padding:.15rem .5rem;border-radius:4px;margin-right:.4rem}
footer{margin-top:3rem;font-size:.85rem;color:#666}
a{color:#1a56db}
</style>
</head>
<body>
<h1>Roblox Decal Asset Catalog</h1>
<p><span class="tag">Lua</span><span class="tag">Open Source</span><span class="tag">MIT</span></p>
<p>A small, dependency-free Lua module for searching and inspecting free Roblox decals from the library.</p>

<h2>What it does</h2>
<ul>
<li>Searches free decals by keyword via <code>InsertService:GetFreeDecals</code></li>
<li>Pulls metadata (name, creator, description, price, timestamps) with <code>MarketplaceService:GetProductInfo</code></li>
<li>Builds ready-to-use thumbnail URLs and <code>rbxassetid://</code> URIs</li>
<li>Optional batch enrichment with built-in rate limiting</li>
</ul>

<h2>How it works</h2>
<p>The core search path uses Roblox’s own free-library API. No third-party proxy is required for <code>SearchFree</code>. Product info is fetched through the standard MarketplaceService call. Thumbnail links use the <code>rbxthumb</code> protocol so they resolve directly inside Studio and experiences.</p>

<h2>Quick start</h2>
<pre>local DecalCatalog = require(path.to.DecalCatalog)

local hits = DecalCatalog.SearchFree("brick", 1)
for _, item in ipairs(hits) do
    print(item.id, item.name)
end

local info = DecalCatalog.GetInfo(hits[1].id)
print(info.name, info.creator)

local thumb = DecalCatalog.GetThumbnailUrl(hits[1].id)
local uri   = DecalCatalog.GetAssetUri(hits[1].id)</pre>

<h2>Files</h2>
<ul>
<li><code>DecalCatalog.lua</code> — the module (no comments)</li>
<li><code>README.md</code> — usage and API reference</li>
<li><code>index.html</code> — this page</li>
</ul>

<h2>License</h2>
<p>MIT. Fully open source. Use it, fork it, ship it.</p>

<footer>
Roblox Decal Asset Catalog — pure Lua helper for free library decals.
</footer>
</body>
</html>
