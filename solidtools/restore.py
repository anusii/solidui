# restore.py
"""Restore utility for SolidTools.
Publishes markdown files back to a Notepod server folder as encrypted ``.ttl`` files.
"""

import pathlib
import sys
from typing import Optional

try:
    from cryptography.fernet import Fernet, InvalidToken
except ImportError:
    Fernet = None
    InvalidToken = Exception


def _load_key(key_str: str) -> bytes:
    """Validate and return a Fernet key from a string."""
    key_bytes = key_str.encode() if isinstance(key_str, str) else key_str
    if len(key_bytes) != 44:
        raise ValueError("Invalid secret key length for Fernet (must be 44 url‑safe base64 characters).")
    return key_bytes


def _encrypt_markdown(text: str, fernet: Fernet) -> bytes:
    """Encrypt markdown text to binary ``.ttl`` format."""
    return fernet.encrypt(text.encode('utf-8'))


def restore_notepod(md_dir: str, server_path: str, secret_key: str) -> None:
    """Publish markdown files from ``md_dir`` to ``server_path`` as encrypted ``.ttl`` files.

    Parameters
    ----------
    md_dir: str
        Directory containing markdown files produced by the backup tool.
    server_path: str
        Destination Notepod folder on the server.
    secret_key: str
        Fernet secret key used for encryption.
    """
    if Fernet is None:
        raise RuntimeError("cryptography package is required for restore. Install with 'pip install cryptography'.")
    fernet = Fernet(_load_key(secret_key))
    md_path = pathlib.Path(md_dir)
    server_path = pathlib.Path(server_path)
    server_path.mkdir(parents=True, exist_ok=True)

    md_files = list(md_path.rglob('*.md'))
    if not md_files:
        print('No markdown files found in', md_path)
        return

    for md_file in md_files:
        rel = md_file.relative_to(md_path)
        ttl_file = server_path / rel.with_suffix('.ttl')
        ttl_file.parent.mkdir(parents=True, exist_ok=True)
        with md_file.open('r', encoding='utf-8') as f:
            markdown = f.read()
        encrypted = _encrypt_markdown(markdown, fernet)
        with ttl_file.open('wb') as f:
            f.write(encrypted)
        print(f'Restored {md_file} -> {ttl_file}')


def _print_usage():
    print('Usage: python -m solidtools.restore <md_dir> <server_notepod_path> <secret_key>')


if __name__ == '__main__':
    if len(sys.argv) != 4:
        _print_usage()
        sys.exit(1)
    _, md_dir, server_path, secret_key = sys.argv
    restore_notepod(md_dir, server_path, secret_key)
