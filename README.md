# terraform_networking

# Problem Statement 1: 

We have to create a web portal for our company with all the security as much as possible.

So, we use WordPress software with dedicated database server.

Database should not be accessible from the outside world for security purposes.

We only need to public the WordPress to clients.

Don't forgot to add auto IP assign.

So here are the steps for proper understanding!

Steps:

1)Write a Infrastructure as code using terraform, which automatically create a VPC.

2)In that VPC we have to create 2 subnets :

  a) public subnet [ Accessible for Public World! ] 

  b) private subnet [ Restricted for Public World! ]

3)Create a public facing internet gateway for connecting our VPC/Network to the internet world and attach this gateway to our VPC.

4)Create a routing table for Internet gateway so that instance can connect to outside world, update and associate it with public subnet.

5)Launch an EC2 instance which has WordPress setup already having the security group allowing port 80 so that our client can connect to our WordPress site.

Also attach the key to instance for further login into it.

6)Launch an EC2 instance which has MYSQL setup already with security group allowing port 3306 in private subnet so that our WordPress VM can connect with the same.

Also attach the key with the same.

# Explanation :

https://www.linkedin.com/pulse/create-secure-web-portal-suhani-arora

# Problem Statement 2: 

We have to create a web portal for our company with all the security as much as possible.

So, we use WordPress software with dedicated database server.

Database should not be accessible from the outside world for security purposes.

We only need to public the WordPress to clients.

Don't forgot to add auto IP assign.

Also add NAT Gateway to provide the internet access to instances running in the private subnet.

So here are the steps for proper understanding!

Performing the following steps:

1. Write an Infrastructure as code using terraform, which automatically create a VPC.

2. In that VPC we have to create 2 subnets :

  1.  public subnet [ Accessible for Public World! ] 

  2.  private subnet [ Restricted for Public World! ]

3. Create a public facing internet gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC.

4. Create a routing table for Internet gateway so that instance can connect to outside world, update and associate it with public subnet.

5. Create a NAT gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC in the public network

6. Update the routing table of the private subnet, so that to access the internet it uses the nat gateway created in the public subnet

7. Launch an ec2 instance which has WordPress setup already having the security group allowing port 80 so that our client can connect to our WordPress site. Also attach the key to instance for further login into it.

8. Launch an EC2 instance which has MySQL setup already with security group allowing port 3306 in private subnet so that our WordPress VM can connect with the same. Also attach the key with the same.

# Explanation :

https://www.linkedin.com/pulse/secure-web-portal-using-wordpress-mysql-suhani-arora
