-- http://daringfireball.net/2009/01/applescripts_targetting_safari_or_webkit
on getCurrentSafariUrl(_browser)
	using terms from application "Safari"
		tell application _browser
			return URL of the first document as Unicode text
		end tell
	end using terms from
end getCurrentSafariUrl

on getCurrentFirefoxUrl()
	-- Does not support necessary AppleScript
end getCurrentFirefoxUrl

on getCurrentChromeUrl()
	-- Does not support necessary AppleScript
end getCurrentChromeUrl

on getCurrentOperaUrl()
	-- Does not support necessary AppleScript
end getCurrentOperaUrl

on getCurrentCaminoUrl(_browser)
	using terms from application "Camino"
		tell application _browser
			return the URL of the current tab of the first browser window
		end tell
	end using terms from
end getCurrentCaminoUrl