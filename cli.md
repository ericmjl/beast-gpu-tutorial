---
title: Creating an Amazon AWS Image using the CLI
author: Eric J. Ma
date: 15 December 2016
---

# The One Magic Command

This magic command assumes that you have:

1. Configured AWS
1. Created a key-pair that you can use.
1. Created a security group and that you know which security group settings you're most comfortable using.

These are oftentimes one-off things to configure from that point, the following is all that you have to remember:

```bash
$ aws ec2 run-instances \
    --image-id ami-40d28157 \
    --count 1 \
    --instance-type g2.2xlarge \
    --key-name cli_keypair \
    --security-group-ids sg-28e2c455
```

If you've not done the aforementioned 3 things, then read on.

# Install Amazon AWS CLI

Make sure you have Python installed. I recommend using the [Anaconda distribution][anaconda] of Python.

[anaconda]: https://www.continuum.io/downloads

After that, run the commands:

```bash
$ pip install awscli
```

# Configure AWS

The goal here is to configure the AWS CLI one time round so that you'll be able to use the CLI afterwards.

Follow the instructions [here][aws-config] for configuring the AWS CLI. Once done, come back here.

[aws-config]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration

In the AWS control panel, under `Users`, click on the `Permissions` tab, and then create new permissions for a group of users, and then add yourself to that group of users.

- Add user to group > `Create group`. (You'll have to do this the first time round, as there's no )
- Give your group some group name, (e.g. my group name is `em_group`), and then check the check box next to `AmazonEC2FullAccess`. Click on `Create group`.
- Click on `Groups`, and then click on `Add user to groups`, and then add yourself to the group you created.

Now, test whether your AWS CLI works, by running the following command:
```bash
$ aws ec2 describe-instances
```

If everything runs correctly, it will output the instances that you currently have running. If nothing is running, nothing will be printed to the Terminal.

If things are not working, you will most likely get an `UnauthorizedOperation` error... in which case, I would greatly appreciate [Pull Requests][prs] to the repository describing how you solved those errors.

[prs]: https://github.com/ericmjl/beast-gpu-tutorial

# (Optional) Create a key-pair.

Only do this if you haven't done so already. The commands are fairly straightforward, and here's the overview first, before providing the code.

Firstly, `cd` into the directory where you keep your SSH keys. On Unix-based systems, it will typically be `~/.ssh`. Then, use the CLI to create the key-pair and output it to disk in the `~/.ssh` directory. Finally, we change the permissions on the `.pem` file to a permission acceptable for use with EC2.

In the following code block, remember to replace `cli_keypair` with some unique name that you prefer to use.

```bash
$ cd ~/.ssh
$ aws ec2 create-key-pair --key-name cli_keypair > cli_keypair.pem
$ chmod 400 cli_keypair.pem
```

Finally, use a text editor to edit the `.pem` file to get rid of the text (including the spaces) before `-----BEGIN RSA PRIVATE KEY-----` and after `-----END RSA PRIVATE KEY-----`. The `.pem` file should look like this:

```
-----BEGIN RSA PRIVATE KEY-----
QJq6mm7HXZRjORImvjNqYRYwjMfWKyCUShFnj0jlP8iKSqLieO2C0nMWi+xaOfBMK1E844cPatpS
MIDFowIBAAKCAQEAr3JB5qrzsnw3w64dOYdZ5bmdZYizw+23sk5TWZJJq62fGv6LUz96k051rz8E
9g8BgE8/WeL1yPfds1jZEodCouDdGMqWap1kkx2ig7bB61Tj8CfWPbDB0u7j5AusIR98OofRFFzw
h5Ed0F2FLFtqWD5ZDKW8x439xedM4/VkZci+w3CDtoqxR1yz8rk6GbY8YdkaTSpyRPLCn0uuDp8o
...
-----END RSA PRIVATE KEY-----
```

# (Optional) Create a security group.

In the short time I gave myself to write this tutorial, I could not figure out an "easy-to-use" way of creating a security group. I would recommend using the web-based interface to create on.

Later on, if you want to figure out what security groups are available, run the following command:

