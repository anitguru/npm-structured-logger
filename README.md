# npm-structured-logger

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

This repository provides a **Zsh** script to run an npm (Node.js) command and capture its output as **structured JSON logs**, including startup/shutdown events and optional log levels. It's designed to work with projects like Docusaurus, but can be adapted for other Node.js projects.

- **Uses**: Zsh (5.8+ recommended), environment variables, and `sed` for minor text processing
- **Output**: Creates a line-oriented JSON log file with timestamp, optional log level, and message for each line of the command's output
- **Extensible**: Easily adapt to other commands or frameworks (e.g., Yarn, npx, Docusaurus)

## Contents

1. [Setup](#setup)
2. [Directory Structure](#directory-structure)
3. [Usage](#usage)
4. [How It Works](#how-it-works)
5. [Example .env](#example-env)
6. [License](#license)

## Setup

1. **Clone the Repo**:
   ```zsh
   git clone https://github.com/your-username/npm-structured-logger.git
   ```
2. **Create .env file**:
   ```zsh
   cp .env.example .env
   # Then edit .env to set your COMMAND, LOGFILE_PATH, and PROJECT_PATH
   ```

## Directory Structure

```zsh
.
├── .env
├── .env.example
├── .gitignore
├── README.md
└── npm-structured-logger.zsh
```

## Usage

1. **Make the script executable**:

   ```zsh
   chmod +x npm-structured-logger.zsh
   ```

2. **Run the script**:
   ```zsh
   ./npm-structured-logger.zsh
   ```

The script reads `.env` for `COMMAND` (the npm/Node command to run), `LOGFILE_PATH` (where JSON logs are written), and `PROJECT_PATH` (the directory of your Node.js project). It logs a **startup** event, then pipes all command output line by line, writes them as **JSON** in `LOGFILE_PATH`, and logs a **shutdown** event when you press <kbd>Ctrl</kbd> + <kbd>C</kbd>.

### Viewing Logs

```zsh
source .env
tail -f $LOGFILE_PATH
```

- Each output line appears as a **single JSON object** (line-oriented JSON).
- For example:
  ```json
  {"time":"2025-02-16T15:57:03-0500","event":"startup"}
  {"time":"2025-02-16T15:57:03-0500","event":"log","level":"INFO","message":"Starting the development server..."}
  {"time":"2025-02-16T15:57:03-0500","event":"shutdown"}
  ```

## How It Works

- **Startup/Shutdown Events**: The script logs startup and shutdown events.
- **Change to Project Directory**: The script changes to the specified project directory before running the command.
- **Background Execution**: The specified command runs in the background, with its output redirected to a temporary file.
- **Log Processing**: Each line of output is processed and written as a JSON object to the log file.
- **Graceful Exit**: The script handles SIGINT (Ctrl+C) and other termination signals, ensuring proper cleanup.

## Example .env

```zsh
COMMAND="npm run --prefix /Users/{your-OS-username}/Github/docusaurus start"
LOGFILE_PATH="/Users/{your-OS-username}/Github/docusaurus/log/dev.log"
PROJECT_PATH="/Users/{your-OS-username}/Github/docusaurus"
```

- **`COMMAND`**: The npm command to run, including any necessary prefixes or paths.
- **`LOGFILE_PATH`**: The full path where your structured JSON logs will be written.
- **`PROJECT_PATH`**: The full path to your Node.js project directory.

## License

[MIT](LICENSE)

Feel free to adapt this script for your own projects. Contributions and PRs are welcome!
