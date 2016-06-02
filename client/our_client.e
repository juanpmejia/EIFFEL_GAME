note

	description:
		"Client root-class for the predef example."
	legal: "See notice at end of class.";

	status: "See notice at end of class.";
	date: "$Date: 2013-02-04 13:27:38 -0800 (Mon, 04 Feb 2013) $";
	revision: "$Revision: 91160 $"
	EIS: "name=Unnamed", "protocol=URI", "src=http://www.yourwebsite.com"

class OUR_CLIENT

inherit

	NETWORK_CLIENT
		redefine
			received
		end

create

	make_client

feature

	our_list: OUR_MESSAGE

	received: detachable OUR_MESSAGE -- Type redefinition

	make_client (argv: OUR_MESSAGE)
			-- Build list, send it, receive modified list, and print it.
		local
			l_host: STRING
			l_port: INTEGER
			l_in_out: detachable like in_out
		do
			if argv.count /= 3 then
--				io.error.put_string ("Usage: ")
--				io.error.put_string (argv.at (1))
--				io.error.put_string (" hostname portnumber%N")
--				io.error.put_string ("Defaulting to host `localhost' and port `2000'.%N")
				l_port := 2000
				l_host := "localhost"
			else
				l_port := argv.at (2).to_integer
				l_host := argv.at (1)
			end
			make (l_port, l_host)
			l_in_out := in_out
			build_list(argv.at (1).to_integer,argv.at (2))
			send (our_list)
			receive
			process_received
			cleanup
		rescue
			if l_in_out /= Void and then not l_in_out.is_closed then
				l_in_out.close
			end
		end

	build_list( posX:INTEGER ; dir:STRING)
			-- Build list of strings `our_list' for transmission to server.
		do
			create our_list.make
			our_list.extend (posX.out)
			our_list.extend (dir)
--			from
--				our_list.start
--				io.put_string ("Esto envio:%N")
--			until
--				our_list.after
--			loop
--				io.put_string (our_list.item)
--				io.new_line
--				our_list.forth
--			end
		end

	process_received
			-- Print the contents of received in sequence.
		do
			if attached {OUR_MESSAGE} received as l_received then
--				from
--					l_received.start
--				until
--					l_received.after
--				loop
--					io.put_string ("Esto recibi:%N")
--					io.put_string (l_received.item)
--					l_received.forth
--				end
			else
				io.put_string ("No list received.")
			end
			io.new_line
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

