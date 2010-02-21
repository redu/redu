var flashvars = {
				config_url: 'constellation_config.xml',
				selected_node_id: '1',
				instance_id: '1',
				passthru: 'user_id=<%=current_user.id%>',
				debug: 'false'
			};
			
			var params = {
				bgcolor: '#ffffff',
				allowScriptAccess: 'sameDomain',
				quality: 'high',
				scale: 'noscale'
			};
			
			var attributes = {
				id: "constellation_roamer",
				name: "constellation_roamer"
			};
			
			swfobject.embedSWF(
				"constellation_roamer.swf", "constellation", "100%", "100%",
				"9", "expressInstall.swf", flashvars, params, attributes);