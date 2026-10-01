local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")

local DecalCatalog = {}

function DecalCatalog.SearchFree(query, page)
	page = page or 1
	local ok, result = pcall(function()
		return InsertService:GetFreeDecals(query, page)
	end)
	if not ok or not result then
		return {}
	end
	local list = {}
	for _, entry in ipairs(result) do
		if type(entry) == "table" then
			local assetId = entry.AssetId or entry.assetId or entry.Id or entry.id
			local name = entry.Name or entry.name or ""
			if assetId then
				table.insert(list, {
					id = tonumber(assetId),
					name = tostring(name),
					raw = entry
				})
			end
		end
	end
	return list
end

function DecalCatalog.GetInfo(assetId)
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
	end)
	if not ok or not info then
		return nil
	end
	return {
		id = info.AssetId or assetId,
		name = info.Name or "",
		description = info.Description or "",
		creator = info.Creator and (info.Creator.Name or "") or "",
		creatorId = info.Creator and (info.Creator.Id or 0) or 0,
		assetTypeId = info.AssetTypeId or 0,
		created = info.Created or "",
		updated = info.Updated or "",
		isForSale = info.IsForSale or false,
		price = info.PriceInRobux or 0
	}
end

function DecalCatalog.GetThumbnailUrl(assetId, size)
	size = size or 420
	return string.format("rbxthumb://type=Asset&id=%d&w=%d&h=%d", assetId, size, size)
end

function DecalCatalog.GetAssetUri(assetId)
	return "rbxassetid://" .. tostring(assetId)
end

function DecalCatalog.SearchAndEnrich(query, page, maxEnrich)
	maxEnrich = maxEnrich or 20
	local results = DecalCatalog.SearchFree(query, page)
	local enriched = {}
	for i, item in ipairs(results) do
		if i > maxEnrich then
			break
		end
		local info = DecalCatalog.GetInfo(item.id)
		if info then
			info.thumbnail = DecalCatalog.GetThumbnailUrl(item.id)
			info.uri = DecalCatalog.GetAssetUri(item.id)
			table.insert(enriched, info)
		else
			table.insert(enriched, {
				id = item.id,
				name = item.name,
				thumbnail = DecalCatalog.GetThumbnailUrl(item.id),
				uri = DecalCatalog.GetAssetUri(item.id)
			})
		end
		task.wait(0.1)
	end
	return enriched
end

function DecalCatalog.BatchInfo(assetIds)
	local out = {}
	for _, id in ipairs(assetIds) do
		local info = DecalCatalog.GetInfo(id)
		if info then
			info.thumbnail = DecalCatalog.GetThumbnailUrl(id)
			info.uri = DecalCatalog.GetAssetUri(id)
			table.insert(out, info)
		end
		task.wait(0.08)
	end
	return out
end

return DecalCatalog
