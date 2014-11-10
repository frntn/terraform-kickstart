# terraform.io Kickstarter

**terraform-kickstart** is an attempt to provide sets of easy to use 
pre-defined configurations templates to use with 
[terraform](https://www.terraform.io/).


## Separation of concerns

Terraform manage the resources it has created, so it's safe to separate
your terraform configurations.

On AWS, I use this concept to distinguish the following :

- `network layouts` : VPC, subnet, route 53, etc...
- `machines distribution`: EC2, RDS, DynamoDB, SQS, etc...

So for this very first `aws/` folder you will find 4 generics **networks 
layouts** to start with terraform in a *Amazon Web Services* environment.

See the README.md inside the `aws` folder for details on each network layout.

## Project overview

```
├── README.md         # <- the file you are currently reading
└── aws/
    │
    ├── README.md
    ├── access_key    # <- create this file (see aws/README.md)
    ├── secret_key    # <- create this file (see aws/README.md)
    │
    ├── pub1/
    │   └── infra.tf
    │
    ├── pub1-priv1/
    │   └── infra.tf
    │
    ├── pub2/
    │   └── infra.tf
    │
    └── pub2-priv2/
        └── infra.tf

```

## VIM

The hcl.vim highlight nested string correctly...

```
  mv hcl.vim /usr/share/vim/vimcurrent/syntax/
```

![Image: VIM custom HCL syntax highlight screenshot](https://raw.githubusercontent.com/frntn/terraform-kickstart/master/vim-highlight-result.png)
