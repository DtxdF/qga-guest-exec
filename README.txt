NAME
     qga-guest-exec - execute commands in a guest via the guest agent protocol

SYNOPSIS
     qga-guest-exec [-q] [-w wait] socket program [args ...]
     qga-guest-exec [-q] -a socket program [args ...]
     qga-guest-exec [-w wait] -p pid socket
     qga-guest-exec -v

DESCRIPTION
     The qga-guest-exec utility connects to the guest agent socket at socket
     and asks the agent to execute program inside the guest.

     The guest agent is the software running inside the virtual machine that
     implements the QEMU Guest Agent Protocol.	The protocol is defined by
     QEMU, but the agent itself is independent of the virtual machine monitor:
     the same "guest-exec" and "guest-exec-status" commands are available
     whenever the protocol is spoken.  The virtual machine monitor only
     provides the transport, by exposing a virtio-serial or virtio-console
     port as a Unix domain socket on the host.	Both bhyve(8) and QEMU/KVM can
     do this, and so can any other VMM that forwards the port.

     The agent returns a process identifier immediately; the "guest-exec"
     operation is asynchronous by design.  qga-guest-exec then polls the
     "guest-exec-status" command until the process exits or the timeout is
     reached.  If output capture is enabled (the default), the standard output
     and standard error produced by the guest process are decoded from base64
     and written to the corresponding streams of qga-guest-exec.

     The socket argument is mandatory and must be a path to a Unix domain
     socket created by the virtual machine monitor for the virtio-console port
     that carries the guest agent.  qga-guest-exec verifies that the path
     exists and is a socket before contacting the agent.

     Before each command, qga-guest-exec issues a "guest-sync-delimited"
     request with a random identifier and verifies the response.  This
     protects against stale or interleaved replies on the socket.

     The options are as follows:

     -a      Launch program in the guest and print the guest process
	     identifier on standard output.  Exit immediately after the
	     identifier is printed.  This option cannot be combined with -p.

     -q      Disable output capture in the guest.  The agent will not collect
	     standard output or standard error, and qga-guest-exec will
	     produce no guest output.  When used together with -a, this
	     determines whether a later -p invocation can retrieve output for
	     the process.  When used together with -p, this option has no
	     effect, because capture was decided when the process was
	     originally launched.

     -p pid  Resume polling an existing guest process previously launched with
	     -a.  No new command is started, and program must not be given.
	     The value pid must be a positive decimal integer.	This option
	     cannot be combined with -a.

     -w wait
	     Set the maximum number of seconds to wait for the guest process
	     to exit.  The default is 30 seconds.  A value of 0 disables the
	     deadline, causing qga-guest-exec to wait indefinitely.  The
	     maximum accepted value is 86400 (one day).  This option has no
	     effect when used together with -a, because qga-guest-exec returns
	     before entering the polling loop.

EXIT STATUS
     0	     The guest process exited with status 0, or -a was used and the
	     identifier was printed successfully.

     1	     Usage error, invalid option argument, an internal failure (such
	     as a malformed response that jq(1) could not parse), or socket
	     does not exist or is not a Unix domain socket.

     2	     No sync delimiter was received from the guest agent.  This
	     usually indicates that the socket is not connected to a live
	     agent.

     3	     The guest agent response did not consist of the expected two
	     lines.

     4	     The guest agent returned an error.  The error description is
	     printed on standard error.

     5	     The "guest-sync" identifier in the response did not match the
	     identifier that was sent.

     6	     The timeout specified with -w expired before the guest process
	     exited.

     127     The guest process exited with a non-zero status.  The exact
	     status is not propagated.

     128     The guest process was terminated by a signal, or the exit status
	     could not be determined.

SEE ALSO
     jq(1), nc(1), bhyve(8), qemu-ga-ref(7)

AUTHORS
     Jesus Daniel Colmenares Oviedo <DtxdF@disroot.org>

CAVEATS
     The "merged" value for the capture-output argument of "guest-exec" is not
     supported by Windows guests.  Consequently, qga-guest-exec always
     requests separate stdout and stderr capture and writes each stream to the
     corresponding local stream.  The relative ordering of lines from the two
     streams is therefore not preserved.

     The socket used by the guest agent may remain open even when no agent is
     listening.  qga-guest-exec relies on a short connection timeout for each
     request and on the "guest-sync-delimited" handshake to detect a dead or
     unresponsive agent.

     The exit status of the guest process is collapsed to 127 for any non-zero
     value.  Scripts that need the exact status should query
     "guest-exec-status" directly.

BUGS
     With -w 0 there is no upper bound on the number of status polls.  If the
     agent returns a response without the exited field, or with exited set to
     null, qga-guest-exec will loop indefinitely.  Use a non-zero timeout to
     avoid this situation.
