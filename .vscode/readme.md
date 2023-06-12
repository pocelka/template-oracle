# MS Visual Studio Code Build Tasks

- [MS Visual Studio Code Build Tasks](#ms-visual-studio-code-build-tasks)
  - [Setup](#setup)
    - [Password Manager Setup](#password-manager-setup)
    - [`tasks.json`](#tasksjson)
    - [`run_sql.sh`](#run_sqlsh)
    - [`apex_export.sh`](#apex_exportsh)
    - [APEX Export](#apex-export)
    - [Compiling Code](#compiling-code)

[Microsoft Visual Studio Code (VSC)](https://code.visualstudio.com/) is a code editor. VSC can compile PL/SQL code directly from VSC (see [this blog](https://ora-00001.blogspot.ca/2017/03/using-vs-code-for-plsql-development.html)) for more information. Opening this project folder in VSC will automatically give you the ability to compile PL/SQL code and do APEX backups

## Setup

Before first task execution few manual changes have to be perfomed for proper functionality.

Modify privileges for helper scripts:

```bash
chmod +x .vscode/scripts/*.sh
chmod +x scripts/*.sh
```

### Password Manager Setup

Storing passwords in plain text is always risky. Personally I don't like to store passwords locally and therefore I'm using [Bitwarden](https://bitwarden.com) as my password manager. Good thing about it is, that you can access your password database using CLI. To setup CLI access you need to perform the following steps:

- Set environment variables (i.e. in your shell profile): `BW_CLIENTID` and `BW_CLIENTSECRET`.
- Login into Bitwarden and unlock database:

    ```bash
    bw login --apikey
    bw unlock --raw
    ```

- `bw unlock` command returns a string which needs to be set into environment variable `BW_SESSION`.
- It might be also good idea to sync database using:

    ```bash
    bw sync
    ```

For more information about CLI, please refer to official documentation.

> If you don't wish to use Bitwarden integration, modify function `get_connection_string` in `./scripts/helper.sh`. Please also modify this section even if you are also using Bitwarden as your setup for passwords might be different.

### `tasks.json`

This file defines the VSCode task. The following changes should be performed:

- Modify `inputs` array and `default` elements. Basically each element in the arraty represents value from Bitwarden entry.
- Modify value for environment variables:

    | Environment Variable | Description                                                                        |
    | -------------------- | ---------------------------------------------------------------------------------- |
    | OCI_WALLET_MAC       | Path where your OCI wallet is located. Keep empty if you are not using OCI wallet. |
    | OCI_WALLET_LINUX     | Path where your OCI wallet is located. Keep empty if you are not using OCI wallet. |
    | SQL_CLI_BINARY       | sqlcl or sqlplus. Full path if binaries are not globally accessible.               |

### `run_sql.sh`

This file is used as a wrapper to execute SQL scripts/commands. You might need to modify section `User specific commands` if you need some specific SQL*Plus pre-setup (i.e. spooling into file).

### `apex_export.sh`

This file is used as a wrapper to export Apex applications. You might need to modify section `User specific commands` if you need some specific SQL*Plus pre-setup.

### APEX Export

If you want to export your APEX applications execute the `Oracle: Export APEX Application` task. Taks supports export for multiple applications (separated by comma).

### Compiling Code

To compile the current file you're editing execute the `Oracle: Execute SQL` task.
