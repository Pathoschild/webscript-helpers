A collection of simple Lua modules for writing Webscript.io webhooks
(see _[Including Modules From GitHub](https://www.webscript.io/documentation#modules)_).

### Tokeniser
This module extracts tokens from arbitrary text. It's mainly intended for
webhooks that need to parse text payloads.

For example, Amazon Web Services sends alert emails that look like this:
> **AWS Elastic Beanstalk Notification - New application version was deployed to running EC2 instances**
> 
> Timestamp: Fri Oct 16 15:40:00 UTC 2015  
> Message: New application version was deployed to running EC2 instances.  
> Environment: sample-api-edge  
> Application: sample-api  
> Environment URL: http://sample-api-edge.elasticbeanstalk.com

This module lets you tokenise simple strings like the subject:

```lua
local service, subject = tokeniser.getCaptures(payload.subject, "^AWS ([^-]+) Notification - (.+)")
```

Or tokenise complex strings:

```lua
local tokens = {}
tokeniser.parse(tokens, payload.body, {
   timestamp = "Timestamp: ([^\r\n]+)",
   message = "Message: ([^\r\n]+)",
   environment = "Environment: ([^\r\n]+)",
   environmentUrl = "Environment URL: ([^\r\n]+)",
   application = "Application: ([^\r\n]+)"
})
```

(See the docstrings in the Lua file for details.)