# Starter Project Template

Inspired by [Insum](https://github.com/insum-labs/starter-project-template) template.

This template provides scripts and processes to help speed up development and simplify some of release processes.

It's **important** to note this is a **template**. Additional changes might be required. All the included tools are meant to help provide results quickly.

- [Starter Project Template](#starter-project-template)
  - [Start](#start)
  - [Overview](#overview)
  - [Setup](#setup)
  - [Folder Structure](#folder-structure)

## Start

In Github simply click the [`Use this template`](https://github.com/pocelka/template-oracle/generate) button.

If using another git platform, start a new project (`git init`) then [**download**](https://github.com/pocelka/template/archive/refs/heads/master.zip) this project (*do not clone or fork*) and unzip into your new project. When copying it's important to copy all hidden files and folders.

## Overview

This template contains a lot of features that may help with your project.

- [Build](build/): Scripts to generate the release
- [Folders](#folder-structure): The most common project folder structure is provided with this project.
- [Release](release/): Framework to build and do releases.
- [Visual Studio Code][vscode] (VSC) integration: compile or run your SQL and PL/SQL code right from VSC. More details are provided in the [`.vscode`](.vscode/) folder.

Once [configured](#setup) the high level process to leverage this template is as follows:

## Setup

- [`pre-commit`](https://pre-commit.com): Install pre-commit
- [`scripts/project-config.sh`](scripts/project-config.sh): Configure APEX settings
- [`scripts/user-config.sh`](scripts/user-config.sh): The first time any bash script is executed this file will be generated and needs to be modified with user specific settings. By default this file should not be committed to your git repo as it contains user specific settings and database passwords
- Remove directories that don't apply to your project (ie. data, templates, etc...)

## Folder Structure

The default folder structure (listed below) provides a set of common folders most projects will use. You're encouraged to add new folders to your projects where necessary.

| Folder / File            | Description                                                                                 |
| ------------------------ | ------------------------------------------------------------------------------------------- |
| [`.vscode`](.vscode/)    | [Visual Studio Code][vscode] specific settings                                              |
| [`apex`](database/apex/) | Application exports                                                                         |
| [`data`](database/data/) | Conversion and seed data scripts                                                            |
| docs                     | Project documents                                                                           |
| [`scripts`](scripts/)    | Usually re-runable scripts or tools                                                         |
| www                      | Assets that go in the server: images, CSS, and JavaScript                                   |
| version                  | Version of the application in [semantic versioning](https://semver.org) - major.minor.patch |

[vscode]: https://code.visualstudio.com/
