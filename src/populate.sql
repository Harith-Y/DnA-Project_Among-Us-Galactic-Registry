-- populate.sql
USE mini_world_db;

-- 1. Insert RoleDetails (Parent Table)
-- Fixed `Rank`
INSERT INTO RoleDetails (Role, `Rank`, BaseSuspicionLevel) VALUES 
('Crewmate', 1, 0),
('Impostor', 1, 50),
('Engineer', 2, 10),
('Scientist', 3, 5),
('Shapeshifter', 2, 60),
('GuardianAngel', 4, 0);

-- 2. Insert TaskBlueprint (Depends on RoleDetails)
INSERT INTO TaskBlueprint (TaskName, DifficultyLevel, EnergyRequired, IsVisual, AssignedRole) VALUES 
('Fix Wiring', 'Easy', 5, FALSE, 'Crewmate'),
('Prime Shields', 'Medium', 15, TRUE, 'Crewmate'),
('Swipe Card', 'Easy', 2, FALSE, 'Crewmate'),
('Inspect Samples', 'Hard', 30, FALSE, 'Scientist'),
('Clean Vents', 'Medium', 10, FALSE, 'Engineer');

-- 3. Insert SabotageType (Depends on RoleDetails)
-- Fixed `Type`
INSERT INTO SabotageType (`Type`, Severity, DefaultFixedByRole) VALUES 
('Reactor Meltdown', 'Fatal', 'Crewmate'),
('O2 Depletion', 'Fatal', 'Crewmate'),
('Lights Out', 'Critical', 'Engineer'),
('Comms Sabotage', 'Low', 'Scientist');

-- 4. Insert Effect
INSERT INTO Effect (EffectType, Duration, SeverityImpact) VALUES 
('Vision Reduction', 30, 8),
('Panic', 45, 5),
('Suffocation Timer', 60, 10);

-- 5. Insert Device
-- Fixed `Status`
INSERT INTO Device (DeviceType, EnergyConsumption, `Status`, LocationX, LocationY) VALUES 
('Shield Generator', 50, 'Active', 100, 200),
('Admin Table', 10, 'Idle', 50, 50),
('Vitals Monitor', 20, 'Active', 60, 60),
('Reactor Core', 100, 'Active', 10, 10);

-- 6. Insert Crewmate (Role is FK. Mission is NULL initially)
-- Fixed `JoinDate`
INSERT INTO Crewmate (Name, Color, Role, HealthStatus, `JoinDate`) VALUES 
('Red', 'Red', 'Impostor', 'Alive', '2025-11-10 10:00:00'),
('Blue', 'Blue', 'Crewmate', 'Alive', '2025-11-10 10:01:00'),
('Green', 'Green', 'Engineer', 'Alive', '2025-11-10 10:02:00'),
('Pink', 'Pink', 'Scientist', 'Alive', '2025-11-10 10:03:00'),
('Yellow', 'Yellow', 'Crewmate', 'Dead', '2025-11-09 08:00:00');

-- 7. Insert Mission (Depends on HostCrewmateID)
INSERT INTO Mission (MapName, Region, HostCrewmateID, Outcome) VALUES 
('The Skeld', 'NA-East', 2, 'InProgress'), -- Host is Blue
('Mira HQ', 'EU-West', 3, 'ImpostorWin'); -- Host is Green

-- 8. UPDATE Crewmate to link to CurrentMissionID (Resolving Circular Logic)
UPDATE Crewmate SET CurrentMissionID = 1 WHERE Name IN ('Red', 'Blue', 'Green', 'Pink');
UPDATE Crewmate SET CurrentMissionID = 2 WHERE Name = 'Yellow';

-- 9. Insert Crewmate_Mission_Participation
INSERT INTO Crewmate_Mission_Participation (CrewmateID, MissionID) VALUES
(1, 1), (2, 1), (3, 1), (4, 1),
(5, 2);

-- 10. Insert Task (Instances of tasks in a mission)
INSERT INTO Task (TaskName, LocationX, LocationY) VALUES 
('Fix Wiring', 10, 10),
('Prime Shields', 100, 200),
('Inspect Samples', 60, 60),
('Swipe Card', 50, 50);

-- 11. Insert MiniTask (Steps for tasks)
INSERT INTO MiniTask (TaskID, StepNumber, Description, EstimatedTime) VALUES 
(1, 1, 'Connect Red Wire', 5),
(1, 2, 'Connect Blue Wire', 5),
(1, 3, 'Connect Yellow Wire', 5),
(3, 1, 'Wait for anomalies', 60),
(3, 2, 'Select anomaly', 5);

-- 12. Insert Sabotage (Triggered by Impostor Red)
-- Fixed `Type` and `TriggerTime` (I'm now using a specific time)
INSERT INTO Sabotage (`Type`, TriggeredBy, LocationX, LocationY, TriggerTime) VALUES 
('Lights Out', 1, 20, 20, '2025-11-10 11:30:00');

-- 13. Insert SabotageEffect
INSERT INTO SabotageEffect (SabotageID, EffectID) VALUES 
(1, 1); -- Lights Out causes Vision Reduction

-- 14. Insert EmergencyMeeting (Called by Blue in Mission 1)
-- Fixed `Timestamp`
INSERT INTO EmergencyMeeting (CalledBy, MissionID, Reason, Outcome, `Timestamp`) VALUES 
(2, 1, 'Red vented in Electrical', 'Skipped', '2025-11-10 11:35:00');

-- 15. Insert Accuses (Blue accuses Red)
INSERT INTO Accuses (MeetingID, AccuserCrewmateID, AccusedCrewmateID, MissionID, VoteCount, IsEjected) VALUES 
(1, 2, 1, 1, 3, FALSE);

-- 16. Insert CommunicationLog
-- Fixed `Timestamp`
INSERT INTO CommunicationLog (FromCrewmate, ToCrewmate, ChannelType, MessageContent, `Timestamp`) VALUES 
(2, NULL, 'Public', 'I saw Red vent near Electrical!', '2025-11-10 11:35:10'),
(1, NULL, 'Public', 'No way, I was in Medbay scanning.', '2025-11-10 11:35:20'),
(5, NULL, 'Ghost', 'Red definitely killed me.', '2025-11-10 11:35:25');

-- 17. Insert MissionSummary
-- Fixed `Note` and `Timestamp`
INSERT INTO MissionSummary (MissionID, EntryNo, `Note`, LoggedBy, `Timestamp`) VALUES 
(1, 1, 'Mission started successfully. All systems nominal.', 2, '2025-11-10 10:05:00'),
(1, 2, 'Sabotage reported in Electrical.', 3, '2025-11-10 11:30:15');

-- 18. Insert Scans (Scientist Pink scans Blue)
-- Fixed `Timestamp`
INSERT INTO Scans (ScannerID, TargetID, ScanResult, `Timestamp`) VALUES 
(4, 2, 'Normal - No Contamination', '2025-11-10 11:00:00');

-- 19. Insert Heals (Guardian Angel healing logic - Hypothetical based on schema)
-- Fixed `Timestamp`
INSERT INTO Heals (HealerID, TargetID, AmountHealed, `Timestamp`) VALUES 
(5, 2, 10, '2025-11-09 09:00:00');