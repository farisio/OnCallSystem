USE master

IF NOT EXISTS (SELECT * FROM master.dbo.sysdatabases WHERE name = 'OnCallSystem')
BEGIN
    CREATE DATABASE OnCallSystem

END

USE OnCallSystem
CREATE SCHEMA ocs

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name IN ('EventTypes','Titles','JobRoles','users'))    
BEGIN 
    CREATE TABLE ocs.EventTypes (
    EventTypeId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_EventTypeId PRIMARY KEY,
    [Type] varchar(100) NOT NULL CONSTRAINT UN_EventTypes_Type UNIQUE
    )
    
    CREATE TABLE ocs.Locations (
    LocationId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_LocationId PRIMARY KEY,
    LocationName varchar (50) NOT NULL CONSTRAINT UN_Locations_LocationName UNIQUE,
	Active bit NOT NULL CONSTRAINT DF_Locations_Active DEFAULT(0)
    )
    
    CREATE TABLE ocs.Titles (
    TitleId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_TitleId PRIMARY KEY,
    Title varchar(9) NOT NULL CONSTRAINT UN_Titles_Title UNIQUE,
    Editable bit NOT NULL CONSTRAINT DF_Titles_Editable DEFAULT(0),
	Active bit NOT NULL CONSTRAINT DF_Titles_Active DEFAULT(0)
    )
    
    CREATE TABLE ocs.JobRoles (
    JobRoleId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_JobRolesId PRIMARY KEY,
    JobRole varchar(15) NOT NULL CONSTRAINT UN_JobRoles_JobRole UNIQUE,
	Active bit NOT NULL CONSTRAINT DF_JobRoles_Active DEFAULT(0)
    )
    
    CREATE TABLE ocs.Users (
    UserId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_UserId PRIMARY KEY,
    TitleId int NOT NULL CONSTRAINT FK_Users_TitleId REFERENCES ocs.Titles (TitleId),
    JobRoleId int NOT NULL CONSTRAINT FK_Users_JobRoleId REFERENCES ocs.JobRoles (JobRoleId),
    Email varchar(100) NOT NULL CONSTRAINT UN_Users_Email UNIQUE
	Active bit NOT NULL CONSTRAINT DF_Users_Active DEFAULT(0)
    )
    
    CREATE TABLE ocs.[Login] (
    LoginId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_LoginId PRIMARY KEY,
    UserId int NOT NULL CONSTRAINT FK_Login_UserId REFERENCES ocs.Users (userId),
    Active bit NOT NULL CONSTRAINT DF_Login_Active DEFAULT(0),
    ActiveHash varchar(255) NOT NULL,
    RecoverHash varchar(255) NULL,
    Salt varchar(10) NOT NULL  
    )
    
    CREATE TABLE ocs.[Permissions] (
    PermissionId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_PermissionId PRIMARY KEY,
    UserId int NOT NULL CONSTRAINT FK_Permissions_UserId REFERENCES ocs.Users (userId),    
    [Admin] bit NOT NULL CONSTRAINT DF_Permissions_Admin DEFAULT(0),    
    AddUsers bit NOT NULL CONSTRAINT DF_Permissions_AddUsers DEFAULT(0),    
    LogCalls bit NOT NULL CONSTRAINT DF_Permissions_LogCalls DEFAULT(0),
    CloseCalls bit NOT NULL CONSTRAINT DF_Permissions_CloseCalls DEFAULT(0),
    ViewReports bit NOT NULL CONSTRAINT DF_Permissions_ViewReports DEFAULT(0)
    )
    
    CREATE TABLE ocs.Calls (
    CallId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_CallId PRIMARY KEY,
    PatientNameHash varchar(255) NOT NULL,
    AdditionalInformation varchar(max) NULL,
    CallersNameHash varchar(255) NOT NULL,
    LocationId int NOT NULL CONSTRAINT FK_Calls_LocationId REFERENCES ocs.Locations (LocationId) 
    )
    
    CREATE TABLE ocs.AuditLogs (
    AuditLogId int IDENTITY(1,1) NOT NULL CONSTRAINT PK_AuditLogId PRIMARY KEY,
    UserId int NULL CONSTRAINT FK_AuditLogs_UserId REFERENCES ocs.Users (UserId),
    CallId int NULL CONSTRAINT FK_AuditLogs_CallId REFERENCES ocs.Calls (CallId),
    TitleId int NULL CONSTRAINT FK_AuditLogs_TitleId REFERENCES ocs.Titles (TitleId),
    EventTypeId int NULL CONSTRAINT FK_AuditLogs_EventTypeId REFERENCES ocs.EventTypes (EventTypeId),
    PermissionId int NULL CONSTRAINT FK_AuditLogs_PermissionId REFERENCES ocs.[Permissions] (PermissionId)
    )
    
END
