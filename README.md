# On-Prem Active Directory Lab & Bulk User Creation with PowerShell

## Summary
<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD Diagram.png">
</div>

In this lab, we're going to use Oracle VirtualBox to run a Windows Server 2019 and a Windows 10 VM. Our Server 19 VM will be our Domain Controller (DC) which will house Active Directory. It will have 2 network adapters, for the Internet as well as our internal network (which, in this case, will be through VirtualBox).

After the DC (Server 19) VM is set up with its network adapters, we'll assign its IP addressing for the internal network.
We'll then install Active Directory Domain Services (AD DS) and create our domain.
Next, we're going to configure Remote Access/NAT and Routing to allow the clients on the private network to access the Internet through the DC.
After that, we'll set up a DHCP on the Domain Controller and create an IP range that will be used by the Windows 10 client to be assigned an IP address on the internal network.
We will then use PowerShell to create users in Active Directory using our Bulk User Creation script.

With the setup complete on our DC, we'll create the client Windows 10 VM and set it up with an internal network adapter to connect with the DC VM through the private VirtualBox network.
We'll join the client VM to the domain and use one of the created accounts to log in on the client VM, making sure the AD setup was successful.

## Technologies Used
  - Oracle VirtualBox
  - Microsoft Windows Server 2019
  - Microsoft Windows 10
  - Network Adapters / Network Interface Card (NIC)
  - Active Directory Domain Services (AD DS)
  - Remote Access Server (RAS) / Network Address Translation (NAT)
  - DHCP Server
  - IPv4
  - PowerShell

## Step-by-Step Process

### Oracle VirtualBox & Windows OS ISO Files
Oracle VirtualBox can be downloaded from https://www.virtualbox.org/wiki/Downloads. Just choose the package for the specific platform you are using and make sure to also download the Extension Pack after downloading VirtualBox.

The Windows Server 2019 ISO file can be downloaded at https://www.microsoft.com/en-us/evalcenter/download-windows-server-2019 and the Windows 10 ISO file can be downloaded at https://www.microsoft.com/en-us/software-download/windows10.

### Creating & Installing Our Domain Controller VM
<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD1.png">
</div>

- To get started, we'll open VirtualBox and create a new VM. To keep things simple, I'll name it "Domain Controller". Since we're starting with the Domain Controller, we'll select the Windows Server 2019 ISO file and continue with the setup. In this lab, the default settings of 2048 MB (2 GB) of memory & 1 CPU processor (as well as the other default configurations) will be used, but it can be increased as desired.

<br />
<br />

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD2.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD3.png">
</div>

- With the DC VM created, before running it, we'll go to the VM "Network" settings. The default first network adapter uses NAT, which will be the Internet-dedicated adapter for the DC. We will also add a second adapter for the internal network, which will connect to the client VM through VirtualBox.

<br />
<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD4.png">
</div>

- With the network configurations complete, we'll open the DC VM and go through the Windows Server 2019 installation.

- We'll be using one of the "Desktop Experience" OS options, the <b>Standard Evaluation (Desktop Experience)</b> OS was used in this lab. Then, we'll continue with the <b>Custom</b> installation since we're installing the OS from scratch.

- Lastly, we'll be asked to make a password for the default admin account, then the installation would be complete and we can log in with the password we just created.

<br />
<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD5.png">
</div>

- <b>Extra</b>: For a smoother experience on the GUI, go to the "Devices" dropdown menu on VirtualBox and select "Insert Guest Additions CD Image". Then, we'll go to the Files Explorer on our DC VM and go to "This PC". In the VirtualBox Guest Additions drive, we'll run the amd64 application and install the additions. The VM will restart and the interface should be smoother.

<br />

### IP Addressing
<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD6.png">
</div>

- Now, we'll need to check which adapter is the Internet-dedicated/internal one, so we'll go to <b>"Network Connections"</b> and check the <b>Status</b> of either of the two network adapters shown.

<br />
<br />

<div align="center">
	<img width = "60%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD7.png">
</div>

- In this case, the network adapter we checked is the internal network adapter. If it was the Internet-dedicated adapter, the IP address would've been 10.x.x.x instead.

<br />
<br />

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD8.png">
</div>

- Now that we know which is which, we'll rename them appropriately so we can easily know which adapter it is later on.

<br />
<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD9.png">
</div>

