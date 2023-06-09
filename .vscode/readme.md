# MS Visual Studio Code Build Tasks

- [MS Visual Studio Code Build Tasks](#ms-visual-studio-code-build-tasks)
  - [Setup](#setup)
    - [Password Manager Setup](#password-manager-setup)
    - [`tasks.json`](#tasksjson)
    - [APEX Export](#apex-export)
    - [Compiling Code](#compiling-code)

[Microsoft Visual Studio Code (VSC)](https://code.visualstudio.com/) is a code editor. VSC can compile PL/SQL code directly from VSC (see [this blog](https://ora-00001.blogspot.ca/2017/03/using-vs-code-for-plsql-development.html)) for more information. Opening this project folder in VSC will automatically give you the ability to compile PL/SQL code and do APEX backups

## Setup

Before first task execution few manual changes have to be perfomed for proper functionality.

### Password Manager Setup

Storing passwords is always risky. Personally I don't like to store passwords locally and therefore I'm using [Bitwarden](https://bitwarden.com) as my password manager. Good think about it is, that you can access your password database using CLI. To setup CLI access you need to perform the following steps:

- Set environment variables (i.e. in your shell profile): `BW_CLIENTID` and `BW_CLIENTSECRET`
- Login into Bitwarden and unlock database:

    ```bash
    bw login --apikey
    bw unlock --raw
    ```

- `bw unlock` command returns a string which needs to be set into environment variable `BW_SESSION`

For more information about CLI, please refer to official documentaiton.

### `tasks.json`

This file defines the VSCode task. The following changes should be performed:

- Modify value for environment variable `OCI_WALLET`.
- Modify `inputs` array and `default` elements. Basically each element in the arraty represents value from Bitwarden entry.

### APEX Export

If you want to export your APEX applications execute the `Oracle: Export APEX Application` task.

### Compiling Code

To compile the current file you're editing execute the `Oracle: Execute SQL` task.
