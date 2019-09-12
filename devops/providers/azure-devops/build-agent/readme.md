# CSE Azure Pipeline Agent

This agent will allow CSE projects to build any linux based project using container tasks.

[Running in Docker](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#linux)

```bash
docker run -d -v /var/run/docker.sock:/var/run/docker.sock \
    -e "AZP_URL=https://dev.azure.com/PROJECT" \
    -e "AZP_TOKEN=PAT_TOKEN" \
    -e "AZP_AGENT_NAME=myAgent01" \
    -e "AZP_POOL=DocPool" \
    registry/cobalt-agent:0.0.1
```