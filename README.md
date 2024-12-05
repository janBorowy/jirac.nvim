# jirac.nvim [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/your/your-project/blob/master/LICENSE)

JiraC is a Jira Cilent built into Neovim. Plugin provides simple Jira functionality so
developers can browse and edit tasks inside their editor. Jirac uses
[nui-components.nvim](https://github.com/grapp-dev/nui-components.nvim) to provide
user-friendly interface.

* [Features](#features)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Known Issues](#known-issues)
* [Roadmap](#roadmap)


## <a name="features">Features</a>
* Browse projects and project's details
* Browse issues and issue's details
* Easily edit issues
* Browse and manipulate issue's comments

## <a name="requirements">Requirements</a>
* [Neovim](https://neovim.io/) - tested on >= 0.10.1
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - for "plenary.curl"
* [nui-components.nvim](https://github.com/grapp-dev/nui-components.nvim) - for UI

## <a name="installation">Installation</a>
Install using your favorite plugin manager:

[Lazy](https://github.com/folke/lazy.nvim)
```lua
{
    "janBorowy/jirac.nvim"
        dependencies = {
            "grapp-dev/nui-components.nvim",
            "nvim-lua/plenary.nvim"
        }
}
```

[Packer](https://github.com/wbthomason/packer.nvim)
```lua
use {
    "janBorowy/jirac.nvim",
        requires = {
            "grapp-dev/nui-components.nvim",
            "nvim-lua/plenary.nvim"
        }
}
```

## <a name="usage">Usage</a>

`:Jirac`

Open Jirac navigation panel.

`:JiracIssue <issue_key> [<project_key>]`

Open issue panel. Use it to browse, modify and transition issues.
`<issue_key>` must be an exact issue's key.
If no project_key is specified, `<default_project_key>` will be used.

`:JiracIssueSearch <search_phrase> [<project_key>]`

Search for issue containing `<search_phrase>` in it's summary or description.

`:JiracJql <jql>`

`:JiracProject [<project_key>]`

Open project panel of project specified by `<project_key>` argument or
`<default_project_key>` if none is specified.

`:JiracProjectSearch <search_phrase>`

Search for a project using `<search_phrase>`

## <a name="configuration">Configuration</a>

## <a name="roadmap">Roadmap</a>

## <a name="known-issues">Known Issues</a>
- You can't add issues to Company-managed software/business project types
