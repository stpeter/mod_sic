-- Module: mod_sic
-- Author: Peter Saint-Andre

--[[

OVERVIEW

This module implements Server IP Check [sic] as specified in
(XEP-0279). See http://xmpp.org/extensions/xep-0279.html for
details.

]]

--[[

CONFIGURATION

Add mod_sic to the "modules_enabled", as you would for any other
Prosody module.

modules_enabled = {
  "mod_sic",
}

]]

-- invoke various utilities
local jid_split = require "util.jid".split;
local st = require "util.stanza";

-- declare namespace and advertise support
local xmlns_sic = "urn:xmpp:sic:1";
module:add_feature("urn:xmpp:sic:1");

function handle_request(event)
        -- assign some values
	local session, stanza = event.origin, event.stanza;
	local username, host = jid_split(stanza.attr.from);
        -- handle the IQ
	if stanza.attr.to then 
                -- it's an attack to request someone else's IP address
                session.send(st.error_reply(stanza, "auth", "forbidden"));
	elseif stanza.attr.type == "set" then 
                -- can't *set* IP and port, return bad-request error
                session.send(st.error_reply(stanza, "modify", "bad-request"));
	elseif stanza.attr.type == "get" then
		local reply = st.reply(stanza):tag("address", { xmlns = xmlns_sic });
		reply:tag("ip"):text(session.ip):up();
                -- the Prosody session object does not yet expose the port;
                -- not sure how to capture that...
		-- reply:tag("port"):text(session.port):up();
		session.send(reply);
		return true;
	end
end

-- register for events
module:hook("iq/self/"..xmlns_sic..":address", handle_request);
