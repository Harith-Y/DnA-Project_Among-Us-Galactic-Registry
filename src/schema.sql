-- schema.sql
-- 1. Database Creation
CREATE DATABASE IF NOT EXISTS mini_world_db;
USE mini_world_db;

-- Disable foreign key checks temporarily to allow table creation out of order if necessary
SET FOREIGN_KEY_CHECKS = 0;

-- 2. Table Definitions

-- Table: RoleDetails
-- Fixed `Rank` as it is a reserved keyword
CREATE TABLE RoleDetails (
    Role VARCHAR(50) NOT NULL,
    `Rank` INT NOT NULL,
    BaseSuspicionLevel INT DEFAULT 0,
    PRIMARY KEY (Role)
);

-- Table: TaskBlueprint
CREATE TABLE TaskBlueprint (
    TaskName VARCHAR(100) NOT NULL,
    DifficultyLevel ENUM('Easy', 'Medium', 'Hard') NOT NULL,
    EnergyRequired INT DEFAULT 10,
    IsVisual BOOLEAN DEFAULT FALSE,
    AssignedRole VARCHAR(50),
    PRIMARY KEY (TaskName),
    FOREIGN KEY (AssignedRole) REFERENCES RoleDetails(Role) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Table: SabotageType
-- Fixed `Type` as it is a reserved keyword
CREATE TABLE SabotageType (
    `Type` VARCHAR(50) NOT NULL,
    Severity ENUM('Low', 'Critical', 'Fatal') NOT NULL,
    DefaultFixedByRole VARCHAR(50),
    PRIMARY KEY (`Type`),
    FOREIGN KEY (DefaultFixedByRole) REFERENCES RoleDetails(Role) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Table: Effect
CREATE TABLE Effect (
    EffectID INT AUTO_INCREMENT,
    EffectType VARCHAR(50) NOT NULL,
    Duration INT NOT NULL COMMENT 'Duration in seconds',
    SeverityImpact INT DEFAULT 1,
    PRIMARY KEY (EffectID)
);

-- Table: Device
-- Fixed `Status` as it is a reserved keyword
CREATE TABLE Device (
    DeviceID INT AUTO_INCREMENT,
    DeviceType VARCHAR(50),
    EnergyConsumption INT,
    `Status` ENUM('Active', 'Idle', 'Broken', 'Off') DEFAULT 'Idle',
    LocationX INT NOT NULL,
    LocationY INT NOT NULL,
    PRIMARY KEY (DeviceID)
);

-- Table: Crewmate
-- Note: CurrentMissionID FK is added at the end of the script to resolve circular dependency
-- Fixed `JoinDate` as JOIN is a reserved keyword
CREATE TABLE Crewmate (
    CrewmateID INT AUTO_INCREMENT,
    Name VARCHAR(50) NOT NULL,
    Color VARCHAR(20) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    `JoinDate` DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastActive DATETIME DEFAULT CURRENT_TIMESTAMP,
    SuspicionLevel INT DEFAULT 0 COMMENT 'Derived Attribute',
    HealthStatus ENUM('Alive', 'Dead', 'Ghost') DEFAULT 'Alive',
    CurrentMissionID INT, 
    PRIMARY KEY (CrewmateID),
    FOREIGN KEY (Role) REFERENCES RoleDetails(Role) ON UPDATE CASCADE
);

-- Table: Mission
CREATE TABLE Mission (
    MissionID INT AUTO_INCREMENT,
    MapName VARCHAR(50) NOT NULL,
    StartTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    EndTime DATETIME,
    Duration INT COMMENT 'Derived: Seconds between Start and End',
    Outcome ENUM('InProgress', 'CrewmateWin', 'ImpostorWin', 'Aborted') DEFAULT 'InProgress',
    Region VARCHAR(50),
    HostCrewmateID INT,
    PRIMARY KEY (MissionID),
    FOREIGN KEY (HostCrewmateID) REFERENCES Crewmate(CrewmateID) ON DELETE SET NULL
);

-- Table: Task
CREATE TABLE Task (
    TaskID INT AUTO_INCREMENT,
    TaskName VARCHAR(100) NOT NULL,
    LocationX INT,
    LocationY INT,
    PRIMARY KEY (TaskID),
    FOREIGN KEY (TaskName) REFERENCES TaskBlueprint(TaskName) ON UPDATE CASCADE
);

-- Table: MiniTask
-- Weak entity using Composite PK
CREATE TABLE MiniTask (
    TaskID INT NOT NULL,
    StepNumber INT NOT NULL,
    Description TEXT,
    EstimatedTime INT,
    PRIMARY KEY (TaskID, StepNumber),
    FOREIGN KEY (TaskID) REFERENCES Task(TaskID) ON DELETE CASCADE
);

-- Table: Sabotage
-- Fixed `Type` and `Timestamp` as they are reserved keywords
CREATE TABLE Sabotage (
    SabotageID INT AUTO_INCREMENT,
    `Type` VARCHAR(50) NOT NULL,
    TriggeredBy INT,
    LocationX INT,
    LocationY INT,
    TriggerTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    FixedTime DATETIME,
    PRIMARY KEY (SabotageID),
    FOREIGN KEY (`Type`) REFERENCES SabotageType(`Type`) ON UPDATE CASCADE,
    FOREIGN KEY (TriggeredBy) REFERENCES Crewmate(CrewmateID) ON DELETE SET NULL
);

-- Table: SabotageEffect
CREATE TABLE SabotageEffect (
    SabotageID INT NOT NULL,
    EffectID INT NOT NULL,
    PRIMARY KEY (SabotageID, EffectID),
    FOREIGN KEY (SabotageID) REFERENCES Sabotage(SabotageID) ON DELETE CASCADE,
    FOREIGN KEY (EffectID) REFERENCES Effect(EffectID) ON DELETE CASCADE
);

-- Table: Crewmate_Mission_Participation
CREATE TABLE Crewmate_Mission_Participation (
    CrewmateID INT NOT NULL,
    MissionID INT NOT NULL,
    PRIMARY KEY (CrewmateID, MissionID),
    FOREIGN KEY (CrewmateID) REFERENCES Crewmate(CrewmateID) ON DELETE CASCADE,
    FOREIGN KEY (MissionID) REFERENCES Mission(MissionID) ON DELETE CASCADE
);

-- Table: EmergencyMeeting
-- Fixed `Timestamp` as it is a reserved keyword
CREATE TABLE EmergencyMeeting (
    MeetingID INT AUTO_INCREMENT,
    CalledBy INT NOT NULL,
    MissionID INT NOT NULL,
    `Timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
    Reason TEXT,
    Outcome ENUM('Skipped', 'Tie', 'Ejected') DEFAULT 'Skipped',
    PRIMARY KEY (MeetingID),
    FOREIGN KEY (CalledBy) REFERENCES Crewmate(CrewmateID) ON DELETE CASCADE,
    FOREIGN KEY (MissionID) REFERENCES Mission(MissionID) ON DELETE CASCADE
);

-- Table: Accuses
CREATE TABLE Accuses (
    MeetingID INT NOT NULL,
    AccuserCrewmateID INT NOT NULL,
    AccusedCrewmateID INT NOT NULL,
    MissionID INT NOT NULL,
    VoteCount INT DEFAULT 1,
    IsEjected BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (MeetingID, AccuserCrewmateID, AccusedCrewmateID),
    FOREIGN KEY (MeetingID) REFERENCES EmergencyMeeting(MeetingID) ON DELETE CASCADE,
    FOREIGN KEY (AccuserCrewmateID) REFERENCES Crewmate(CrewmateID) ON DELETE CASCADE,
    FOREIGN KEY (AccusedCrewmateID) REFERENCES Crewmate(CrewmateID) ON DELETE CASCADE,
    FOREIGN KEY (MissionID) REFERENCES Mission(MissionID) ON DELETE CASCADE
);

-- Table: CommunicationLog
-- Fixed `Timestamp` as it is a reserved keyword
CREATE TABLE CommunicationLog (
    LogID INT AUTO_INCREMENT,
    FromCrewmate INT,
    ToCrewmate INT,
    ChannelType ENUM('Public', 'Radio', 'Ghost') DEFAULT 'Public',
    `Timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
    MessageContent TEXT,
    PRIMARY KEY (LogID),
    FOREIGN KEY (FromCrewmate) REFERENCES Crewmate(CrewmateID) ON DELETE SET NULL,
    FOREIGN KEY (ToCrewmate) REFERENCES Crewmate(CrewmateID) ON DELETE SET NULL
);

-- Table: MissionSummary
-- Fixed `Note` and `Timestamp` as they are reserved keywords
CREATE TABLE MissionSummary (
    MissionID INT,
    EntryNo INT NOT NULL,
    `Note` TEXT,
    LoggedBy INT,
    `Timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (MissionID, EntryNo),
    FOREIGN KEY (MissionID) REFERENCES Mission(MissionID) ON DELETE CASCADE,
    FOREIGN KEY (LoggedBy) REFERENCES Crewmate(CrewmateID) ON DELETE SET NULL
);

-- Table: Heals
-- Fixed `Timestamp` as it is a reserved keyword
CREATE TABLE Heals (
    HealerID INT NOT NULL,
    TargetID INT NOT NULL,
    AmountHealed INT,
    `Timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (HealerID, TargetID, `Timestamp`),
    FOREIGN KEY (HealerID) REFERENCES Crewmate(CrewmateID) ON DELETE CASCADE,
    FOREIGN KEY (TargetID) REFERENCES Crewmate(CrewmateID) ON DELETE CASCADE
);

-- Table: Scans
-- Fixed `Timestamp` as it is a reserved keyword
CREATE TABLE Scans (
    ScannerID INT NOT NULL,
    TargetID INT NOT NULL,
    `Timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
    ScanResult VARCHAR(255),
    PRIMARY KEY (ScannerID, TargetID, `Timestamp`),
    FOREIGN KEY (ScannerID) REFERENCES Crewmate(CrewmateID) ON DELETE CASCADE,
    FOREIGN KEY (TargetID) REFERENCES Crewmate(CrewmateID) ON DELETE CASCADE
);

-- 3. Applying Circular Constraints
ALTER TABLE Crewmate 
ADD CONSTRAINT fk_crewmate_current_mission 
FOREIGN KEY (CurrentMissionID) REFERENCES Mission(MissionID) ON DELETE SET NULL;

-- Re-enable foreign keys
SET FOREIGN_KEY_CHECKS = 1;