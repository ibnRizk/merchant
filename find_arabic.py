import os
import re

def find_arabic_strings(directory):
    arabic_pattern = re.compile(r'[\u0600-\u06FF]+')
    results = []

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    try:
                        lines = f.readlines()
                        for i, line in enumerate(lines):
                            if arabic_pattern.search(line):
                                # Extract string literals containing Arabic
                                strings = re.findall(r'["\']([^"\']*[\u0600-\u06FF]+[^"\']*)["\']', line)
                                if strings:
                                    results.append(f"{filepath}:{i+1} -> {strings}")
                    except Exception as e:
                        pass
    return results

if __name__ == '__main__':
    matches = find_arabic_strings('d:\\project\\ssm_merchant\\lib')
    for match in matches:
        print(match)
