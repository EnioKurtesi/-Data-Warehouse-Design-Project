if object_id ('Hockey.Fact_table','U') is not null
	drop table Hockey.Fact_table;
go
if object_id('Hockey.SEQ_fact_id','SO') is not null
	drop sequence Hockey.SEQ_fact_id;
go
if object_id ('Hockey.Venue','U') is not null
	drop table Hockey.Venue;
go
if object_id('Hockey.SEQ_venue_id','SO') is not null
	drop sequence Hockey.SEQ_venue_id;
go

if object_id ('Hockey.Home_Team','U') is not null
	drop table Hockey.Home_Team;
go
if object_id('Hockey.SEQ_home_team_id','SO') is not null
	drop sequence Hockey.SEQ_home_team_id;
go

if object_id ('Hockey.Away_Team','U') is not null
	drop table Hockey.Away_Team;
go
if object_id('Hockey.SEQ_away_team_id','SO') is not null
	drop sequence Hockey.SEQ_away_team_id;
go

if object_id ('Hockey.Season','U') is not null
	drop table Hockey.Season;
go
if object_id('Hockey.SEQ_season_id','SO') is not null
	drop sequence Hockey.SEQ_season_id;
go
if object_id ('Hockey.Official','U') is not null
	drop table Hockey.Official;
go
if object_id('Hockey.SEQ_official_id','SO') is not null
	drop sequence Hockey.SEQ_official_id;
go

if object_id ('Hockey.Date_dimension','U') is not null
drop table Hockey.Date_dimension;
go

if schema_id ('Hockey') is not null
	drop schema Hockey;
go
create schema Hockey;
go

create sequence Hockey.SEQ_fact_id as int
start with 1
increment by 1
no cycle
go

create sequence Hockey.SEQ_venue_id as int
start with 1
increment by 1
no cycle
go

create sequence Hockey.SEQ_home_team_id as int
start with 1
increment by 1
no cycle
go
create sequence Hockey.SEQ_away_team_id as int
start with 1
increment by 1
no cycle
go

create sequence Hockey.SEQ_season_id as int
start with 1
increment by 1
no cycle
go

create sequence Hockey.SEQ_official_id as int
start with 1
increment by 1
no cycle
go

create table Hockey.Venue(
	venue_id int not null constraint DFT_Venue_venue_id default(next value for Hockey.SEQ_venue_id),
	venue_name varchar(100) not null,
	coast varchar(20) not null,
	conference varchar(100) not null,
	constraint PK_Venue primary key (venue_id)
)
go

create table Hockey.Home_Team(
	home_team_id int not null constraint DFT_Home_Team_home_team_id default(next value for Hockey.SEQ_home_team_id),
	home_team_nid int not null,
	shortname varchar(70),
	nickname varchar(30),

	constraint PK_Home_Team primary key (home_team_id)
)

create table Hockey.Away_Team(
	away_team_id int not null constraint DFT_Away_Team_away_team_id default(next value for Hockey.SEQ_away_team_id),
	away_team_nid int not null,
	shortname varchar(70),
	nickname varchar(30),

	constraint PK_Away_Team primary key (away_team_id)

)

create table Hockey.Season(
	season_id int not null constraint DFT_Season_season_id default(next value for Hockey.SEQ_season_id),
	years varchar(20) not null,

	constraint PK_Season primary key (season_id)
)

create table Hockey.Official(
	official_id int not null constraint DFT_Official_official_id default(next value for Hockey.SEQ_official_id),
	official_fullname varchar(110) not null,
	official_name varchar(60) not null,
	official_surname varchar(60) not null,

	constraint PK_Official primary key (official_id)
)

