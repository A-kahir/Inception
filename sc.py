#!/usr/bin/env python3

import os
import json

# --- Configuration ---
# Add the file extensions you want to include (must be a tuple)
TARGET_EXTENSIONS = ('.cnf', '.sh', '.conf', '.dockerignore', '.env', '.yml', '.css', '.html', 'js')

# Add the exact filenames you want to include (case-insensitive check is used below)
TARGET_FILENAMES = ('Dockerfile', 'Makefile')

# The name of the output JSON file
OUTPUT_FILENAME = 'project_data.json'

# The root directory to start searching from ('.' means current directory)
ROOT_DIR = '.'
# --- End of Configuration ---


def pack_files_to_json():
    """
    Finds specified files in the current and subdirectories and packs them
    into a single JSON file.
    """
    all_files_data = {}
    
    # Normalize target filenames to lowercase for case-insensitive comparison
    target_filenames_lower = [name.lower() for name in TARGET_FILENAMES]

    print(f"Starting file search in root directory: '{os.path.abspath(ROOT_DIR)}'")
    print(f"Looking for extensions: {TARGET_EXTENSIONS}")
    print(f"Looking for filenames: {TARGET_FILENAMES}")
    print("-" * 30)

    # os.walk recursively explores the directory tree
    for dirpath, _, filenames in os.walk(ROOT_DIR):
        for filename in filenames:
            # Check if the file has a target extension OR is a target filename
            if filename.endswith(TARGET_EXTENSIONS) or filename.lower() in target_filenames_lower:
                
                file_path = os.path.join(dirpath, filename)
                
                # Create a clean, relative path for the JSON key (e.g., "src/utils/helpers.c")
                # This makes the output portable and independent of the original machine's path
                relative_path = os.path.relpath(file_path, ROOT_DIR).replace('\\', '/')

                # Skip the script itself if it's in the directory
                if relative_path == os.path.basename(__file__):
                    continue
                
                try:
                    # Read the file content. 'errors=ignore' prevents crashes on non-UTF-8 chars.
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                        all_files_data[relative_path] = content
                        print(f"  [+] Added: {relative_path}")
                except Exception as e:
                    print(f"  [!] Error reading {file_path}: {e}")

    # Write the collected data to the JSON file
    try:
        with open(OUTPUT_FILENAME, 'w', encoding='utf-8') as f:
            # 'indent=2' makes the JSON file human-readable
            json.dump(all_files_data, f, indent=2, ensure_ascii=False)
        
        print("-" * 30)
        print(f"\n✅ Success! All data written to '{OUTPUT_FILENAME}'")
        print(f"   Total files packed: {len(all_files_data)}")

    except Exception as e:
        print(f"\n❌ Error writing to JSON file: {e}")


if __name__ == "__main__":
    pack_files_to_json()