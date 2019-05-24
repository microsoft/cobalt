# Modules

## Metadata
| Metadata field | Description                 | Possible values | Example         | Required? |
|----------------|-----------------------------|-----------------|-----------------|-----------|
| `category`     | Always set to `module`.     | `module`        | `category: module`  | Y     |
| `date`         | Timestamp of file creation. This will be updated during deployment. | - | `date: 2020-03-07 17:24` | Y |
| `draft`        | Indicates if doc is a draft. This should be set as `true` by author. The CD pipeline will change the value to `false` during deployment. | `true`<BR>`false` | `draft: true` | Y |
| `provider`     | Name of cloud provider.     | `azure`<BR>`aws` |`provider: azure` | Y       |
| `tags`         | List of tags associated with module. | `api`<BR>`containers-managed`<BR>`containers-orchestrated`<BR>`load-balancer`<BR>`logging`<BR>`metrics`<BR>`paas` | `tags:`<BR>&nbsp;&nbsp;`- containers-managed`<BR>&nbsp;&nbsp;`- logging`<BR>&nbsp;&nbsp;`- paas` | N |
| `targetUser`   | Suggested user of template. | `app-dev`<BR>`network-admin` | `targetUser: network-admin` | Y |
| `title`        | Humanized, sentence-case name of module. | - | `title: API management` | Y  |

## Content
| Content section | Description                                                    | Required? |
|-----------------|----------------------------------------------------------------|-----------|
| Summary         | Brief summary of the module.                                   | Y         |
| How to use      | Numbered list of usage steps.                                  | Y         |
| Configuraton    | Table listing configurable settings with description and possible values. | Y |
| Sample output   | Code block showing a sample output.                            | Y         |


# Templates

## Metadata

## Content

