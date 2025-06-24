# 🧪 Type Checker for Compiler

This project is a simplified **C compiler frontend** that performs **lexical analysis**, **parsing**, **Abstract Syntax Tree (AST) construction**, and **type checking**. It also includes a **web interface** and a **Flask-based Python backend** for ease of use.

---

## 📁 Project Structure

CD_PROJECT/
├── .vscode/ # VS Code configuration
├── image/ # Images used in GUI (if any)
├── ast.c # AST construction logic
├── ast.h # Header for AST
├── compiler.exe # Compiled executable
├── gui.html # Web interface
├── inputt.c # Sample input C code
├── lex.yy.c # Generated Lex file
├── lexer.l # Lexical analyzer definition
├── parser.exe # Parser executable
├── parser.tab.c # Generated Yacc parser code
├── parser.tab.h # Generated parser header
├── parser.y # Grammar and parsing rules
├── requirements.txt # Python dependencies
├── server.py # Flask backend for GUI interaction


---

## ✅ Features

- Lexical analysis using `flex` (`lexer.l`)
- Syntax analysis using `bison` (`parser.y`)
- AST generation and traversal
- Type checking (with error reporting for mismatches)
- Flask-powered backend with a basic HTML GUI
- Modular design using C, Python, and Web tech

---
---

## ⚙️ Prerequisites

Make sure the following tools are installed on your system:

- 🐍 Python 3.x
- 💻 GCC Compiler
- ✨ Flex (Lex tool)
- 🧩 Bison (Yacc-compatible parser generator)

### 🪟 On Windows (via MSYS2 or WSL):

- [Install MSYS2](https://www.msys2.org/)
- Then run:
  ```bash
  pacman -S flex bison gcc


## 🧪 How to Run

### ⚙️ 1. Build Compiler Components

Make sure you have `flex`, `bison`, and `gcc` installed:

```bash
flex lexer.l
bison -d parser.y
gcc -o compiler lex.yy.c parser.tab.c ast.c -ly -ll

2. Install Python Requirements
pip install -r requirements.txt

3. Start the Flask Server
python server.py

4. Open in Browser
Visit:
http://127.0.0.1:5000/


Developed By
Arpita Rungta & Team
B.Tech – Computer Science
Compiler Design Project – Type Checker for Compiler