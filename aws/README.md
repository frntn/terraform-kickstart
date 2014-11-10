# Terraform AWS Kickstart

This folder contains 4 generic network configurations.

In order to use them, first you have to put your own `AWS secret key` and 
`AWS access key` inside input files **without ending newline**.
On Unix-like operating system you can do the following :

    echo -n "MYSECRETKEY" > secret_key
    echo -n "MYACCESSKEY" > access_key

Then go to one of the subfolder (choose one thanks to details below) and :

    terraform apply

The following layout templates have been tested OK with terraform 0.3.1 with
an post-2013 AWS account (eg. EC2-VPC only, no EC2-classic)

## Templates descriptions

#### pub1

Just one public network on one AZ.
(availability zone A of your region)

#### pub1-priv1

One public network and one private on one AZ.
You can put in the private subnet your machines that are not meant to be
accessible from outside.
(availability zones A of your region)

*Typical use is for your web servers (public network) to access a separate
database server (private network)*

#### pub2

Same as `pub1` but distributed on two AZ for high availability.
(availability zone B and C of your region)

*Typical use is for scalability of your web servers (public networks)*

#### pub2-priv2

Same as `priv1_pub1` but distributed on two AZ for high-availability.
(availabilty zones B and C of your region)

*Typical use is for scalability of your web servers (public networks) and
redundancy for your databases (private networks)*

## Limitations / Known Issues

You may need to consider the following limitations as terraform is an excellent
tool in active development but still in 0.3.1...

#### DependencyViolation error while destroying with bastion server

On both `pub1-priv1` and `pub2-priv2` layouts, you'll find a `bastion` section.
It should be used to access the machines inside the private subnet. It's also 
a good practice to use this kind of unique bastion server (the only entry point 
with security focus) for `pub1` and `pub2` subnets.

By default this section is commented out because you may want to change the 
`ami` and `instance_type`.

**If you use this bastion server, you'll have to first remove it (comment
back this section then `terraform apply`) before being able to destroy the 
whole layout (`terraform destroy`) without any error (`DependencyViolation`).**


