# jirac.nvim [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/your/your-project/blob/master/LICENSE)

JiraC is a Jira Cilent built into Neovim. Plugin provides simple Jira functionality so
developers can browse and edit tasks inside their editor.

* [Features](#features)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
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

`:JiracIssue <issue_key | search_phrase> [<project_key>]`

Open issue panel. Use it to browse, modify and transition issues.
Jirac runs a search every time this command is used and will
open issue search panel instead if more than one or no issue is found.
If no project_key is specified, `default_project_key` will be used.

## <a name="configuration">Configuration</a>

## <a name="roadmap">Roadmap</a>
