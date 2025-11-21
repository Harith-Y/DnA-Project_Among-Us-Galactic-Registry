# Mini-World Database Project (Phase 4)

This project implements a database for our "Among Us" Mini-World and provides a Python CLI application to interact with it.

## Application Features

The `main_app.py` script provides the following features, listed in the order they appear in the menu.

### Read Operations

- **List all crewmates:**
  - Fetches and displays a summary table of all crewmates currently in the database, showing their ID, Name, Role, and Health Status.

- **Find crewmate details:**
  - Prompts the user for a crewmate's name.
  - Displays a detailed view for that specific crewmate, including their ID, Role, Status, and the Map Name of the mission they are currently in (if any).

- **List missions:**
  - Fetches and displays all missions recorded in the database, showing the Mission ID, Map Name, Region, and current Outcome.

- **View mission participants:**
  - Prompts the user for a Mission ID.
  - Lists all crewmates who are registered as participants in that specific mission.

- **View logs:**
  - Fetches and displays the full CommunicationLog table, showing the time, channel, sender, and message for all in-game communications.

### Write Operations

- **Add new crewmate:**
  - Prompts the user for a new crewmate's Name, Color, and Role.
  - Inserts a new record into the Crewmate table. (Demonstrates INSERT)

- **Update health status:**
  - Prompts the user for a CrewmateID and a new status (Alive, Dead, or Ghost).
  - Updates that crewmate's record. (Demonstrates UPDATE)

- **Delete a task:**
  - Prompts the user for a TaskID.
  - Removes that task from the Task table. (Demonstrates DELETE)

## How to run

1. Create a virtual environment and do :
    ```sh
    pip install pymysql
    ```

2. Run the following :
    ```sh
    mysql -u root -p < src/schema.sql  # to create schema
    mysql -u root -p < src/populate.sql  # to populate data

    python src/main_app.py
    ```
