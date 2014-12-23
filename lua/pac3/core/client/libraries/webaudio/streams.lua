-- made by Morten and CapsAdmin

pac.webaudio = pac.webaudio or {}
local webaudio = pac.webaudio

webaudio.Streams = webaudio.Streams or {}

webaudio.Streams.LastStreamId = 0
webaudio.Streams.Streams      = {}

function webaudio.Streams.CreateStream(url)
	--url = url:gsub("http[s?]://", "http://")

	if not string.find(url, "http") then
		url = "asset://garrysmod/sound/" .. url
	end

	local stream = setmetatable({}, webaudio.Streams.STREAM)

	webaudio.Streams.LastStreamId = webaudio.Streams..LastStreamId + 1
	stream:SetId(webaudio.Streams.LastStreamId)
	stream:SetUrl(url)
	
	webaudio.Streams[stream.id] = stream
	
	webaudio.Browser.QueueJavascript(string.format("createStream(%q, %d)", stream:GetUrl(), stream:GetId()))
	
	return stream
end

function webaudio.Streams.GetStream(streamId)
	return webaudio.Streams.Streams[streamId]
end

function webaudio.Streams.StreamExists(streamId)
	return webaudio.Streams.Streams[streamId] ~= nil
end

function webaudio.Streams.Think()
	for streamId, stream in pairs(webaudio.Streams.Streams) do
		if stream:IsValid() then
			stream:Think()
		else
			stream:Stop()
			webaudio.Streams[streamId] = nil
			webaudio.Browser.QueueJavascript(string.format("destroyStream(%i)", stream.id))

			setmetatable(stream, getmetatable(NULL))
		end
	end
end