import os
import re

def remove_comments_from_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        # Check if the line is only a comment
        # We match whitespace followed by // or /// and then anything until the end of the line
        if re.match(r'^\s*///?.*$', line):
            continue
        
        # Handle inline comments
        # We want to remove // and everything after it, but only if it's not part of a URL (http://)
        # A simple way is to check if it's preceded by a space or if it's at the end of some code.
        # However, to be safe, let's only remove them if they have at least one space before them
        # and are not part of a URL.
        
        # This regex looks for a space followed by // that is not preceded by :
        # It's not perfect but will handle most cases in Dart.
        # Actually, let's just target the ones that look like AI comments.
        
        # Updated regex: look for // that is preceded by at least one space and not :
        processed_line = re.sub(r'(?<!:)\s//.*$', '', line)
        
        # If the line became empty except for whitespace, and it wasn't empty before, we might want to skip it
        # but let's keep the structure for now unless it was a full line comment.
        
        new_lines.append(processed_line.rstrip() + '\n')

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

def main():
    base_path = r'c:\Users\zakiCode\AndroidStudioProjects\notchnco-task\lib'
    for root, dirs, files in os.walk(base_path):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                print(f"Processing {file_path}")
                remove_comments_from_file(file_path)

if __name__ == '__main__':
    main()