```bash
$ aws ec2 describe-security-groups
```

A list of security groups that you have associated with your account will be printed to screen. **Knowing the security group name is important for the next step.**

# Fire up an EC2 instance

The instructions here are a summary of what's available on Amazon's [website][amzn]. The most important command to run is below:

```bash
$ aws ec2 run-instances \
    --image-id ami-40d28157 \
    --count 1 \
    --instance-type g2.2xlarge \
    --key-name cli_keypair \
    --security-group-ids sg-28e2c455
```

A few things to note here:

- `--image-id ami-40d28157`: this is the Ubuntu Linux AMI.
- `--count 1`: we are only launching one instance.
- `--instance-type g2.2xlarge`: we are launching the `g2.2xlarge` instance, which is the GPU-based one.
- `--key-name cli_keypair`: we are using this particular key to access the instance. It should not have the path to the key, but just the name of the key.
- `--security-groups sg-28e2c455`: we are using this particular security group. Note: it's not the name you give it, but a unique ID assigned by Amazon.

[amzn]: http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-launch.html#launching-instances

Once it's run, after a short while, you will see the instance show up running on your EC2 dashboard (view using web browser). Alternatively, run the following command to see what instances are running. Sample output is also provided.

```bash
$ aws ec2 describe-instances

RESERVATIONS	597678314672	r-0a4c508d7779e8356
INSTANCES	0	x86_64		False	xen	ami-40d28157	i-027e9ef1e23a4e046	g2.2xlarge	cli_keypair	2016-12-16T00:49:29.000Z	ip-172-31-16-181.ec2.internal	172.31.16.181	ec2-54-88-130-120.compute-1.amazonaws.com	54.88.130.120	/dev/sda1	ebs	True		subnet-8f15f1d7	hvm	vpc-999e0ffd
BLOCKDEVICEMAPPINGS	/dev/sda1
EBS	2016-12-16T00:49:30.000Z	True	attached	vol-0b404dcd8082e61c3
MONITORING	disabled
NETWORKINTERFACES		0e:ea:be:5f:f5:34	eni-efa84c2c	597678314672	ip-172-31-16-181.ec2.internal	172.31.16.181	True	in-use	subnet-8f15f1d7	vpc-999e0ffd
ASSOCIATION	amazon	ec2-54-88-130-120.compute-1.amazonaws.com	54.88.130.120
ATTACHMENT	2016-12-16T00:49:29.000Z	eni-attach-66ee75e0	True	0	attached
GROUPS	sg-28e2c455	SSH-only access
PRIVATEIPADDRESSES	True	ip-172-31-16-181.ec2.internal	172.31.16.181
ASSOCIATION	amazon	ec2-54-88-130-120.compute-1.amazonaws.com	54.88.130.120
PLACEMENT	us-east-1a		default
SECURITYGROUPS	sg-28e2c455	SSH-only access
STATE	16	running
```

Take note of the addresses provided. They are in the following line, accessible with `grep`.

```bash
$ aws ec2 describe-instances | grep INSTANCES
INSTANCES	0	x86_64		False	xen	ami-40d28157	i-027e9ef1e23a4e046	g2.2xlarge	cli_keypair	2016-12-16T00:49:29.000Z	ip-172-31-16-181.ec2.internal	172.31.16.181	ec2-54-88-130-120.compute-1.amazonaws.com	54.88.130.120	/dev/sda1	ebs	True		subnet-8f15f1d7	hvm	vpc-999e0ffd
```

Still not very convenient yet for programmatically starting and stopping instances, but it'll suffice for now. Take note of the address of the instance, it'll look like `ec2-[ip-addr-numbers-here].compute-1.amazonaws.com`. You can now SSH into the instance using the following command:

```bash
$ ssh ubuntu@ec2-54-88-130-120.compute-1.amazonaws.com -i ~/.ssh/cli_keypair.pem
```

Alternatively, you can choose to go back and edit your SSH config file. This is described in the [main tutorial][back].

[back]: https://ericmjl.github.io/beast-gpu-tutorial/#configure-ssh-and-then-ssh-into-the-amazon-ec2-instance
