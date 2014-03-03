--[[

glemasters
poetics of mobile, etc., etc.



Let's draw a building and add some windows.

This code calculates all of the measurements necessary for the layout of my building... but it does those calculations as if the building were located in the upper left-hand corner of the screen.  In essence, then, we construct a "virtual" building, stuff the relative-coordinates of its windows into a table, and then return that table to whomever called us in the first place.  It is up to them to (1) figure out where on the screen the building goes and then (2) draw our windows on top of their building.

]]--

local function installWindows( bW, bRC, bH, bFC )

-- To start the function, I pass width, room count, height, floor count to installWindows().
-- I used short variable names inside the parentheses just to keep things neat.  We don't have to do this, but for clarity's sake, let's transfer the stuff stored in those short names to the "real" variables:

	local bldgWidth = bW
	local bldgHeight = bH
	local bldgFloorCount = bFC
	local bldgRoomCount = bRC

	-- Writing interesting code means always trying to rethink the world
	-- in numeric terms.  Its a challenge, especially for those of us who
	-- never got past advanced algebra:  It seemed so difficult at the time.
	-- It turns out, according to scholars like Seymour Papert, that it
	-- wasn't my fault that algebra seemed so alien, it was the fault of
	-- modern curricula.  Math, he says, should be intuitive, and pleasurable.
	-- When I became more serious about my code while I was in grad school,
	-- I suddenly discovered what Papert means:  For lack of a better term,
	-- it is genuinely fun to think about how audio compression works, or
	-- how to increase the contrast on a scanned photograph, or even how
	-- to model a tiny economy in a lemonade stand simulator.

	-- So based on the four numbers we know, let's see what we can posit.

	-- Presently, we don't know (1) where the windows are on the building,
	-- or (2) how big they are.  So let's define that second part ourselves.

	-- Let's do it by creating a ratio:
	-- If window is 1/2 width of room:
	local windowWidthToRoomWidthRatio = 1 / 2 -- (or 0.5)
	-- this means, simply, that to find the window's width, we merely
	-- multiply the room's width by our ratio (e.g., multiply it by 0.5).

	-- same deal:
	local windowHeightToFloorHeightRatio = 1 / 2 -- again, 0.5

	-- See if you can tell what these do.  The math.round() function, obviously,
	-- takes a floating-point number (e.g., 3.175) and changes it to an integer
	-- (e.g., 3).  Since the addresses on the screen are all whole numbers,
	-- decimal points are usually (but not always) useless.

	local bldgRoomWidth = math.round( bldgWidth / bldgRoomCount )
	local bldgFloorHeight = math.round( bldgHeight / bldgFloorCount )

	-- Given the width of the building, and the number of rooms, it is relatively
	-- easy to discern the width of each room.  Which means, thank you very much,
	-- that by using our ratio (from above), we also know the window width.

	local bldgWindowWidth = math.round( bldgRoomWidth * windowWidthToRoomWidthRatio )
	local bldgWindowHeight = math.round( bldgFloorHeight * windowHeightToFloorHeightRatio )

	-- To reiterate:  With this approach, everything is RELATIVE.  bldgCenterX
	-- assumes that the building starts at x=0.  Now roomCenterX assumes the same thing:
	-- that this room is as far to the left (x=0) as possible.

	local roomCenterX = bldgRoomWidth * 0.50
	local roomCenterY = bldgFloorHeight * 0.50

-- But if we are careful about discovering all our relative values, everything else will fall in place once we have a single x,y coordinate.  (Archimedes:  Give me a lever of sufficient length, and a fulcrum, and I will move the world).

-- Once we've computed the sizes and centers of our building, rooms, and windows, we are ready (finally) to compute the layout of a floor.

-- Again:  This approach assumes that our "virtual" building is currently pressing its upper-left-hand corner into the upper-left-hand corner of our screen (i.e., both left-hand corners are touching at 0,0).  As always, there are various ways to do this:  My approach is just one of them.

-- First off, margins:  It is very likely that our rooms won't sit neatly inside our building's shell:  They may be too wide, or too narrow.  So we need to figure out the left, right, top and bottom "margins" of the building.

	local remainderX = bldgWidth - ( bldgRoomWidth * bldgRoomCount )
	local remainderY = bldgHeight - ( bldgFloorHeight * bldgFloorCount )

-- gateaux sec!  Now we've got the L/R and T/B margin totals, so we just need to split them in half (half for the left, half for the right, etc.)

	remainderX = remainderX * 0.5
	remainderY = remainderY * 0.5

-- Finally:  Don't forget that we usually need to multiply our objects' widths and heights by 0.5 in order to find their centers:  That is their "anchor point," and that is always the most important position to us.  In other words, the most important idea here is that in order to align your 20-pixel wide room to the far left of the screen, you must set its X-position at 10.  If your room is 36 pixels high, then you would set its Y-position at 18.  Etc.

-- With all that in mind, let's set our window mid-points with another variable (we don't really need to do this, but it makes things look neater when the code becomes more dense).

	local windowCenterX = bldgWindowWidth * 0.5
	local windowCenterY = bldgWindowHeight * 0.5 

-- So:  Let's test it out, using nested for-loops to do the heavy lifting.  Remember:  We're working from the left edge, but we need to place things on their center anchor points -- so there's a tiny translation we need to make: 

-- our window's x position = margin + (window number * window width) - roomCenterX

-- That "minus roomCenterX" isn't pretty, but it moves us back over to the left just far enough to find the room's middle.  Let's squeeze things together in order to keep things simple:

	local windowAnchorX = remainderX - roomCenterX
	local windowAnchorY = remainderY - roomCenterY

-- If that's not clear, I'll add some code in a second post that will allow you to experiment with those values for yourself.

-- Last minute add-in:  Window color as a table (of R,G,B values)
	local windowLightsOn = { 1, .8, .2 }

	for column = 1, bldgRoomCount do
		for row = 1, bldgFloorCount do
			local xPos = windowAnchorX + (column * bldgRoomWidth)
			local yPos = windowAnchorY + (row * bldgFloorHeight)
			local window = display.newRect (xPos, yPos, bldgWindowWidth, bldgWindowHeight)
			window.fill = windowLightsOn
		end
	end

-- That's it, we're out of here.  End the function and return control to the main program loop.

end


-- For the purposes of this tutorial, let's just call it with a simple test.  For a building that is 300 units wide and 750 units tall...

-- We'll draw a building shell, and then draw our windows.

-- don't forget: x, y = 300/2, 750/2 because anchors are in the center!

local bldgShell = display.newRect( 150, 375, 300, 750 )
bldgShell.fill = { .3, .3, .36 }

-- Don't forget how we began:  ( bW, bRC, bH, bFC )
-- (note that the arguments for my installWindows() function do NOT line up with those of the newRect() function.  Your comments will be important here, in order to remind yourself of the order in which the arguments are presented.

installWindows( 300, 6, 750, 13 ) -- I can provide fill info directly, too


-- Now:  We're stuck.  We can't move this building, nor can we move the windows, nor can we adjust the lighting from any of the rooms.  This just got things onto the screen.  Happily, this was the vast bulk of the work, and moving the building, etc., won't take much more effort.