- Next, we'll give an IP address to our internal adapter. In the internal adapter's <b>Properties</b>, we'll go to the <b>IPv4 Properties</b> and assign it an <b>IP address</b> of 172.16.0.1 and <b>Subnet mask</b> of 255.255.255.0 as seen in the diagram shown in the Summary section. We won't assign a <b>Default gateway</b> because the DC itself will serve as the default gateway. We'll also assign a <b>Preferred DNS server address</b> of 127.0.0.1, which is just a loop-back address that refers back to itself (alternatively, we can use the 172.16.0.1 address again as well).

<br />
<br />

<div align="center">
	<img width = "60%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD10.png">
</div>

- We'll also be renaming the PC for convenience, which will prompt the device to restart.

<br />

### Installing Active Directory Domain Services (AD DS) & Creating a Domain
<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD11.png">
</div>

- First, we'll go to the <b>Server Manager Dashboard</b> and <b>Add roles & features</b>. We'll be asked about the installation type, which should be the default-selected <b>Role-based or feature-based installation</b>, as well as which server we want to install it on.

<br />
<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD12.png">
</div>

- We're going to be installing <b>Active Directory Domain Services</b>, as well as the additional features we are prompted to add with it as seen in the image (continue through the prompts and install).

<br />
<br />

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD13.png">
</div>

- Back on the <b>Dashboard</b>, we'll see this flag appear. Even though we installed AD DS, we haven't created the domain yet, so we'll need to configure it.

<br />
<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD14.png">
</div>

- We want to <b>Add a new forest</b>, and then we can use any domain name, in this case, "ad-domain.com". We'll then be prompted for a password and can continue through the prompts to install, which will restart the device.

<br />
<br />

<div align="center">
	<img width = "30%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD15.png">
</div>

- As we can see when logging back in, the account is now associated with the domain.

<br />

### Creating a Dedicated (Domain) Admin account 
<div align="center">
	<img width = "50%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD16.png">
</div>

- In the start menu, we'll go to <b>Active Directory Users and Computers</b> in the <b>Windows Administrative Tools</b> folder.

<br />
<br />

<div align="center">
	<img width = "50%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD17.png">
  <img width = "40%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD18.png">
</div>

- Here, we're going to create a new <b>Organizational Unit</b> under our domain and name it "<b>_ADMINS</b>".

<br />
<br />

<div align="center">
	<img width = "50%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD19.png">
  <img width = "40%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD20.png">
</div>

- Now, we're going to create a new <b>User</b> in <b>_ADMINS</b>. In this example, I'll just be using my name and a common-form username for an admin account. In the next window, we'll be prompted for a password (for the lab, we'll select the <b>Password never expires</b> option as it's not relevant to this lab).

<br />
<br />

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD21.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD22.png">
</div>

- The account isn't an admin account yet, so we'll go to the account's <b>Properties</b> in the <b>_ADMINS</b> folder and make it a member of "<b>Domain Admins</b>"

- <b>Note:</b> Make sure to click "Check Names" after typing "domain admins" in the text box.

<br />
<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD23.png">
</div>

- Now, we can sign out of the default administrator account and log in to our newly created domain admin account.

<br />

### Installing a Remote Access Server (RAS) and NAT
The purpose of installing RAS/NAT is to allow the client machine (Windows 10 VM) to connect to the domain controller through the internal (private) network, and be able to access the Internet through the domain controller.

<br />

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD24.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD25.png">
</div>

- Now that we're signed in on our domain admin account, we'll go to the <b>Server Manager Dashboard</b> and <b>Add roles and features</b>. This time, the role we'll be adding is <b>Remote Access</b>.

- In the <b>Role Services</b> section, we'll install <b>Routing</b> and add features, which auto-selects <b>DirectAccess and VPN (RAS)</b> as well, and then we'll continue to install the new role.

<br />
<br />

<div align="center">
	<img width = "30%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD26.png">
  <img width = "60%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD27.png">
</div>

- Now, we'll want to select <b>Routing and Remote Access</b> in the <b>Tools</b> bar and configure and enable it for the local machine (domain controller) that we are working with..

<br />
<br />

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD28.png">
  <img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD29.png">
</div>

- We'll be configuring a <b>NAT</b> and selecting the previously-labeled public interface that is facing the Internet.

<br />
<br />

<div align="center">
	<img width = "30%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD30.png">
</div>

- After completing the RAS setup, the local domain controller server in the <b>Routing and Remote Access</b> window should appear configured with a dropdown option.

<br />

### Setting Up a DHCP Server on the Domain Controller
The DHCP server will allow clients to get an IP address and connect to the Internet through our server from the private network they will be on. 

