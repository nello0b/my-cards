"""Create a YPK by copying a template and replacing files.

This script treats .ypk files as ZIP archives (the game's YPK format is ZIP-like).
It copies `Empty Model.ypk`, replaces the `script/` folder contents, replaces the
`custom.cdb` file, adds `test-strings.conf`, and writes the result to `OmegaCustom.ypk`.

Usage: run directly in this folder. Adjust constants below if needed.
"""

from pathlib import Path
import zipfile
import shutil
import sys


TEMPLATE = Path("Empty Model.ypk")
SCRIPT_FOLDER = Path("script")
ART_FOLDER = Path("art")
DB_FILE = Path("Custom-Cards.cdb")
TEST_STRINGS = Path("test-strings.conf")
FINAL_NAME = Path("OmegaCustom.ypk")


def build_ypk(template: Path, output: Path, script_dir: Path, art_dir: Path, db: Path, test_strings: Path):
	if not template.exists():
		raise FileNotFoundError(f"Template not found: {template}")

	# Backup output if it exists
	if output.exists():
		bak = output.with_suffix(output.suffix + ".bak")
		print(f"Backing up existing {output} -> {bak}")
		shutil.move(str(output), str(bak))

	with zipfile.ZipFile(template, 'r') as zin, zipfile.ZipFile(output, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
		# Copy all entries except script/ folder, custom.cdb and test-strings.conf
		for item in zin.infolist():
			name = item.filename
			low = name.lower()
			if low.startswith('script/'):
				continue
			if low.startswith('pics/'):
				continue
			if low == 'custom.cdb':
				continue
			if low == 'test-strings.conf':
				continue
			data = zin.read(name)
			zout.writestr(name, data)

		# Add/replace the DB file as custom.cdb
		if db.exists():
			print(f"Adding {db} as custom.cdb")
			zout.write(str(db), arcname='custom.cdb')
		else:
			print(f"Warning: DB file not found: {db} (skipping)")

		# Add/replace test-strings.conf
		if test_strings.exists():
			print(f"Adding {test_strings}")
			zout.write(str(test_strings), arcname='test-strings.conf')
		else:
			print(f"Warning: test-strings not found: {test_strings} (skipping)")

		# Add all files from script_dir into the script/ folder inside the archive
		if script_dir.exists() and script_dir.is_dir():
			for p in sorted(script_dir.rglob('*')):
				if p.is_file():
					arcname = Path('script') / p.relative_to(script_dir)
					print(f"Adding script file {p} -> {arcname}")
					zout.write(str(p), arcname=str(arcname).replace('\\', '/'))
		else:
			print(f"Warning: script folder not found: {script_dir} (no scripts added)")

		# Add all files from art_dir into the pics/ folder inside the archive
		if art_dir.exists() and art_dir.is_dir():
			for p in sorted(art_dir.rglob('*')):
				if p.is_file():
					arcname = Path('pics') / p.relative_to(art_dir)
					print(f"Adding art file {p} -> {arcname}")
					zout.write(str(p), arcname=str(arcname).replace('\\', '/'))
		else:
			print(f"Warning: art folder not found: {art_dir} (no art added)")


def main():
	try:
		build_ypk(TEMPLATE, FINAL_NAME, SCRIPT_FOLDER, ART_FOLDER, DB_FILE, TEST_STRINGS)
		print(f"Built YPK: {FINAL_NAME}")
	except Exception as e:
		print(f"Error: {e}")
		sys.exit(1)


if __name__ == '__main__':
	main()