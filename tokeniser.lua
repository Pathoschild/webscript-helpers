local string, table, pairs, unpack = string, table, pairs, unpack

--[[
This module extracts tokens from raw text based on the specified patterns. It's
mainly intended for webhooks that need to parse incoming payloads (e.g. parsing
the details from an Amazon Web Services email alert).
]]
module('tokeniser')
_DESCRIPTION = 'Text payload tokeniser'
_VERSION = 'tokeniser 0.1'

--[[
capture

Returns substrings matched by capturing groups in a regex pattern. This is
equivalent to the values returned by string.find without the start & end
indexes.

Parameters
	text: The text to search.
	pattern: The regex pattern containing capturing groups.

Example:
	local username, messages = tokeniser.capture("Hi Bob! You have 42 points.", "Hi ([^!]+)! You have (\d+) points")
]]
function capture(text, pattern)
	local values = {string.find(text, pattern)}
	table.remove(values, 1)
	table.remove(values, 1)
	return unpack(values)
end

--[[
parseTokens

Extracts tokens from a raw text (based on the specified patterns) and adds them
to the provided table. If the table already contains a matched token, it will
be overwritten.

Parameters
	tokens: A table to populate with tokens.
	text: The text to parse.
	map: A table indicating how to parse the message. The keys should be the
		token names, and the values should be a regex pattern whose first
		capture contains the token value.

Example:
	local tokens = {}
	tokeniser.parseTokens(tokens, "Service: Amazon Beanstalk\nError: something went very wrong.", { service = "Service: ([^\n]+)", error = "Error: ([^\n]+)" })
]]
function parse(tokens, text, map)
	for name, pattern in pairs(map) do
		local _, _, value = string.find(text, pattern)
		tokens[name] = value or ''
	end
end