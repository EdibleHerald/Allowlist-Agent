// Goal: Write a program that can create a valid websocket and test it!
use socket::*;

// IPV4 socket: AF_INET
// For this example, UDP: SOCK_DGRAM 
// Why I chose UDP over TCP: 
// - Easier, TCP local socket addresses that have been bound are unavailable for a short period after closing)
// - Connection-oriented sockets are allowed to use ONLY unicast addresses.
// e.g. socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP), "IPPROTO_UDP" as in "IP Protocol UDP"

// The third argument can also be "0", whose meaning changes based on context.
// Better to be explicit and use "IPPROTO_UDP" in the above example.

// bind(2) is used to bind a socket to a local interface address.
// listen(2) is used on unbound sockets to automatically bound
// to a random free port, address set to "INADDR_ANY".
// connect(2) has similar behavior as listen(2) but also allows
// to be automatically bound to a usable shared port.

// An IP socket address is defined as a combo of an IP interface address
// and a 16-bit port number.
// Port numbers <1024 are "privileged ports", requires a privileged process to bind to these sockets.
// NOTE: raw IPv4 protocol has NO CONCEPT of port numbers. Port numbers are implemented the TCP/UDP protocols.

// Special/reserved addresses:
// IPADDR_LOOPBACK (127.0.0.1) # Refers to localhost.
// INADDR_ANY (0.0.0.0) # Use any address.
// INADDR_BROADCAST (255.255.255.255) # Broadcast to all hosts on local network segement (if the link is capable, and if SO_BROADCAST is set).
// Few more are defined at ip(8) that aren't necessary to know about.

/// Hello!
/// 
/// 
fn main() {

}