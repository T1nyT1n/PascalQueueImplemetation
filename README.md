**English** | [Русский](docs/README_RU.md)

# Circular Queue Implementation in Pascal

A TUI application to demonstrate the operation of a circular queue in Pascal.

## Features

- Implementation using a linked list
- Cross-platform
- Case-menu with arrow key navigation

## Functions

- Create and clear the structure
- Insert an element
- Read an element
- Delete an element
- Display all elements in the structure with their count shown

## How to Use?

### Compilation

Use [Free Pascal](https://www.freepascal.org/) to compile the program for your platform. By default, the Windows command line uses the CP866 encoding, which does not support Russian. To compile the program with UTF-8 support, add a special compiler flag.

```
fpc -FcUTF-8 main.pas
```

Linux terminals most commonly use UTF-8 by default.

### Usage

- The application runs in a terminal.
- Use the up and down arrow keys to navigate the main menu.
- Press the Enter key to activate the selected function.
- After activating a function, follow the on-screen instructions to proceed.