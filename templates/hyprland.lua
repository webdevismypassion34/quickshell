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
  }
})
