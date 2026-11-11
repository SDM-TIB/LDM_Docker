import argparse, re, subprocess, sys, tempfile, os

def normalize(name):
    return re.sub(r'[-_.]+', '-', name).lower()

def get_names(filename):
    names = set()
    with open(filename) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            name = re.split(r'[><=!; \[]', line)[0]
            names.add(normalize(name))
    return names

def patch_requirements(requirements_file, override_names):
    tmp = tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False)
    with open(requirements_file) as f:
        for line in f:
            stripped = line.strip()
            if stripped and not stripped.startswith('#'):
                name = re.split(r'[><=!; \[]', stripped)[0]
                if normalize(name) in override_names:
                    print(f"  Skipping '{stripped}' (overridden by constraints file)")
                    continue
            tmp.write(line)
    tmp.close()
    return tmp.name

def main():
    parser = argparse.ArgumentParser(
        description='Install requirements, with a constraints file that overrides (rather than just constrains) specific packages.'
    )
    parser.add_argument('-r', dest='requirements', required=True, metavar='requirements.txt',
                        help='Framework requirements file (e.g. requirements1.txt)')
    parser.add_argument('-c', dest='constraints', required=True, metavar='constraints.txt',
                        help='Your requirements file, takes precedence over -r (e.g. requirements2.txt)')
    args = parser.parse_args()

    override_names = get_names(args.constraints)
    patched = patch_requirements(args.requirements, override_names)

    try:
        print(f"\nInstalling patched requirements from '{args.requirements}'...")
        subprocess.run(['ckan-pip', 'install', '--no-cache-dir', '--upgrade', '-r', patched], check=True)
        print(f"\nInstalling overrides from '{args.constraints}'...")
        subprocess.run(['ckan-pip', 'install', '--no-cache-dir', '--upgrade', '-r', args.constraints], check=True)
    finally:
        os.unlink(patched)

if __name__ == '__main__':
    main()
