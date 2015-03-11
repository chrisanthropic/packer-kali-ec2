packer-kali-ec2
===========
A Packer template to build a Kali 1.1 EC2 instance

## Requirements
* Packer
* Vagrant
* AWS account

## About the AMI
First we start with the official Offensive Security [https://www.kali.org/news/kali-linux-amazon-ec2-ami/](Kali AMI) (ami-42fa462a) then we update it to Kali 1.1.

## How to use
Add your AWS Acess_Key/Secret_Key to the kali.json template here:

```
"aws_access_key": "YOUR-ACCESS-KEY-HERE",
"aws_secret_key": "YOUR-SECRET-KEY-HERE"
```

Run packer to create the AMI: `packer build kali.json`

You now have a fully updated Kali 1.1 AMI available in your AWS EC2 account.