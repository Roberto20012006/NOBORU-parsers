Submanga=Parser:new("Submanga","https://submangas.net","ESP","SUBMANGASPA",1)local function a(b)local c={}Threads.insertTask(c,{Type="StringRequest",Link=b,Table=c,Index="string"})while Threads.check(c)do coroutine.yield(false)end;return c.string or""end;function Submanga:getManga(b,d)local e=a(b)local f=d;local g=true;for h,i,j in e:gmatch('<a href="([^"]-)"[^>]->[^>]-src=\'([^\']-)\' alt=\'([^\']-)\'>[^<]-</a>')do local k=CreateManga(j,h,i,self.ID,h)if k then f[#f+1]=k;g=false end;coroutine.yield(false)end;if g then f.NoPages=true end end;function Submanga:getPopularManga(l,d)self:getManga(self.Link.."/filterList?sortBy=views&asc=false&page="..l,d)end;function Submanga:searchManga(m,l,d)self:getManga(self.Link.."/filterList?alpha="..m.."&sortBy=views&asc=false&page="..l,d)end;function Submanga:getChapters(k,d)local e=a(k.Link)local f={}for h,j in e:gmatch('fa fa%-eye"></i>[^<]-<a href="([^"]-)">([^<]-)</a>')do f[#f+1]={Name=j,Link=h,Pages={},Manga=k}end;for n=#f,1,-1 do d[#d+1]=f[n]end end;function Submanga:prepareChapter(o,d)local e=a(o.Link)local f=d;for h in e:gmatch('img%-responsive"[^>]-data%-src=\' ([^\']-) \'')do f[#f+1]=h end end;function Submanga:loadChapterPage(b,d)d.Link=b end