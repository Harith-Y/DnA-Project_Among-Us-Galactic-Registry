# src/ui_utils.py
import sys

def print_header(title):
    """Prints a stylized header."""
    print("\n" + "=" * 60)
    print(f"{title.center(60)}")
    print("=" * 60)

def print_success(msg):
    print(f"\n[SUCCESS] {msg}")

def print_error(msg):
    print(f"\n[ERROR] {msg}", file=sys.stderr)

def press_enter_to_continue():
    input("\nPress Enter to continue...")

def print_table(data):
    """
    Takes a list of dictionaries and prints a formatted ASCII table.
    Dynamically calculates column widths based on data content.
    """
    if not data:
        print("\n(No results found)")
        return

    # 1. Extract headers (keys from the first dictionary)
    headers = list(data[0].keys())

    # 2. Calculate column widths
    col_widths = {header: len(header) for header in headers}
    
    for row in data:
        for header in headers:
            # Convert value to string to measure length, handle None/NULL
            val_str = str(row.get(header, "NULL"))
            col_widths[header] = max(col_widths[header], len(val_str))

    # Add a little padding
    for header in col_widths:
        col_widths[header] += 2

    # 3. Create formatting string (e.g., "{:<10} | {:<20}")
    header_fmt = " | ".join([f"{h:<{col_widths[h]}}" for h in headers])
    separator = "-+-".join(["-" * col_widths[h] for h in headers])
    
    # 4. Print Table
    print("\n" + header_fmt)
    print(separator)

    for row in data:
        row_values = []
        for h in headers:
            val = str(row.get(h, "NULL"))
            row_values.append(f"{val:<{col_widths[h]}}")
        print(" | ".join(row_values))
    print("") # Newline at end