<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD31.png">
</div>

- We'll return back to the <b>Server Manager Dashboard</b> and <b>Add roles and features</b>. We'll add the <b>DHCP Server</b> role and its features, then continue to install it.

<br />
<br />

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD32.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD33.png">
</div>

- With the role now installed, we'll select <b>DHCP</b> in the <b>Tools</b> bar and create a new scope in the <b>IPv4</b> subcategory of our DHCP server.

<br />
<br />

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD34.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD35.png">
</div>

- We'll be creating a range from 172.16.0.100 to 172.16.0.200, so I'll use that as the name to keep it simple. These will be the start and end IP addresses, and the subnet mask is 255.255.255.0 (a length of /24).

- We don't have any exclusions in this lab, however, any IP addresses to be excluded from the range would be configured in the next window.

<br />
<br />

<div align="center">
	<img width = "50%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD36.png">
</div>

- Next, we are prompted about the lease duration limit. The lease duration is how long a client will occupy an IP address from the chosen range before the IP address can be assigned to a client again. In this lab, we'll keep it at the default 8 days.

- This can be changed to suit business needs, for example, a cafe may have a shorter lease duration (~2 hours) so that IP addresses aren't occupied by customers who aren't there anymore and a corporate office environment may have a longer duration since an employees will be using a given client repetitively over longer periods of time. 

<br />
<br />

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD37.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD38.png">
</div>

- Here, we are asked if we want to configure the DHCP options for the scope. This is what tells our clients what servers to use for the default gateway and for DNS. We want this, so we'll select Yes and use the domain controller's IP address of 172.16.0.1 (make sure to click "Add").

<br />
<br />

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD39.png">
</div>

- Next, it will ask what we want to use as our domain server. It should already be pre-filled with the <b>ad-domain.com</b> domain we created before and the associated IP address (172.16.0.1).

- We won't be configuring the WINS server, so we'll continue through the prompts. In the next prompt, we'll choose Yes to activate the scope now and then finish the configuration for the new scope.

<br />
<br />

<div align="center">
	<img width = "60%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD40.png">
  <img width = "30%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD41.png">
</div>

- After the configuration, we'll authorize the DHCP server and refresh it. We've now completed our DHCP and DNS setup.

<br />

### AD Bulk User Creation PowerShell Script
<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Bulk%20Script.png">
</div>
Before continuing, I'll explain the functionality of the PowerShell script that will be used in the next section.

#### - User's First Password
<div align="center">
	<img width = "60%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Bulk1.png">
</div>

- When an account is created, the user is typically given a password that they would change after their initial login. 

- For this lab, we're assigning a simple password for demonstration purposes. We then have to convert the password into a secure string that PowerShell can then use later in the script when actually creating the user-account in Active Directory.

#### - Making a "User" Organizational Unit in Active Directory
<div align="center">
	<img width = "80%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Bulk2.png">
</div>

- Here, we are just creating an organizational unit, being "<b>_USERS</b>" in the Active Directory Users and Computers section on the Domain Controller (this is similar to the "<b>_ADMINS</b>" organizational unit we created previously).

- After we run the script, the change would appear on the Domain Controller as seen in the image below.

<br />

<div align="center">
	<img width = "50%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/BulkAD.png">
</div>

#### - Creating the User-Accounts
<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Bulk3.png">
</div>

- The final part of the script is a loop that can be broken down into 3 parts.

##### 1) Getting the Users' First & Last Names
<div align="center">
	<img width = "50%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Bulk4.png">
</div>

- Here, we have a "<b>names.txt</b>" file which is a list of our users' first and last names. The file is assigned to a variable and then the first/last name pairs are extracted. A temporary variable (<b>$user</b>) will be assigned to represent the "first intitial + last name" of each user, which will end up being a user's username in most cases.

<b>Note:</b> The filename in script should be changed to the actual file's name if it is different, as well as accounting for the filepath.

##### 2) Username Duplicates
<div align="center">
	<img width = "80%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Bulk5.png">
</div>

- There will be some instances where a user's "first intitial + last name" combination is the same as another user. In this section, we are checking our list in the (<b>$user</b>) variable to find any combinations that were the same between different users.

- If the combination has no matches, then it becomes the user's username (<b>$username</b>).

- If a match is found, then an incremental number is added to the end of the combination to create a unique username (<b>$username</b>).

##### 3) Creating the Account
<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/Bulk6.png">
</div>

