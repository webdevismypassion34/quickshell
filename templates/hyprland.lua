hl.config({ 
  general = { 
    gaps_in = $insideMargin,
    gaps_out = $outsideMargin,

    col = {
			active_border = "rgba(${border:nohash}ff)",
			inactive_border = "rgba(${border:nohash}ff)",
		},
  },
  
  decoration = {
    rounding = $rounding,
    rounding_power = $power,
  },

  animations = {
    enabled = $animationsEnabled,
  },

  input = {
    sensitivity = $sensitivity,
    accel_profile = "$accelProfile",

    touchpad = {
      natural_scroll = $naturalScroll,
      tap_to_click = $tapToClick,
    },
  }
})
