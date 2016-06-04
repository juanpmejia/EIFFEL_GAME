note

	description:
		"Server root-class for the same_mach example."
	legal: "See notice at end of class.";

	status: "See notice at end of class.";
	date: "$Date: 2013-02-04 13:27:38 -0800 (Mon, 04 Feb 2013) $";
	revision: "$Revision: 91160 $"

class OUR_SERVER

inherit

	SOCKET_RESOURCES

	SED_STORABLE_FACILITIES

create

	make_server

feature

	received: detachable OUR_MESSAGE --Type redefinition

	our_list : OUR_MESSAGE

	soc1: NETWORK_STREAM_SOCKET

	velx : INTEGER

	velxAlien : INTEGER

	playerCount : INTEGER

	alienCount : INTEGER

	screenW:INTEGER

	screenH:INTEGER

	alienW:INTEGER

	alienH:INTEGER

	players_x : LINKED_LIST[INTEGER]

	aliens_x : LINKED_LIST[INTEGER]

	aliens_y : LINKED_LIST[INTEGER]

	alienDir:INTEGER

	connectionFailed : BOOLEAN

	gameStarted : BOOLEAN

	client : OUR_CLIENT

	principal : BOOLEAN

	s_address : STRING

	s_status : BOOLEAN

	make_server(argv: ARRAY [STRING])

		local
				l_port: INTEGER
				count : INTEGER
				message : OUR_MESSAGE
				mreceived : OUR_MESSAGE
			do
				if not connectionFailed then --First time we try to connect we need to initialize
					if argv.count /= 2 then
						io.error.put_string ("Usage: ")
						io.error.put_string (argv.item (0))
						io.error.put_string (" hostname portnumber%N")
						io.error.put_string ("Defaulting to host `localhost' and port `2000'.%N")
						l_port := 2000
					else
						l_port := argv.item (1).to_integer
					end
					velx := 10
					velxAlien := 15
					playerCount := 1
					alienCount := 4
					alienDir := 1
					principal := true
					create players_x.make
					create aliens_x.make
					create aliens_y.make
					from
						count :=0
					until
						count = alienCount
					loop
						aliens_x.extend (-1)
						aliens_y.extend (-1)
						count := count + 1
					end
					from
						count := 1
					until
						count = 5
					loop
						players_x.extend (-1)
						count := count + 1
					end
				end

				if principal then
					create soc1.make_server_by_port (l_port)
					from
						soc1.listen (5)
					until
						false
					loop
						soc1.accept
						--io.put_string ("Acepte socket Server%N")
						process_message  -- See below
						--io.put_string ("Se proceso%N")

					end
					soc1.cleanup
					io.put_string ("sali")
				else


					from
						s_address := ("192.168.250.35")
						create message.make
						message.extend (s_address)
						message.extend (l_port.out)
						create client.make_client (message)
					until
						false
					loop

						client.soc1.connect
						create message.make
						message.extend ("RESP")
						client.send(message)
						mreceived := client.receive
						client.soc1.cleanup
						from
							count := 1
						until
							count = mreceived.count + 1
						loop
							if count <= 4 then
								players_x.put_i_th (mreceived.at (count).to_integer, count)

							elseif count = 5 then

								alienCount := mreceived.at (count).to_integer

							elseif count >= 6 and count - 5 < alienCount then

								aliens_x.put_i_th (mreceived.at (count).to_integer, count-5)

							elseif count - 5 = alienCount then

								alienDir := mreceived.at (count).to_integer
							end
							count := count + 1

						end

					end

				end

		rescue
			if soc1 /= Void then
				if principal then
					soc1.cleanup
					connectionFailed:=true
					io.put_string ("Connection failed. Waiting for players")
					retry
				else
					principal := true
					io.put_string ("Iniciando servidor principal")
				end
				soc1.cleanup
				connectionFailed:=true
				io.put_string ("Connection failed. Waiting for players")
				retry
			end
		end

	process_message
			-- Print the contents of received in sequence.
		local
			l_medium : SED_MEDIUM_READER_WRITER
			player:INTEGER
			posX:INTEGER
			count:INTEGER
			count2: INTEGER
			oldPlayer: BOOLEAN
		do
			--io.put_string ("Intentando procesar%N")
			create our_list.make
			if attached {NETWORK_STREAM_SOCKET} soc1.accepted as soc2 then
				create l_medium.make (soc2)
				l_medium.set_for_reading
				--io.put_string ("Recibi socket Server%N")
				if attached {OUR_MESSAGE} retrieved(l_medium,true) as l_received then
					--io.put_string ("Recibi Server%N")
					if(l_received.at (1).is_equal ("LEFT")) then
						posX := l_received.at(2).to_integer
						posX := posX - velx
						player := l_received.at(3).to_integer
						players_x.put_i_th (posX, player)

					elseif(l_received.at (1).is_equal ("RIGHT")) then
						posX := l_received.at(2).to_integer
						posX := posX + velx
						player := l_received.at(3).to_integer
						players_x.put_i_th (posX, player)

					elseif(l_received.at (1).is_equal ("UPDATE")) then
						posX := l_received.at(2).to_integer
						player := l_received.at(3).to_integer
						players_x.put_i_th (posX, player)
					elseif(l_received.at (1).is_equal ("INI")) then
						screenW := l_received.at(2).to_integer
						screenH := l_received.at(3).to_integer
						alienW := l_received.at(4).to_integer
						alienH := l_received.at(5).to_integer
						oldPlayer :=  l_received.at(6).to_boolean
						from
							l_received.start
						until
							l_received.after
						loop
							io.put_string (l_received.item+"%N")
							l_received.forth
						end
						io.put_string (l_received.at (6)+" Es oldplayer?%N")
						io.put_string ("Jugador: "+playerCount.out+"%N")
						if not gameStarted then
							from
								count := 1
							until
								count = alienCount + 1
							loop
								if count = 1 then
									aliens_x.put_i_th (screenW, count)
									aliens_y.put_i_th (screenH//2, count)
								else
									aliens_x.put_i_th (aliens_x.at (count-1)+5+alienW, count)
									aliens_y.put_i_th (screenH//2, count)
								end
								count := count + 1

							end
						end
						if not oldPlayer then
							our_list.extend(playerCount.out)
							playerCount := playerCount +1
						end
					else
						io.put_string ("FUCK%N")
						io.put_string (l_received.at (1))
						io.new_line
						from
							l_received.start
							--io.put_string ("Esto es lo que esta:%N")
						until
							l_received.after
						loop
							io.put_string (l_received.item)
							io.new_line
							l_received.forth
						end
						posX := posX - 1
						our_list.extend(posX.out)
					end

					from 	--Update the aliens positions
						count := 1
					until
						count = alienCount + 1
					loop
						if alienDir=1 then -- Moving to the left
							if aliens_x.at (alienCount) <= 0-alienW then
								--io.put_string ("Voy ahora a la derecha y "+aliens_x.at (1).out)
								alienDir:=2
							else
								from
									count2 := 1
								until
									count2 = alienCount + 1
								loop
									aliens_x.put_i_th (aliens_x.at (count2)-velxAlien, count2)
									count2 := count2 + 1
								end

							end
						elseif alienDir=2 then -- Moving to the right
							if aliens_x.at (1) >= screenW then
								--io.put_string ("Voy ahora a la izquierda y "+aliens_x.at (1).out)
								alienDir:=1
							else
								from
									count2 := 1
								until
									count2 = alienCount + 1
								loop
									aliens_x.put_i_th (aliens_x.at (count2)+velxAlien, count2)
									count2 := count2 + 1
								end
							end
						end
						count := count + 1
					end

					from -- Pack the players positions
						count := 1
					until
						count = 5
					loop
						our_list.extend (players_x.at (count).out)
						count := count + 1
					end
					our_list.extend (alienCount.out)
					from
						count := 1
					until
						count = alienCount+1
					loop
						our_list.extend (aliens_x.at (count).out)
						count := count + 1
					end
					l_medium.set_for_writing
					independent_store(our_list, l_medium, true)
					--io.put_string ("Envie! Server%N")
				else
					--io.put_string ("No list received.")
				end
				soc2.close
			else
				--io.put_string ("No pude recibir%N")
			end
		end
note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"
end

