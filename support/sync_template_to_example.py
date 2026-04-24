#!/usr/bin/env python3
import os
import shutil
import subprocess

def sync():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    template_dir = os.path.join(root_dir, 'templates', 'solidui', 'brick')
    example_dir = os.path.join(root_dir, 'example')
    
    print(f"Syncing template from {template_dir} to {example_dir}...")
    
    # 1. Ensure mason is initialized and get the brick
    try:
        subprocess.run(['mason', 'get'], cwd=root_dir, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        print("Mason CLI check failed. Please ensure it's installed: 'dart pub global activate mason_cli'")
        return

    # 2. Run mason make to a temporary directory
    temp_gen_dir = os.path.join(root_dir, '.temp_template_gen')
    if os.path.exists(temp_gen_dir):
        shutil.rmtree(temp_gen_dir)
    os.makedirs(temp_gen_dir)
    
    try:
        subprocess.run([
            'mason', 'make', 'solidui',
            '--projectName', 'myapp',
            '--description', 'My App - A SolidUI Template Application',
            '--author', 'Software Innovation Institute, ANU',
            '-o', temp_gen_dir
        ], cwd=root_dir, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        print("Failed to run 'mason make'. Check if Mason is properly configured.")
        shutil.rmtree(temp_gen_dir)
        return

    # 3. Copy generated files back to example
    # Generated files are usually lib/, assets/, pubspec.yaml, etc.
    gen_content_dir = temp_gen_dir  # mason make -o temp_gen_dir puts files directly there
    
    for item in os.listdir(gen_content_dir):
        s = os.path.join(gen_content_dir, item)
        d = os.path.join(example_dir, item)
        if os.path.isdir(s):
            if os.path.exists(d):
                shutil.rmtree(d)
            shutil.copytree(s, d)
            print(f"Updated directory: {item}")
        else:
            shutil.copy2(s, d)
            print(f"Updated file: {item}")
            
    # Clean up
    shutil.rmtree(temp_gen_dir)
    print("Sync complete.")

if __name__ == "__main__":
    sync()
