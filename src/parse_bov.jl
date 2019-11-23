using HTTP
using JSON
using PyCall

function sips_req()
	bov = pyimport("sips.lines.bov.bov")
	lines = bov.lines(["nba"], output="list")
	return lines
end