IF object_id ('Hockey.Date_dimension','U') is not null
DROP TABLE Hockey.Date_dimension;
GO
CREATE TABLE Hockey.[Date_dimension]
	(	[DateKey] INT primary key, 
		[Date] DATETIME,
		[FullDate] CHAR(10), -- Date in dd-MM-yyyy format
		[DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
		[DayName] VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		[DayOfWeek] CHAR(1),-- First Day Sunday=1 and Saturday=7
		[DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[MonthName] VARCHAR(9),--January, February etc
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[YearName] CHAR(7), --CY 2012,CY 2013
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6),
		[FirstDayOfMonth] DATE,
		[LastDayOfMonth] DATE,
		[FirstDayOfQuarter] DATE,
		[LastDayOfQuarter] DATE,
		[FirstDayOfYear] DATE,
		[LastDayOfYear] DATE,
	)
GO
/********************************************************************************************/
--Specify Start Date and End date here
--Value of Start Date Must be Less than Your End Date 
DECLARE @StartDate DATETIME = '01/01/2000' --Starting value of Date Range
DECLARE @EndDate DATETIME = '01/01/2021' --End Value of Date Range

--Temporary Variables To Hold the Values During Processing of Each Date of Year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

/*Table Data type to store the day of week count for the month and year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

--Extract and assign various parts of Values from Current Date to Variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

/********************************************************************************************/
--Proceed only if Start Date(Current date ) is less than End date you specified above

WHILE @CurrentDate < @EndDate
BEGIN
 
/*Begin day of week logic*/

         /*Check for Change in Month of the Current date if Month changed then 
          Change variable value*/
	IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

        /* Check for Change in Quarter of the Current date if Quarter changed then change 
         Variable value*/

	IF @CurrentQuarter != DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
        /* Check for Change in Year of the Current date if Year changed then change 
         Variable value*/
	

	IF @CurrentYear != DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
        -- Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
/*End day of week logic*/


/* Populate Your Dimension Table with values*/
	
	INSERT INTO Hockey.[Date_dimension]
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) as DateKey,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,101) as FullDate,
		DATEPART(DD, @CurrentDate) AS DayOfMonth,	
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(dw,@CurrentDate+5) % 7 + 1 AS DayOfWeek,	
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR,
		DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR,
		DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0),
		@CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		DATEPART(QQ, @CurrentDate) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(YEAR, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR,
		DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) +
		CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD,
		@CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD,
		(DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1,
		@CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY,
		@CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY,
		@CurrentDate))) AS LastDayOfYear
	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END



create table Hockey.Fact_table(
	fact_id int not null constraint DFT_Fact_table_fact_id default(next value for Hockey.SEQ_fact_id),
	venue_id int,
	home_team_id int,
	away_team_id int,
	season_id int,
	date_id int,
	official_id int,
	home_team_goals int,
	away_team_goals int,
	total_goals int,
	home_team_shoots int,
	away_team_shoots int,
	total_shoots int,
	home_team_hits int,
	away_team_hits int,
	total_hits int,
	home_team_powergoals int,
	away_team_powergoals int,
	total_powergoals int,
	overcome varchar(70),
	home_team_takeaways int,
	away_team_takeaways int,
	total_takeaways int,
	home_team_giveaways int,
	away_team_giveaways int,
	total_giveaways int,
	home_team_blocked int,
	away_team_blocked int,
	total_blocked int,

	constraint PK_Fact_table primary key (fact_id),
	constraint FK_Fact_table_venue_id foreign key (venue_id) references Hockey.Venue (venue_id),
	constraint FK_Fact_table_home_team_id foreign key (home_team_id) references Hockey.Home_Team(home_team_id),
	constraint FK_Fact_table_away_team_id foreign key (away_team_id) references Hockey.Away_Team(away_team_id),
	constraint FK_Fact_table_season_id foreign key (season_id) references Hockey.Season(season_id),
	constraint FK_Fact_table_official_id foreign key (official_id) references Hockey.Official(official_id),
	constraint FK_Fact_table_date_id foreign key (date_id) references Hockey.Date_dimension(DateKey),
)

