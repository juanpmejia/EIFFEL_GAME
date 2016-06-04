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

	SOCKET_RESOURCES

	SED_STORABLE_FACILITIES



create

	make_client

feature

	our_list: OUR_MESSAGE

	received: detachable OUR_MESSAGE -- Type redefinition

	soc1: detachable NETWORK_STREAM_SOCKET

	l_host: STRING

	l_port: INTEGER

	make_client (argv: OUR_MESSAGE)
			-- Build list, send it, receive modified list, and print it.

		do
			if argv.count /= 3 then
--				io.error.put_string ("Usage: ")
--				io.error.put_string (argv.at (1))
--				io.error.put_string (" hostname portnumber%N")
--				io.error.put_string ("Defaulting to host `localhost' and port `2000'.%N")
				l_port := 2000
				l_host := "localhost"--"192.168.250.251"
			else
				l_port := argv.at (2).to_integer
				l_host := argv.at (1)
			end
			l_port := 55555
			l_host := "localhost"--"192.168.250.29"--"localhost"
			create soc1.make_client_by_port (l_port, l_host)
			--ssoc1.connect
			--io.put_string ("Conecte%N")
		rescue
			if soc1 /= Void then
				soc1.cleanup
			end
		end

	send(toSend : OUR_MESSAGE)
		local
			l_medium: SED_MEDIUM_READER_WRITER
		do
			create l_medium.make (soc1)
			l_medium.set_for_writing
			--io.put_string ("Tratando de enviar%N")
			independent_store (toSend, l_medium, True)
			--io.put_string ("Envie! Cliente%N")
			--l_medium.set_for_reading

		end

	receive : OUR_MESSAGE
			-- Build a message to server, receive answer, build
			-- modified message from that answer, and print it.
		local
			l_medium: SED_MEDIUM_READER_WRITER
		do
			create l_medium.make (soc1)
			l_medium.set_for_reading
			if attached {OUR_MESSAGE} retrieved (l_medium, True) as our_new_list then
				--io.put_string ("Recibi Cliente%N")
				Result:=our_new_list
			else
				io.put_string ("me jodi Cliente%N")
			end
		end

	restart
		do
			soc1.cleanup
			create soc1.make_client_by_port (l_port, l_host)
		end

--	connect
--		do
--			soc1.connect
--		rescue
--			io.put_string ("Connection failed%N Retrying%N")
--			retry
--		end



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

