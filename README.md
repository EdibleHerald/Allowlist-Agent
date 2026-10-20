# Allow-Agent

Allow-Agent is a simple application that works on a deny-default firewall by dynamically updating
the firewall's allow list based on users authenticated through an Identity Service Provider (IdP). 
This solution aims to reduce the attack surface of a given network environment by only ever 
allowing authenticated users to connect to the network. 

Currently, the only supported IdP and firewall is:
- KeyCloak (IdP)
- OPNsense (Firewall)