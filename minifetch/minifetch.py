#!/usr/bin/env python3

import os
import platform
import re
import shutil
import subprocess
import sys
import time
import unicodedata
from pathlib import Path


ANSI_RE = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")


def run(*args):
    """Run a command and return its standard output."""
    try:
        return subprocess.check_output(
            args,
            text=True,
            stderr=subprocess.DEVNULL,
            env={**os.environ, "LC_ALL": "C"},
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return ""


def field(text, name):
    """Extract a field from system_profiler output."""
    match = re.search(
        rf"^\s*{re.escape(name)}:\s*(.+)$",
        text,
        re.MULTILINE,
    )
    return match.group(1).strip() if match else ""


def visible_width(text):
    """Return the approximate number of terminal columns used by text."""
    text = ANSI_RE.sub("", text)

    width = 0

    for character in text:
        if unicodedata.combining(character):
            continue

        category = unicodedata.category(character)

        if category.startswith("C"):
            continue

        if unicodedata.east_asian_width(character) in {"W", "F"}:
            width += 2
        else:
            width += 1

    return width


def format_uptime():
    """Return system uptime in a readable form."""
    boot_info = run("sysctl", "-n", "kern.boottime")
    match = re.search(r"sec\s*=\s*(\d+)", boot_info)

    if not match:
        return "unknown"

    seconds = max(0, int(time.time()) - int(match.group(1)))

    days, seconds = divmod(seconds, 86400)
    hours, seconds = divmod(seconds, 3600)
    minutes = seconds // 60

    parts = []

    if days:
        parts.append(f"{days} day{'s' if days != 1 else ''}")

    if hours or days:
        parts.append(f"{hours} hour{'s' if hours != 1 else ''}")

    parts.append(f"{minutes} min{'s' if minutes != 1 else ''}")

    return ", ".join(parts)


def get_shell():
    """Return the current shell name and version."""
    shell_name = os.path.basename(
        run(
            "ps",
            "-p",
            str(os.getppid()),
            "-o",
            "comm=",
        )
    ).lstrip("-")

    if (
        not shell_name
        or shell_name.startswith("python")
        or shell_name in {"env", "login"}
    ):
        shell_name = os.path.basename(os.environ.get("SHELL", "sh"))

    shell_path = shutil.which(shell_name)

    if not shell_path:
        shell_path = os.environ.get("SHELL", shell_name)

    version_output = run(shell_path, "--version")
    version_match = re.search(r"\d+\.\d+(?:\.\d+)*", version_output)
    version = version_match.group() if version_match else ""

    return f"{shell_name} {version}".strip()


def load_logo():
    """Load logo.txt from the script's directory."""
    logo_path = Path(__file__).resolve().with_name("logo.txt")

    try:
        lines = logo_path.read_text(encoding="utf-8").splitlines()
        return [line.expandtabs(4).rstrip() for line in lines]
    except OSError:
        return []


def get_information():
    """Collect operating-system and hardware information."""
    version = run("sw_vers", "-productVersion")
    build = run("sw_vers", "-buildVersion")
    architecture = platform.machine()

    os_parts = ["macOS"]

    if version:
        os_parts.append(version)

    if build:
        os_parts.append(f"({build})")

    if architecture:
        os_parts.append(architecture)

    hardware = run("system_profiler", "SPHardwareDataType")

    model_name = field(hardware, "Model Name") or "Mac"
    model_identifier = field(hardware, "Model Identifier")

    if model_identifier:
        host = f"{model_name} ({model_identifier})"
    else:
        host = model_name

    chip = (
        field(hardware, "Chip")
        or field(hardware, "Processor Name")
        or run("sysctl", "-n", "machdep.cpu.brand_string")
        or "unknown"
    )

    cores = field(hardware, "Total Number of Cores")

    core_match = re.search(
        r"\((\d+)\s+performance.*?(\d+)\s+efficiency",
        cores,
        re.IGNORECASE,
    )

    if core_match:
        core_information = (
            f" ({core_match.group(1)}+{core_match.group(2)})"
        )
    elif cores:
        total_match = re.search(r"\d+", cores)
        core_information = f" ({total_match.group()})" if total_match else ""
    else:
        core_information = ""

    return [
        ("OS", " ".join(os_parts)),
        ("Kernel", f"{platform.system()} {platform.release()}"),
        ("Uptime", format_uptime()),
        ("Host", host),
        ("CPU", f"{chip}{core_information}"),
        ("Shell", get_shell()),
    ]


def display(logo_lines, information):
    """Print the logo and system information side by side."""
    use_color = sys.stdout.isatty() and "NO_COLOR" not in os.environ

    bold_cyan = "\033[1;36m" if use_color else ""
    reset = "\033[0m" if use_color else ""

    label_width = max(len(label) for label, _ in information)

    information_lines = [
        f"{bold_cyan}{label:<{label_width}}{reset}  {value}"
        for label, value in information
    ]

    if not logo_lines:
        print("\n".join(information_lines))
        return

    logo_width = max(
        (visible_width(line) for line in logo_lines),
        default=0,
    )

    line_count = max(len(logo_lines), len(information_lines))

    for index in range(line_count):
        logo = logo_lines[index] if index < len(logo_lines) else ""
        information_line = (
            information_lines[index]
            if index < len(information_lines)
            else ""
        )

        if information_line:
            padding_width = max(0, logo_width - visible_width(logo))
            padding = " " * padding_width
            print(f"{logo}{padding}   {information_line}")
        else:
            print(logo)


def main():
    display(
        load_logo(),
        get_information(),
    )


if __name__ == "__main__":
    main()
