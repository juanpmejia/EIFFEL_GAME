note

	description:
		"Server root-class for the same_mach example."
	legal: "See notice at end of class.";

	status: "See notice at end of class.";
	date: "$Date: 2013-02-04 13:27:38 -0800 (Mon, 04 Feb 2013) $";
	revision: "$Revision: 91160 $"

class OUR_SERVER

inherit

	--SOCKET_RESOURCES

	--STORABLE
	NETWORK_SERVER
		redefine
			received
		end
create

	make_server

feature

	received: detachable OUR_MESSAGE --Type redefinition
--	make (argv: ARRAY [STRING])
--			-- Accept communication with client and exchange messages
--		local
--			soc1: detachable NETWORK_STREAM_SOCKET
--			count: INTEGER
--		do
--			if argv.count /= 2 then
--				io.error.putstring ("Usage: ")
--				io.error.putstring (argv.item (0))
--				io.error.putstring (" portnumber%N")
--			else
--				create soc1.make_server_by_port (argv.item (1).to_integer)
--				from
--					soc1.listen (5)
--					count := 0
--				until
--					count = 3
--				loop
--					process (soc1)-- See below
--					count := count + 1
--				end
--				soc1.cleanup
--			end
--		rescue
--			if soc1 /= Void then
--				soc1.cleanup
--			end
--		end

--	process (soc1: NETWORK_STREAM_SOCKET)
--			-- Receive a message, extend it, and send it back.
--		do
--			soc1.accept
--			if
--				attached {NETWORK_STREAM_SOCKET} soc1.accepted as soc2 and then
--				attached {OUR_MESSAGE} retrieved (soc2) as our_new_list
--			then
--				from
--					our_new_list.start
--				until
--					our_new_list.after
--				loop
--					io.putstring (our_new_list.item)
--					our_new_list.forth
--					io.new_line
--				end
--				our_new_list.extend ("%N I'm back.%N")
--				our_new_list.general_store (soc2)
--				soc2.close
--			end
--		end
	make_server(argv: ARRAY [STRING])
		local
				l_port: INTEGER
				l_in_out: detachable like in
				our_list: OUR_MESSAGE
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
				make (l_port)
				l_in_out := in
				receive
				process_message
				create our_list.make
				our_list.extend ("Mocos")
				resend (our_list)
				cleanup
			rescue
				if l_in_out /= Void and then not l_in_out.is_closed then
					l_in_out.close
				end
		end

	process_message
			-- Print the contents of received in sequence.
		do
			if attached {OUR_MESSAGE} received as l_received then
				from
					l_received.start
				until
					l_received.after
				loop
					io.put_string("Recibi: ")
					io.put_string (l_received.item)
					l_received.forth
				end
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