- Finally, new user-accounts are created in Active Directory using all the information and variables we have gathered and created, and are stored in the <b>_USERS</b> organizational unit on the Domain Controller. The user's will have a unique username associated to their first and last name, and the initial password we set up previously is assigned to the account.

- <b>Note:</b> On the last line, I added an option so that the password doesn't expire/does not need to be changed after the first sign-in. This was for lab-purposes and would not be replicated in actual environments.

### Creating Users (in Bulk) in Active Directory with a PowerShell Script
We'll be using our ((AD Bulk User Creation))<Link to Script?> script to create over 1200 users from a "<b>names.txt</b>" file which contains the first and last names of 1200+ users.

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD42.png">
</div>

- To run the PowerShell script, we'll first need to go to <b>Windows PowerShell</b> in the start menu and run <b>Windows PowerShell ISE</b> as administrator. 

<br />
<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD43.png">
</div>

- To bypass the restrictions, and given that this is a lab environment, we'll remove any restrictions on running PowerShell scripts and change directories to where the "<b>names.txt</b>" file is located, as shown in the image above.

<br />
<br />

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD44.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD45.png">
</div>

- I'll add my name to the top of the list and we can run the bulk user creation script.

- With this, we are ready to create and use a client machine with one of the user accounts.

<br />

### Creating & Installing the Client VM
<div align="center">
	<img width = "70%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD46.png">
</div>

- Just as with the Domain Controller VM, we'll be selecting an ISO file to use for this VM, however, we'll be using the Windows 10 ISO this time. Since this is the client machine, I'll name it "CLIENT1". Same as before, we'll use 2048 MB (2 GB) of memory and 1 CPU core (can increase these options as desired for smoother function). We'll continue with the VM creation using the default settings.

<br />
<br />

<div align="center">
	<img width = "60%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD47.png">
</div>

- Before opening the VM and installing Windows, we'll go into the CLIENT1 VM's Network settings. This machine will be connecting to the Domain Controller through the internal (private) network, so we'll change the adapter settings to fit that. We are only configuring 1 adapter for this machine, unlike the 2 on the Domain Controller VM.

<br />
<br />

<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD48.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD49.png">
</div>

- We can now open our VM and go through the installation. When prompted we can select "I don't have a product key" (since I don't...), and we'll be using the <b>Windows 10 Pro</b> OS (make sure not to select Windows 10 Home since we can't join the domain with it). Then, we'll continue with the <b>Custom</b> installation since we're installing this OS onto an empty hard drive as well.

- When prompted to select a network, we'll select that we don't have internet. We'll be continuing with the "limited setup"/"using for home" options since we're making a local account and not creating a Microsoft account.

- Finally, we make an initial "user" account by giving it a name and, optionally, a password.

- Our installation is now complete.

### Client Configurations
<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD50.png">
</div>

- After logging into our client machine, we can open Command Prompt and test our connections by pinging a website like Google and pinging the domain. This shows that the network connections from the diagram shown in the Summary section are all functional.

<br />
<br />

<div align="center">
	<img width = "50%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD51.png">
</div>

- We'll be renaming the client-host and adding it to the domain, so <b>System</b> in the <b>Settings</b> and scroll down to the <b>Rename this PC (advanced)</b> setting.

<br />
<br />

<div align="center">
	<img width = "45%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD52.png">
  <img width = "40%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD53.png">
</div>

- There, we will select <b>Change</b>, where we can rename the computer to "CLIENT1" while adding it as a member of our domain (ad-domain.com).

- We'll be prompted for the user/pass of an account that is a member of the domain. Here, we can use one of the <b>_USER</b> accounts we created using our PowerShell script (though the domain admin account created would work as well). The client will then restart.

<br />
<br />

<div align="center">
	<img width = "75%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD54.png">
</div>

- When logging back in, we'll use the account we entered in the previous step.

<br />
<br />

<div align="center">
	<img src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD55.png">
</div>

- We can then open Command Prompt and confirm that we are now logged in with a user that is a member of the domain.

### Confirmation at the Domain Controller
<div align="center">
	<img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD56.png">
  <img width = "49%" src="https://github.com/mohammedshahwan/Active-Directory/blob/main/assets/AD57.png">
</div>

- If we check back on the Domain Controller machine, we'll see in the <b>DHCP</b> server that a lease has been granted to our CLIENT1 machine.

- We can also check in <b>Active Directory Users and Computers</b>, and we'll find that the client VM is listed under the Computers section since it was joined to the domain.

