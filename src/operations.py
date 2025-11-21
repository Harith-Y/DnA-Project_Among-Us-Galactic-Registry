# src/operations.py
import pymysql
import sys
from ui_utils import print_header, print_table, print_success, print_error, press_enter_to_continue

# --- Read Operations ---

def list_all_crewmates(connection):
    print_header("1. List All Crewmates")
    try:
        with connection.cursor() as cursor:
            sql_query = """
                SELECT CrewmateID, Name, Color, Role, HealthStatus, SuspicionLevel 
                FROM Crewmate
            """
            cursor.execute(sql_query)
            results = cursor.fetchall()
            print_table(results)
    except pymysql.Error as e:
        print_error(e)
    finally:
        press_enter_to_continue()

def view_crewmate_details(connection):
    print_header("2. View Crewmate Details")
    try:
        search_name = input("Enter crewmate name: ").strip()
        if not search_name:
            print_error("Name cannot be empty.")
            return

        with connection.cursor() as cursor:
            sql_query = """
                SELECT c.CrewmateID, c.Name, c.Role, c.HealthStatus, 
                       c.JoinDate, m.MapName AS CurrentLocation
                FROM Crewmate c
                LEFT JOIN Mission m ON c.CurrentMissionID = m.MissionID
                WHERE c.Name = %s
            """
            cursor.execute(sql_query, (search_name,))
            results = cursor.fetchall() # Using fetchall to make it a list for our table printer
            print_table(results)
            
    except pymysql.Error as e:
        print_error(e)
    finally:
        press_enter_to_continue()

def list_missions(connection):
    print_header("3. List Missions")
    try:
        with connection.cursor() as cursor:
            sql_query = """
                SELECT MissionID, MapName, Region, Outcome, 
                       DATE_FORMAT(StartTime, '%Y-%m-%d %H:%i') as StartTime 
                FROM Mission
            """
            cursor.execute(sql_query)
            results = cursor.fetchall()
            print_table(results)
    except pymysql.Error as e:
        print_error(e)
    finally:
        press_enter_to_continue()

def list_mission_participants(connection):
    print_header("4. Mission Participants")
    try:
        mission_id = input("Enter Mission ID: ").strip()
        with connection.cursor() as cursor:
            sql_query = """
                SELECT c.CrewmateID, c.Name, c.Color, c.Role 
                FROM Crewmate c
                JOIN Crewmate_Mission_Participation cmp ON c.CrewmateID = cmp.CrewmateID
                WHERE cmp.MissionID = %s
            """
            cursor.execute(sql_query, (mission_id,))
            results = cursor.fetchall()
            print_table(results)
    except pymysql.Error as e:
        print_error(e)
    finally:
        press_enter_to_continue()

def view_communication_logs(connection):
    print_header("5. Communication Logs")
    try:
        with connection.cursor() as cursor:
            sql_query = """
                SELECT 
                    DATE_FORMAT(l.Timestamp, '%H:%i:%s') as Time,
                    l.ChannelType,
                    IFNULL(c_from.Name, 'Unknown') AS Sender,
                    l.MessageContent
                FROM CommunicationLog l
                LEFT JOIN Crewmate c_from ON l.FromCrewmate = c_from.CrewmateID
                ORDER BY l.Timestamp DESC
            """
            cursor.execute(sql_query)
            results = cursor.fetchall()
            print_table(results)
    except pymysql.Error as e:
        print_error(e)
    finally:
        press_enter_to_continue()

# --- Write Operations ---

def add_new_crewmate(connection):
    print_header("6. Add New Crewmate")
    try:
        name = input("Name: ").strip()
        color = input("Color: ").strip()
        role = input("Role (e.g., Crewmate, Impostor): ").strip()

        with connection.cursor() as cursor:
            sql_query = "INSERT INTO Crewmate (Name, Color, Role) VALUES (%s, %s, %s)"
            cursor.execute(sql_query, (name, color, role))
        
        connection.commit()
        print_success(f"Added crewmate: {name}")
    except pymysql.Error as e:
        connection.rollback()
        print_error(f"Failed to add crewmate: {e}")
    finally:
        press_enter_to_continue()

def update_crewmate_health(connection):
    print_header("7. Update Health Status")
    try:
        c_id = input("Crewmate ID: ").strip()
        status = input("New Status (Alive/Dead/Ghost): ").strip()

        with connection.cursor() as cursor:
            sql_query = "UPDATE Crewmate SET HealthStatus = %s WHERE CrewmateID = %s"
            cursor.execute(sql_query, (status, c_id))
            
            if cursor.rowcount > 0:
                connection.commit()
                print_success(f"Crewmate {c_id} is now {status}.")
            else:
                print_error(f"Crewmate ID {c_id} not found.")
    except pymysql.Error as e:
        connection.rollback()
        print_error(e)
    finally:
        press_enter_to_continue()

def delete_a_task(connection):
    print_header("8. Delete Task")
    try:
        task_id = input("Task ID to delete: ").strip()
        with connection.cursor() as cursor:
            sql_query = "DELETE FROM Task WHERE TaskID = %s"
            cursor.execute(sql_query, (task_id,))
            
            if cursor.rowcount > 0:
                connection.commit()
                print_success(f"Task {task_id} deleted.")
            else:
                print_error(f"Task ID {task_id} not found.")
    except pymysql.Error as e:
        connection.rollback()
        print_error(e)
    finally:
        press_enter_to_continue()