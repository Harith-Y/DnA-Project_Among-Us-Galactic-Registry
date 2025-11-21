# src/main_app.py
import sys
from getpass import getpass
from config import DB_HOST, DB_NAME
from db_utils import get_db_connection
from ui_utils import print_header
# Import specific functions from operations module
import operations

def print_menu():
    print("\n" + "=" * 40)
    print("   MINI WORLD INTERFACE (AMONG US)")
    print("=" * 40)
    print(" [R] READ OPERATIONS")
    print("  1. List all crewmates")
    print("  2. Find crewmate details")
    print("  3. List missions")
    print("  4. View mission participants")
    print("  5. View logs")
    print("-" * 40)
    print(" [W] WRITE OPERATIONS")
    print("  6. Add new crewmate")
    print("  7. Update health status")
    print("  8. Delete a task")
    print("-" * 40)
    print("  q. Quit")
    print("=" * 40)

def main_cli(connection):
    while True:
        print_menu()
        choice = input("Select option: ").strip().lower()

        if choice == '1':
            operations.list_all_crewmates(connection)
        elif choice == '2':
            operations.view_crewmate_details(connection)
        elif choice == '3':
            operations.list_missions(connection)
        elif choice == '4':
            operations.list_mission_participants(connection)
        elif choice == '5':
            operations.view_communication_logs(connection)
        elif choice == '6':
            operations.add_new_crewmate(connection)
        elif choice == '7':
            operations.update_crewmate_health(connection)
        elif choice == '8':
            operations.delete_a_task(connection)
        elif choice == 'q':
            print("\nGoodbye.")
            break
        else:
            print("\n[!] Invalid choice.")

if __name__ == "__main__":
    print_header("DB CONNECTION SETUP")
    print(f"Target: {DB_NAME} @ {DB_HOST}")
    
    user = input("MySQL Username: ").strip()
    password = getpass("MySQL Password: ")

    conn = get_db_connection(user, password, DB_HOST, DB_NAME)
    
    if conn:
        try:
            main_cli(conn)
        finally:
            conn.close()
    else:
        sys.exit(1)