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
			connectionFailed := false
			run_game(controller)  -- Run the core creator of the game.
			controller.quit_library  -- Clear the library before quitting
		end

	run_game(controller:GAME_LIB_CONTROLLER)
		local
			bk,sky:GAME_SURFACE
			sprites:LIST[GAME_SURFACE]
			random_gen:GAME_RANDOM_CONTROLLER
			playerNum:INTEGER
			message:OUR_MESSAGE

		do
			if not connectionFailed then --No need to re initialize variables
				--Associate keyboard events
				controller.event_controller.on_quit_signal.extend (agent on_quit(controller))  -- When the X of the window is pressed, execute the on_quit method.
				controller.event_controller.on_key_down.extend(agent on_key_down)
				controller.event_controller.on_key_up.extend(agent on_key_up)

				--Load resources
				sky:=create {GAME_SURFACE_IMG_FILE}.make_with_alpha ("Sprites\background.jpg")  -- Create the sky surface
				create bk.make_with_bit_per_pixel(sky.width,sky.height,16,true)  -- Create the background surface
				bk.draw_surface (sky, 0, 0)	-- Show the desert surface on the blue background.
				sprites:=gen_sprites		-- Generate the animations images
				controller.create_screen_surface (bk.width, bk.height, 16, true, true, false, true, false)	-- Create the window. Dimension: same as bk image, 16 bits per pixel, Use video memory, use hardware double buffer,

				--Initialize control variables
				go_left:=false
				go_right:=false
				create random_gen.make		-- Creation of a random generator (you can also use the GAME_LIB_CONTROLLER that is a GAME_RANDOM object too)
				random_gen.generate_new_random		-- Generate a number

				--Initialize player positions
				players_x:=create {ARRAYED_LIST[INTEGER]}.make(4)
				players_y:=create {ARRAYED_LIST[INTEGER]}.make(4)
				players_x.extend ((bk.width//2)-sprites.at (1).width//2) --Initial x position of the first player
				players_x.extend ((bk.width//2)-sprites.at (2).width//2)	--Initial x position of the second player
				players_x.extend ((bk.width//2)-sprites.at (3).width//2) --Initial x position of the third player
				players_x.extend ((bk.width//2)-sprites.at (4).width//2) --Initial x position of the fourth player

				players_y.extend (bk.height-sprites.at (1).height) --Initial y position of the first player
				players_y.extend (0) --Initial y position of the second player
				players_y.extend (bk.height-sprites.at (3).height) --Initial y position of the third player
				players_y.extend (0) --Initial y position of the fourth player

				--Create client and initialize message
				create client.make_client (create{OUR_MESSAGE}.make)
				create message.make
				message.extend ("INI")
				message.extend (bk.width.out)
				message.extend (bk.height.out)
				message.extend (sprites.at (5).width.out)
				message.extend (sprites.at (5).height.out)
			end
			client.soc1.connect

			if not gameStarted then --Get player number
				message.extend ("False")
				client.send (message)
				playerNum := client.receive.at (1).to_integer
			else
				message.put_i_th ("True", 6)
				client.send (message)
			end
			client.soc1.cleanup
			main_loop(controller,bk,sprites,playerNum)
		rescue
			connectionFailed := true
			create client.make_client (create{OUR_MESSAGE}.make)
			io.put_string ("La conexion fallo. Reintentando...%N")
			retry
		end

	gen_sprites:LIST[GAME_SURFACE]
		local
			shipSprite:GAME_SURFACE_IMG_FILE
		do
			Result:=create{ARRAYED_LIST[GAME_SURFACE]}.make(4)
			create shipSprite.make_with_alpha ("Sprites\j1-sprite.png")
			Result.extend (shipSprite)
			create shipSprite.make_with_alpha ("Sprites\j2-sprite.png")
			Result.extend (shipSprite)
			create shipSprite.make_with_alpha ("Sprites\j3-sprite.png")
			Result.extend (shipSprite)
			create shipSprite.make_with_alpha ("Sprites\j4-sprite.png")
			Result.extend (shipSprite)
			create shipSprite.make_with_alpha ("Sprites\invader-sprite.png")
			Result.extend (shipSprite)
		end

feature {NONE} -- Routines

	main_loop(controller:GAME_LIB_CONTROLLER;bk:GAME_SURFACE;sprites:LIST[GAME_SURFACE];playerNum:INTEGER)
			-- This routine is not a loop, but it will be launch at each pass of the application main loop
		local
			message : OUR_MESSAGE
			received : OUR_MESSAGE
			count : INTEGER
			alienNum:INTEGER
		do
			gameStarted:=true
			from
				create message.make
				create client.make_client (message)
				must_quit:=false
			until
				must_quit
			loop
				create message.make
				controller.screen_surface.draw_surface (bk, 0, 0)	-- Print the background on the screen surface
				if go_left then
					message.extend ("LEFT") --Direction
					message.extend (players_x.at (playerNum).out) --Position
					message.extend (playerNum.out) --ID
				elseif go_right then
					message.extend ("RIGHT") --Direction
					message.extend (players_x.at (playerNum).out) --Position
					message.extend (playerNum.out) --ID
				else
					message.extend ("UPDATE")
					message.extend (players_x.at (playerNum).out) --Position
					message.extend (playerNum.out) --ID
				end
				from
					client.soc1.connect
					client.send (message)
					received := client.receive
					alienNum := received.at (5).to_integer
					create aliens_x.make
					create aliens_y.make
					count := 1
				until
					count = 5+alienNum+1 --Plus one so the alienNum is readed
				loop
					if count<=4 then --For every player
						players_x.put_i_th (received.at (count).to_integer, count)
						if  players_x.at (count) > 0 then --If the player is alive
							controller.screen_surface.draw_surface (sprites.at (count), players_x.at(count), players_y.at(count))
						end
					elseif count>=6 then
						aliens_x.extend (received.at (count).to_integer)
						--io.putstring ("MARCIANITOOOOO "+aliens_x.at(count-5).out)
						--io.new_line
						controller.screen_surface.draw_surface (sprites.at (5), aliens_x.at(count-5), bk.height//2)--aliens_y.at(count-5))
					end
					count := count + 1
				end
				client.restart
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
	players_x:LIST[INTEGER]
	players_y:LIST[INTEGER]
	aliens_x:LINKED_LIST[INTEGER]
	aliens_y:LINKED_LIST[INTEGER]
	must_quit:BOOLEAN
	connectionFailed:BOOLEAN
	gameStarted:BOOLEAN

end
