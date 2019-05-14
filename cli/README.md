# Cobalt CLI

Currently this only contains the start of the project structure, a test concept, Makefile and Readme. From a terminal, cd into the `cli` folder and run:

```make deps```
```make build```
```make run```
```make test```

We are currently only using go-cobra and go-testing packages just to get something committed. 

# Cobalt CLI Commands

List help commands:

```cobalt --help```

Setup template in current directory:

```cobalt setup --template "bedrock/azure-simple"```

> The flag `--template` is specified using the following structure:
>
> `[github repo name]/[cobalt template name]`

Test the current template in current directory:

```cobalt run --docker```

# Cobalt Usage
1. Create project dir: my_cobalt_proj
2. `cd` to my_cobalt_proj
3. Run `cobalt setup --template "cobalt/azure-simple"`
4. Follow prompts for cloud provider info

```
ianphil@afropro.local [~/src/tmp/my_cobalt_proj]
> tree -a
.
├── .env
├── infra
│   └── templates
│       └── azure-simple-hw
│           ├── backend.tf
│           ├── main.tf
│           ├── outputs.tf
│           ├── provider.tf
│           ├── test
│           │   └── integration
│           │       └── azure_simple_integration_test.go
│           └── variables.tf
```