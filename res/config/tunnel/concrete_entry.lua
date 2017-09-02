function data()
return {
	name = _("Standard tunnel"),
	carriers = { "RAIL" },
	portals = {
		{ "track_design_patterns/tunnel_left.mdl", "track_design_patterns/tunnel_fence.mdl", "track_design_patterns/tunnel_right.mdl" },
		{ "track_design_patterns/tunnel_left.mdl", "track_design_patterns/tunnel_fence.mdl", "track_design_patterns/tunnel_right.mdl" },
		{ "track_design_patterns/tunnel_left.mdl", "track_design_patterns/tunnel_fence.mdl", "track_design_patterns/tunnel_right.mdl" },
	},
	--minTracks = 1,
	--maxTracks = 4,
	cost = 1000.0
}
end
