from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import subprocess
import tempfile
import os

app = Flask(__name__)
CORS(app)

@app.route('/')
def serve_html():
    return send_from_directory('.', 'gui.html')

@app.route('/<path:filename>')
def serve_static(filename):
    return send_from_directory('.', filename)

@app.route('/check', methods=['POST'])
def check_code():
    try:
        data = request.get_json()
        code = data.get('code', '')
        action = data.get('action', 'all')
        
        if not code.strip():
            return jsonify({'output': 'Please enter code to check.'})
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.c', delete=False) as temp_input:
            temp_input.write(code)
            temp_input_path = temp_input.name
        
        try:
            compile_result = compile_parser()
            if compile_result['success']:
                result = run_parser(temp_input_path, action)
                return jsonify({'output': result})
            else:
                return jsonify({'output': f'Compilation Error: {compile_result["error"]}'})
        finally:
            if os.path.exists(temp_input_path):
                os.unlink(temp_input_path)
                
    except Exception as e:
        return jsonify({'output': f'Server Error: {str(e)}'})

def compile_parser():
    try:
        # Check required files
        required_files = ['lexer.l', 'parser.y', 'ast.c', 'ast.h']
        missing = [f for f in required_files if not os.path.exists(f)]
        if missing:
            return {'success': False, 'error': f'Missing files: {", ".join(missing)}'}
        
        # Clean up
        for f in ['lex.yy.c', 'parser.tab.c', 'parser.tab.h', 'parser.exe', 'parser']:
            if os.path.exists(f):
                try: os.unlink(f)
                except: pass
        
        # Generate lexer
        if subprocess.run(['flex', 'lexer.l'], capture_output=True).returncode != 0:
            return {'success': False, 'error': 'Flex failed'}
        
        # Generate parser
        if subprocess.run(['bison', '-d', 'parser.y'], capture_output=True).returncode != 0:
            return {'success': False, 'error': 'Bison failed'}
        
        # Verify files created
        if not os.path.exists('parser.tab.c'):
            return {'success': False, 'error': 'parser.tab.c not generated'}
        
        # Compile - try different commands for Windows compatibility
        gcc_commands = [
            ['gcc', '-o', 'parser.exe', 'parser.tab.c', 'lex.yy.c', 'ast.c'],
            ['gcc', '-o', 'parser', 'parser.tab.c', 'lex.yy.c', 'ast.c', '-lfl', '-ly']
        ]
        
        for cmd in gcc_commands:
            if subprocess.run(cmd, capture_output=True).returncode == 0:
                return {'success': True}
        
        return {'success': False, 'error': 'GCC compilation failed'}
        
    except FileNotFoundError:
        return {'success': False, 'error': 'flex/bison/gcc not found. Install development tools.'}
    except Exception as e:
        return {'success': False, 'error': f'Compilation error: {str(e)}'}

def run_parser(input_file_path, action='all'):
    try:
        executable = 'parser.exe' if os.name == 'nt' else 'parser'
        if not os.path.exists(executable):
            return f'{executable} not found'
        
        with open(input_file_path, 'r') as f:
            result = subprocess.run([f'./{executable}'], stdin=f, 
                                  capture_output=True, text=True, timeout=30)
        
        output = (result.stdout + '\n' + result.stderr).strip()
        
        if action != 'all':
            output = filter_output(output, action)
        
        return output or "Parser completed but produced no output."
        
    except subprocess.TimeoutExpired:
        return "Parser timed out."
    except Exception as e:
        return f"Execution error: {str(e)}"

def filter_output(output, action):
    lines = output.split('\n')
    
    if action == 'generateAST':
        start_idx = next((i for i, line in enumerate(lines) if 'Generated AST:' in line), -1)
        end_idx = next((i for i, line in enumerate(lines[start_idx+1:], start_idx+1) 
                       if 'Semantic Analysis:' in line or 'Symbol Table:' in line), len(lines))
        return '\n'.join(lines[start_idx:end_idx]) if start_idx != -1 else "No AST found"
    
    elif action == 'generateSymbolTable':
        start_idx = next((i for i, line in enumerate(lines) if 'Symbol Table:' in line), -1)
        return '\n'.join(lines[start_idx:]) if start_idx != -1 else "No Symbol Table found"
    
    elif action == 'checkSemanticErrors':
        error_lines = [line for line in lines if 'semantic' in line.lower()]
        return '\n'.join(error_lines) or "No semantic error information found"
    
    return output

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'Server is running'})

if __name__ == '__main__':
    print("Starting Type Checker Server...")
    print("Required files: lexer.l, parser.y, ast.c, ast.h, gui.html")
    print("Server: http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)