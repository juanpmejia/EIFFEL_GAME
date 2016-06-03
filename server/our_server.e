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

	make_server(argv: ARRAY [STRING])
		local
				l_port: INTEGER
				count : INTEGER
			do
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
				create soc1.make_server_by_port (l_port)
				from
					soc1.listen (5)

					count := 0
				until
					false
				loop

					soc1.accept
					io.put_string ("Acepte socket Server%N")
					process_message  -- See below
					io.put_string ("Se proceso%N")

				end
				soc1.cleanup
				io.put_string ("sali")
		rescue
			if soc1 /= Void then
				soc1.cleanup
			end
		end

	process_message
			-- Print the contents of received in sequence.
		local
			l_medium : SED_MEDIUM_READER_WRITER
			posX:INTEGER
		do
			io.put_string ("Intentando procesar%N")
			create our_list.make
			if attached {NETWORK_STREAM_SOCKET} soc1.accepted as soc2 then
				create l_medium.make (soc2)
				l_medium.set_for_reading
				io.put_string ("Recibi socket Server%N")
				if attached {OUR_MESSAGE} retrieved(l_medium,true) as l_received then
					io.put_string ("Recibi Server%N")
					posX := l_received.at(1).to_integer
					if(l_received.at (2).is_equal ("LEFT")) then
	--					io.put_string ("Detecte izquierda")
						posX := posX - velx
						our_list.extend(posX.out)
						--io.put_string (posX.out)
					elseif(l_received.at (2).is_equal ("RIGHT")) then
						posX := posX + velx
						our_list.extend(posX.out)
						--io.put_string (posX.out)
					else
						io.put_string ("FUCK%N")
						io.put_string (l_received.at (2))
						io.new_line
						from
							l_received.start
							io.put_string ("Esto es lo que esta:%N")
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
					l_medium.set_for_writing
					independent_store(our_list, l_medium, true)
					io.put_string ("Envie! Server%N")
					--l_medium.set_for_reading
				else
					io.put_string ("No list received.")
				end
				--io.new_line
				soc2.close
			else
				io.put_string ("No pude recibir%N")
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

