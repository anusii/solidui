# backup.py
"""Backup utility for SolidTools.
Extracts encrypted .ttl note files from a Notepod server directory,
decrypts them using the provided secret key, and writes them as plain
Markdown files to a local backup directory.

Usage:
    python -m solidtools.backup <server_notepod_path> <backup_dir> <secret_key>
"""

import os
import sys
import pathlib
from typing import Optional

try:
    from cryptography.fernet import Fernet, InvalidToken
except ImportError:
    # cryptography may not be installed; raise a clear error when used.
    Fernet = None
    InvalidToken = Exception


def _load_key(key_str: str) -> bytes:
    """Return a valid Fernet key.
    The key can be a base64 url‑safe string or a raw 32‑byte key.
    """
    if isinstance(key_str, str):
        key_bytes = key_str.encode()
    else:
        key_bytes = key_str
    # Fernet expects a 44‑byte base64‑encoded key.
    if len(key_bytes) != 44:
        raise ValueError("Invalid secret key length for Fernet (must be 44 url‑safe base64 characters).")
    return key_bytes


def _decrypt_ttl(data: bytes, fernet: Fernet) -> str:
    """Decrypt a .ttl file's binary content and return UTF‑8 text.
    If decryption fails, the original data is returned as‑is.
    """
    try:
        return fernet.decrypt(data).decode("utf-8")
    except InvalidToken:
        # Return raw data for debugging; callers may decide to skip.
        return data.decode("utf-8", errors="ignore")


def backup_notepod(server_path: str, backup_dir: str, secret_key: str) -> None:
    """Extract all ``*.ttl`` files from ``server_path`` and write them as ``.md``.

    Parameters
    ----------
    server_path: str
        Path to the Notepod folder on the server containing encrypted ``.ttl`` files.
    backup_dir: str
        Destination directory where markdown files will be created.
    secret_key: str
        The secret key used for Fernet decryption.
    """
    if Fernet is None:
        raise RuntimeError("cryptography package is required for backup. Install with 'pip install cryptography'.")

    fernet = Fernet(_load_key(secret_key))
    server_path = pathlib.Path(server_path)
    backup_path = pathlib.Path(backup_dir)
    backup_path.mkdir(parents=True, exist_ok=True)

    ttl_files = list(server_path.rglob("*.ttl"))
    if not ttl_files:
        print("No .ttl files found in", server_path)
        return

    for ttl_file in ttl_files:
        rel = ttl_file.relative_to(server_path)
        md_file = backup_path / rel.with_suffix('.md')
        md_file.parent.mkdir(parents=True, exist_ok=True)
        with ttl_file.open('rb') as f:
            encrypted = f.read()
        markdown = _decrypt_ttl(encrypted, fernet)
        with md_file.open('w', encoding='utf-8') as f:
            f.write(markdown)
        print(f"Backed up {ttl_file} -> {md_file}")


def _encrypt_markdown(text: str, fernet: Fernet) -> bytes:
    """Encrypt markdown text back to binary ``.ttl`` format."""
    return fernet.encrypt(text.encode('utf-8'))


def restore_notepod(md_dir: str, server_path: str, secret_key: str) -> None:
    """Publish markdown files back to the Notepod server as encrypted ``.ttl`` files.

    Parameters
    ----------
    md_dir: str
        Directory containing markdown files produced by ``backup_notepod``.
    server_path: str
        Destination Notepod folder on the server where encrypted files will be written.
    secret_key: str
        The secret key used for Fernet encryption.
    """
    if Fernet is None:
        raise RuntimeError("cryptography package is required for restore. Install with 'pip install cryptography'.")
    fernet = Fernet(_load_key(secret_key))
    md_path = pathlib.Path(md_dir)
    server_path = pathlib.Path(server_path)
    server_path.mkdir(parents=True, exist_ok=True)

    md_files = list(md_path.rglob("*.md"))
    if not md_files:
        print("No markdown files found in", md_path)
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
        print(f"Restored {md_file} -> {ttl_file}")


def _print_usage():
    print("Usage: python -m solidtools.backup <server_notepod_path> <backup_dir> <secret_key>")
    print("   or: python -m solidtools.restore <md_dir> <server_notepod_path> <secret_key>")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        _print_usage()
        sys.exit(1)
    mode = sys.argv[1].lower()
    if mode == "backup":
        _, _, server, out, key = sys.argv
        backup_notepod(server, out, key)
    elif mode == "restore":
        _, _, md_dir, server, key = sys.argv
        restore_notepod(md_dir, server, key)
    else:
        _print_usage()
        sys.exit(1)
