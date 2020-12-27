MangaOneLove = Parser:new("MangaOneLove", "https://mangaonelove.ru", "RUS", "MANGAONELOVERU", 1)

local function downloadContent(link)
	local f = {}
	Threads.insertTask(
		f,
		{
			Type = "StringRequest",
			Link = link,
			Table = f,
			Index = "text"
		}
	)
	while Threads.check(f) do
		coroutine.yield(false)
	end
	return f.text or ""
end

local function stringify(string)
	return string:gsub(
		"&#([^;]-);",
		function(a)
			local number = tonumber("0" .. a) or tonumber(a)
			return number and u8c(number) or "&#" .. a .. ";"
		end
	):gsub(
		"&(.-);",
		function(a)
			return HTML_entities and HTML_entities[a] and u8c(HTML_entities[a]) or "&" .. a .. ";"
		end
	)
end

local function stringify2(string)
	return string:gsub(
		"\\u(....)",
		function(a)
			return u8c(tonumber("0x" .. a))
		end
	)
end

function MangaOneLove:getManga(link, dt)
	local content = downloadContent(link)
	dt.NoPages = true
	for Link, Name, ImageLink in content:gmatch('manga%-item%-.-href="[^"]-/manga/(.-)/" title="(.-)".-data%-src="(.-)"') do
		dt[#dt + 1] = CreateManga(stringify(Name), Link, ImageLink, self.ID, self.Link .. "/manga/" .. Link)
		dt.NoPages = false
		coroutine.yield(false)
	end
end

function MangaOneLove:getPopularManga(page, dt)
	self:getManga(self.Link .. "/manga/page/" .. page .. "/?m_orderby=rating", dt)
end

function MangaOneLove:getAZManga(page, dt)
	self:getManga(self.Link .. "/manga/page/" .. page .. "/?m_orderby=alphabet", dt)
end

function MangaOneLove:getLatestManga(page, dt)
	self:getManga(self.Link .. "/manga/page/" .. page .. "/?m_orderby=latest", dt)
end

function MangaOneLove:searchManga(search, page, dt)
	local content = downloadContent(self.Link .. "/page/" .. page .. "/?s=" .. search .. "&post_type=wp-manga")
	dt.NoPages = true
	for Link, Name, ImageLink in content:gmatch('item__content".-href="[^"]-/manga/(.-)/" title="(.-)".-data%-src="(.-)"') do
		dt[#dt + 1] = CreateManga(stringify(Name), Link, ImageLink, self.ID, self.Link .. "/manga/" .. Link)
		dt.NoPages = false
		coroutine.yield(false)
	end
end

function MangaOneLove:getChapters(manga, dt)
	local content = downloadContent(self.Link .. "/manga/" .. manga.Link)
	local t = {}
	for Link, Name in content:gmatch('wp%-manga%-chapter%s*"> <a href="[^"]+/([^"]-)/">(.-)</a>') do
		t[#t + 1] = {
			Name = stringify(Name),
			Link = Link,
			Pages = {},
			Manga = manga
		}
	end
	for i = 1, #t do
		dt[#dt + 1] = t[i]
	end
end

function MangaOneLove:prepareChapter(chapter, dt)
	local content = downloadContent(self.Link .. "/manga/" .. chapter.Manga.Link .. "/" .. chapter.Link)
	content = content:match("chapter_preloaded_images = %[(.-)%]")
	for Link in content:gmatch('"(.-)"') do
		dt[#dt + 1] = Link:gsub("\\/", "/")
	end
end

function MangaOneLove:loadChapterPage(link, dt)
	dt.Link = link
end
