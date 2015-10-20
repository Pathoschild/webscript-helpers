local alert, pcall = alert, pcall

--[[
This module provides utilities for error-monitoring webhooks on Webscript.io.
]]
module('monitoring')
_DESCRIPTION = 'Webscript error monitoring'
_VERSION = 'monitoring 0.1'

--[[
getMonitor

Build a monitor which runs arbitrary code and catches errors for handling.
If there are no handlers (or none of the handlers handle the error), this
will notify the webhook owner via email.

Parameters
	name: a human-readable name for the webhook (like 'AWS event').
	request: The received HTTP request.
	handlers: The functions to call when an error occurs. Each function is
		passed three arguments (error, request, webhook name), and must return
		whether the error was handled. If a handler raises an error, it will be
		discarded and treated as if the handler had returned false.
]]
function get(name, request, handlers)
	return {
		--[[
		monitor

		Invoke a lambda and catch any errors it raises for handling.

		Parameters
			lambda: the function to invoke.
		]]
		monitor = function(lambda)
			-- run webhook
			local success, err = pcall(lambda)
			
			-- handle errors
			if not success then
				-- invoke handlers
				local handled = false
				if handlers then
					for i = 0, #handlers do
						pcall(function()
							handled = handlers[i](err, request, name)
						end)

						if handled then
							break
						end
					end
				end

				-- fallback to email
				if not handled then
					local message = 'Webhook (' .. name .. ') failed.\n\nError:\n> ' .. error .. '\n\nreceived message:\n> ' .. request.body
					alert.email(details)
				end

				-- format error response (if returned by the webhook)
				return 500, json.stringify(err)
			end

			-- format success response (if returned by the webhook)
			return 200
		end
	}
end

--[[
getSlackNotifier

Get an error handler that notifies a Slack channel.

Parameters
	slack: The configured Slack integration to notify.
]]
function getSlackNotifier(slack)
	return function(error, request, name)
		local message = 'Webhook (' .. name .. ') failed.\n\nError:\n> ' .. error .. '\n\nreceived message:\n> ' .. request.body
		slack.post(message)
		return true
	end
end