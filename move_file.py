import os
import shutil

source_dir = 'tcg-scripts'
dest_dir = 'example-scripts'
copy_list_file = 'copy.txt'

if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

if not os.path.exists(copy_list_file):
    print(f"Error: {copy_list_file} not found.")
else:
    with open(copy_list_file, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            # Extract the first part of the line (the number)
            parts = line.split()
            if not parts:
                continue
                
            card_id = parts[0]
            filename = f'c{card_id}.lua'
            
            src_path = os.path.join(source_dir, filename)
            dest_path = os.path.join(dest_dir, filename)
            
            if os.path.exists(src_path):
                try:
                    shutil.copy2(src_path, dest_path)
                    print(f'Copied: {filename}')
                except Exception as e:
                    print(f'Error copying {filename}: {e}')
            else:
                print(f'File not found: {src_path}')
