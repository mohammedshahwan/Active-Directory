# Troubleshooting Updates Will be Posted Here:

## 10/30/2024

It's been a while since I got onto my AD home lab.
I needed an isolated environment to run some programs and test "malware" mitigation techniques, so I decided to use the virtual setup of my AD home lab.

### CLIENT1 Machine wasn't connected to the internet?
<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Troubleshooting1/Trb1.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Troubleshooting1/Trb2.png">
</div>

When I logged into the domain controller account, everything appeared fine on the surface. I didn't want to go through setting up another domain controller machine if anything happened,
so I decided to use the client machine since it would be easily replaceable.

To my surprise, the client machine was not connected to the internet. On the client side, the IP address is auto-assigned by the DHCP server on the domain controller, so I didn't look into it too much as a possible cause.

I first tried performing a network reset to see if a simple fix could solve the issue, however, that was not the case.

<br />

I then checked if the client machine was able to find the domain controller on the network:

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Troubleshooting1/Trb3.png">
</div>

When I pinged the domain controller's IP address, the ping was successful, however, when I tried to ping the host domain itself, the client machine was unable to find it.

<br />

With this being the case, I figured the problem was on the domain controller end.

<br />

### Domain Controller did what...?

When I switched back to the domain controller I checked if the client machine was still registered with the Active Directory Users and Computers.

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Troubleshooting1/Trb4.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Troubleshooting1/Trb5.png">
</div>

<br />

This part was unexpected, but I went back to the client machine to check the firewall rules.

Here, I encountered a problem. To access the Windows Defender Firewall with Advanced Security, I needed admin-level access. I was logged in as a normal user, but when I attempted logging in with the domain admin credentials on the client machine, I was denied access because the client machine was unable to connect to the domain to verify the credentials.

...quite the paradoxical problem...

I then logged in as the localhost administrator (that I definitely didn't forget about) and was able to configure the proper inbound firewall rules as suggested by the pop-up on the domain controller.

This... still didn't solve the problem. However, I was able to rule out the firewall from being the cause of the issue.

<br />

I then switched back to the domain controller and decided to check the internal/external network adapter connections.

Their names were reverted back to Ethernet and Ethernet2, which I found suspicious. The external (internet-facing) network adapter seemed normal, other than the name, however, I found a problem on the internal (private network/domain hosting) network adapter.

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Troubleshooting1/Trb6.png">
</div>

<br />

The IP addressing configuration I had previously set up was reverted to default?

I reconfigured the IPv4 address/mask and DNS server address back to the original setup I had configured.

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Troubleshooting1/Trb7.png">
</div>

<br />

I also took a look at the Remote Access Server (RAS) configurations to make sure if anything had changed on that end.

It seemed that was also changed to a Remote Access configuration, so I disabled it and reconfigured it to the proper NAT setup.

For safe measure, I also reconfigured the DHCP server, then went back to the client machine.

<br />

### Connection Issue: Solved

When I logged back into the client machine, it began initializing as if it was the first time I was signing into the machine under the credentials I usually used (good sign?).

The machine showed that it was connected to the internet, which meant the troubleshooting was a success.

For good measure, I pinged the domain host again and an external website, verifying that the proper connection configurations were re-established.

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Troubleshooting1/Trb8.png">
</div>






