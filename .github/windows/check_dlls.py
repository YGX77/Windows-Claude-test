#!/usr/bin/env python3
"""Fails if a program or library in a Windows install folder imports a DLL that is neither shipped next to it nor part
of Windows itself, which is what makes Windows show "<name>.dll was not found" when the program starts.

Usage: check_dlls.py <bin folder>
"""

import collections
import os
import pathlib
import sys

import pefile


def is_windows_provided(name: str, system_directory: pathlib.Path) -> bool:
    lowered = name.lower()
    # API sets are resolved by the loader itself and have no file.
    if lowered.startswith(("api-ms-win-", "ext-ms-win-")):
        return True
    return (system_directory / name).exists()


def main() -> int:
    root = pathlib.Path(sys.argv[1]).resolve()
    system_directory = pathlib.Path(os.environ.get("SystemRoot", r"C:\Windows")) / "System32"

    shipped_next_to_exe = {path.name.lower() for path in root.iterdir() if path.is_file()}

    modules = sorted(path for path in root.rglob("*") if path.is_file() and path.suffix.lower() in (".exe", ".dll"))
    missing: dict[str, set[str]] = collections.defaultdict(set)

    for module in modules:
        pe = pefile.PE(str(module), fast_load=True)
        pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_IMPORT"]])
        shipped_beside = {path.name.lower() for path in module.parent.iterdir() if path.is_file()}
        for entry in getattr(pe, "DIRECTORY_ENTRY_IMPORT", []):
            name = entry.dll.decode()
            if name.lower() in shipped_next_to_exe or name.lower() in shipped_beside:
                continue
            if is_windows_provided(name, system_directory):
                continue
            missing[name].add(str(module.relative_to(root)))
        pe.close()

    print(f"Checked {len(modules)} programs and libraries in {root}")
    if not missing:
        print("Every imported DLL is shipped or provided by Windows.")
        return 0

    print(f"{len(missing)} imported DLLs are missing:")
    for name, users in sorted(missing.items()):
        print(f"  {name}  (needed by {', '.join(sorted(users)[:3])}{', ...' if len(users) > 3 else ''})")
    return 1


if __name__ == "__main__":
    sys.exit(main())
