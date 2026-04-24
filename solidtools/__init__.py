# solidtools package initializer
"""Utility scripts for handling encrypted ttl notes.
Provides backup and restore functionality for notepod notes.
"""

from .backup import backup_notepod, restore_notepod

__all__ = ["backup_notepod", "restore_notepod"]
