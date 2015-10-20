local http, json = http, json

--[[
This module provides a minimal Slack client for using an 'Incoming WebHooks'
integration configured via Slack.
]]
module('slack')
_DESCRIPTION = 'Slack webhook client'
_VERSION = 'slack 0.1'

--[[
getClient

Get a Slack API client.

Parameters
	settings: A table containing the Slack webhook data. The following fields are supported:
		• url: the URL of the Slack endpoint to ping.
		• username (optional): the default display name to show in Slack; defaults to the integration settings in Slack.
		• icon_url (optional): the URL of the avatar to show in Slack; defaults to the integration settings in Slack.
		• channel (optional): the channel to notify (like '#channel'); defaults to the integration settings in Slack.
]]
function getClient(settings)
	-- validate
	if not settings.url or settings.url == '' then
		error('The \'url\' setting is required')
	end

	-- build client
	local client = { settings = settings }
	
	--[[
	post

	Send a message to the Slack integration. If the webhook fails, this throws an informative error.

	Parameters
		text: the message text to send.
		settings: (optional) A table containing message settings. The following fields are supported:
			• username (optional): the display name to show in Slack; defaults to the integration settings in Slack.
			• icon_url (optional): the URL of the avatar to show in Slack; defaults to the integration settings in Slack.
			• channel (optional): the channel to notify (like '#channel'); defaults to the integration settings in Slack.
	]]
	function client.post(text, options)
		options = options or {}
		response = http.request({
			url = options.url or settings.url,
			method = 'POST',
			data = json.stringify({
				username = options.username or settings.username,
				icon_url = options.icon_url or settings.icon_url,
				channel = options.channel or settings.channel,
				text = text
			})
		})
		
		if response.statuscode ~= 200 then
			error('Couldn\'t send a message to Slack. Their webhook returned HTTP ' .. response.statuscode .. ': ' .. response.content)
		end
	end

	return client
end