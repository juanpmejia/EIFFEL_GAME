note
	description : "Mouse-text application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

create
	make

feature {NONE} -- Initialization

	client: OUR_CLIENT

	make
		local
			controller:GAME_LIB_CONTROLLER

		do
			create controller.make
			controller.enable_video -- Enable the video functionalities
			run_game(controller)  -- Run the core creator of the game.
			controller.quit_library  -- Clear the library before quitting
		end

	run_game(controller:GAME_LIB_CONTROLLER)
		local
			bk,desert:GAME_SURFACE
			maryo_anim:LIST[GAME_SURFACE]
			sky_color:GAME_COLOR
			random_gen:GAME_RANDOM_CONTROLLER
		do
			controller.event_controller.on_quit_signal.extend (agent on_quit(controller))  -- When the X of the window is pressed, execute the on_quit method.
			controller.event_controller.on_key_down.extend(agent on_key_down)
			controller.event_controller.on_key_up.extend(agent on_key_up)




			desert:=create {GAME_SURFACE_IMG_FILE}.make_with_alpha ("Sprites\background.jpg")  -- Create the desert surface
			create bk.make_with_bit_per_pixel(desert.width,desert.height,16,true)  -- Create the background surface
			create sky_color.make_rgb (69, 161, 246)	-- Set blue for the background sky.
			bk.fill_rect (sky_color, 0, 0, bk.width, bk.height)	-- Draw the blue background sky.
			bk.draw_surface (desert, 0, 0)	-- Show the desert surface on the blue background.

			maryo_anim:=gen_maryo_anim		-- Generate the animations images

			controller.create_screen_surface (bk.width, bk.height, 16, true, true, false, true, false)	-- Create the window. Dimension: same as bk image, 16 bits per pixel, Use video memory, use hardware double buffer,


			go_left:=false
			go_right:=false
			anim_index:=1
			create random_gen.make		-- Creation of a random generator (you can also use the GAME_LIB_CONTROLLER that is a GAME_RANDOM object too)
			random_gen.generate_new_random		-- Generate a number
			maryo_x:=(bk.width//2)-maryo_anim.at (1).width//2---random_gen.last_random_integer_between (0, controller.screen_surface.width)	-- Get the last generate number. The result must be between 0 and the width of the screen
			maryo_y:=bk.height-maryo_anim.at (1).height
			main_loop(controller,bk,maryo_anim)
		end

	gen_maryo_anim:LIST[GAME_SURFACE]
		local
			shipSprite:GAME_SURFACE_IMG_FILE
		do
			Result:=create{ARRAYED_LIST[GAME_SURFACE]}.make(1) -- We need 4 images to animate the Maryo (the 2nd and the 4th are the same)
			create shipSprite.make_with_alpha ("Sprites\j1-sprite.png")		-- In this image, there are 3 images
--			Result.extend (maryo.sub_surface (maryo.width//3, 0, maryo.width//3, maryo.height))			-- Make a surface with the second image
--			Result.extend (maryo.sub_surface (0, 0, maryo.width//3, maryo.height))						-- Make a surface with the first image
--			Result.extend (maryo.sub_surface ((maryo.width//3)*2, 0, maryo.width//3, maryo.height))		-- Make a surface with the third image
--			Result.extend (maryo.sub_surface (0, 0, maryo.width//3, maryo.height))						-- Make a surface with the first image
--			Result.extend (Result.at(1).surface_mirrored (true, false))	-- Make the surface for when the Maryo go to the left
--			Result.extend (Result.at(2).surface_mirrored (true, false))	-- The mirror and rotate routine of a GAME_SURFACE is very expensive in
--			Result.extend (Result.at(3).surface_mirrored (true, false))	-- memor an in CPU. Don't do it in a game loop.
--			Result.extend (Result.at(6))
			Result.extend (shipSprite)
						-- Note that this method does not duplicate the surface in memory
		end

feature {NONE} -- Routines

	main_loop(controller:GAME_LIB_CONTROLLER;bk:GAME_SURFACE;maryo_anim:LIST[GAME_SURFACE])
			-- This routine is not a loop, but it will be launch at each pass of the application main loop
		local
			message : OUR_MESSAGE
		do
			from
				create message.make
				create client.make_client (message)
				must_quit:=false
			until
				must_quit
			loop
				create message.make
				--create client.make_client (message)
				--io.put_string ("LO CREE!")
				controller.screen_surface.draw_surface (bk, 0, 0)	-- Print the background on the screen surface
				message.extend (maryo_x.out)
				if go_left then
					message.extend ("LEFT")
					client.send (message)
					maryo_x := client.receive.at (1).to_integer
					--client.soc1.cleanup
					client.restart
					--io.put_string ("PUDE RECIBIR!")
					--anim_index:=(anim_index+1)\\20		-- The same image must be print for 5 calls of main_loop. There is 4 images in the animation.
														-- o at index 20, we go back to the first (index 0)
					--controller.screen_surface.draw_surface (maryo_anim.at ((anim_index//5)+5), maryo_x, maryo_y)	-- Show the animation images 5 to 8
				elseif go_right then
--					maryo_x:=maryo_x+1	-- Move the Maryo to the left
					message.extend ("RIGHT")
					client.send (message)
					maryo_x := client.receive.at (1).to_integer
					client.restart
					--anim_index:=(anim_index+1)\\20		-- The same image must be print for 5 calls of main_loop. There is 4 images in the animation.
														-- o at index 20, we go back to the first (index 0)
					--controller.screen_surface.draw_surface (maryo_anim.at ((anim_index//5)+1), maryo_x, maryo_y) 	-- Shaw the animation images 1 to 4
				else
					--controller.screen_surface.draw_surface (maryo_anim.at (anim_index), maryo_x, maryo_y)		-- No move, show the static sprite
				end
				controller.screen_surface.draw_surface (maryo_anim.at (anim_index), maryo_x, maryo_y)		-- No move, show the static sprite
				controller.flip_screen		-- Show the screen in the window
				controller.update		-- This call is very important. It permit to the events to continue.
				controller.delay (1)		-- Donc forget the loop delay. Without it, your CPU will burn :)
			end

		end

	on_key_down(event:GAME_KEYBOARD_EVENT)
		do
			if event.is_left_key then
				go_left:=true
			elseif event.is_right_key then
				go_right:=true
			end
		end

	on_key_up(event:GAME_KEYBOARD_EVENT)
		do
			if event.is_left_key then
				go_left:=false
				--anim_index:=5
			elseif event.is_right_key then
				go_right:=false
				--anim_index:=1
			end
		end

	on_quit(controller:GAME_LIB_CONTROLLER)
			-- This method is called when the quit signal is send to the application (ex: window X button pressed).
		do
			must_quit:=true
		end

feature {NONE} -- Variables

	go_left:BOOLEAN
	go_right:BOOLEAN
	anim_index:INTEGER
	maryo_x,maryo_y:INTEGER
	must_quit:BOOLEAN

end
