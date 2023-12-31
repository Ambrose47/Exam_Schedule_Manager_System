USE [master]
GO
/****** Object:  Database [ESMS_v3]    Script Date: 25-Nov-23 9:09:25 AM ******/
CREATE DATABASE [ESMS_v3]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ESMS_v3', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ESMS_v3.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ESMS_v3_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\ESMS_v3_log.ldf' , SIZE = 270336KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [ESMS_v3] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ESMS_v3].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ESMS_v3] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ESMS_v3] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ESMS_v3] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ESMS_v3] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ESMS_v3] SET ARITHABORT OFF 
GO
ALTER DATABASE [ESMS_v3] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ESMS_v3] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ESMS_v3] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ESMS_v3] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ESMS_v3] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ESMS_v3] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ESMS_v3] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ESMS_v3] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ESMS_v3] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ESMS_v3] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ESMS_v3] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ESMS_v3] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ESMS_v3] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ESMS_v3] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ESMS_v3] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ESMS_v3] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ESMS_v3] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ESMS_v3] SET RECOVERY FULL 
GO
ALTER DATABASE [ESMS_v3] SET  MULTI_USER 
GO
ALTER DATABASE [ESMS_v3] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ESMS_v3] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ESMS_v3] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ESMS_v3] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ESMS_v3] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ESMS_v3] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'ESMS_v3', N'ON'
GO
ALTER DATABASE [ESMS_v3] SET QUERY_STORE = ON
GO
ALTER DATABASE [ESMS_v3] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [ESMS_v3]
GO
/****** Object:  UserDefinedFunction [dbo].[GetMigrationString]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[GetMigrationString] (@value as nvarchar(max))
returns nvarchar(max)
as
begin
	return case 
			when @value is null
				then 'null'
			when @value = ''
				then '""'
			else '"' + replace(replace(replace(@value, '"', '""'),'“','""'),'”','""') + '"'
			end
end;
GO
/****** Object:  UserDefinedFunction [dbo].[getuqpkData]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create function [dbo].[getuqpkData] (@tableNamepar nvarchar(MAX))
returns nvarchar(MAX)
as
begin

	--Ref. link: https://www.mssqltips.com/sqlservertip/3443/script-all-primary-keys-unique-constraints-and-foreign-keys-in-a-sql-server-database-using-tsql/
	--Export all PK and unique constraints
	 
	declare @SchemaName varchar(100)
	declare @TableName varchar(256)
	declare @IndexName varchar(256)
	declare @ColumnName varchar(100)
	declare @is_unique_constraint varchar(100)
	declare @IndexTypeDesc varchar(100)
	declare @FileGroupName varchar(100)
	declare @is_disabled varchar(100)
	declare @IndexOptions varchar(max)
	declare @IndexColumnId int
	declare @IsDescendingKey int
	declare @IsIncludedColumn int
	declare @TSQLScripCreationIndex varchar(max)
	declare @TSQLScripDisableIndex varchar(max)
	declare @is_primary_key varchar(100)
	

	--	,('dbo.PatientAssociatePatient')
	--	,('dbo.PatientAssociateType')
	--	,('dbo.PatientAssociateNonRegisteredIdentifier')
	--	,('pds.AddressUid')
	--	,('PDS.PatientFlags')
	declare @data nvarchar(max) = ''

	declare CursorIndex cursor
	for
	select schema_name(t.schema_id) [schema_name]
		,t.name
		,ix.name
		,case 
			when ix.is_unique_constraint = 1
				then ' UNIQUE '
			else ''
			end
		,case 
			when ix.is_primary_key = 1
				then ' PRIMARY KEY '
			else ''
			end
		,ix.type_desc
		,case 
			when ix.is_padded = 1
				then 'PAD_INDEX = ON, '
			else 'PAD_INDEX = OFF, '
			end + case 
			when ix.allow_page_locks = 1
				then 'ALLOW_PAGE_LOCKS = ON, '
			else 'ALLOW_PAGE_LOCKS = OFF, '
			end + case 
			when ix.allow_row_locks = 1
				then 'ALLOW_ROW_LOCKS = ON, '
			else 'ALLOW_ROW_LOCKS = OFF, '
			end + case 
			when INDEXPROPERTY(t.object_id, ix.name, 'IsStatistics') = 1
				then 'STATISTICS_NORECOMPUTE = ON, '
			else 'STATISTICS_NORECOMPUTE = OFF, '
			end + case 
			when ix.ignore_dup_key = 1
				then 'IGNORE_DUP_KEY = ON, '
			else 'IGNORE_DUP_KEY = OFF, '
			end + 'SORT_IN_TEMPDB = OFF, FILLFACTOR =' + CAST(ix.fill_factor as varchar(3)) as IndexOptions
				, case when ix.data_space_id >32767 then '' else FILEGROUP_NAME(ix.data_space_id) end FileGroupName
	from sys.tables t
	inner join sys.indexes ix on t.object_id = ix.object_id
	where ix.type > 0
		and (
			ix.is_primary_key = 1
			or ix.is_unique_constraint = 1
			) --and schema_name(tb.schema_id)= @SchemaName and tb.name=@TableName
		and t.is_ms_shipped = 0
		and t.name <> 'sysdiagrams'
		and (
			schema_name(t.schema_id) + '.' + t.name in (
				select tablename
				from include_table_list
				)
			or (
				select count(1)
				from include_table_list
				) = 0
			) and  schema_name(t.schema_id) + '.' +t.name =@tableNamepar
	order by schema_name(t.schema_id)
		,t.name
		,ix.name

	open CursorIndex

	fetch next
	from CursorIndex
	into @SchemaName
		,@TableName
		,@IndexName
		,@is_unique_constraint
		,@is_primary_key
		,@IndexTypeDesc
		,@IndexOptions
		,@FileGroupName

	while (@@fetch_status = 0)
	begin
		declare @IndexColumns varchar(max)
		declare @IncludedColumns varchar(max)

		set @IndexColumns = ''
		set @IncludedColumns = ''

		declare CursorIndexColumn cursor
		for
		select col.name
			,ixc.is_descending_key
			,ixc.is_included_column
		from sys.tables tb
		inner join sys.indexes ix on tb.object_id = ix.object_id
		inner join sys.index_columns ixc on ix.object_id = ixc.object_id
			and ix.index_id = ixc.index_id
		inner join sys.columns col on ixc.object_id = col.object_id
			and ixc.column_id = col.column_id
		where ix.type > 0
			and (
				ix.is_primary_key = 1
				or ix.is_unique_constraint = 1
				)
			and schema_name(tb.schema_id) = @SchemaName
			and tb.name = @TableName
			and ix.name = @IndexName
			
		order by ixc.index_column_id

		open CursorIndexColumn

		fetch next
		from CursorIndexColumn
		into @ColumnName
			,@IsDescendingKey
			,@IsIncludedColumn

		while (@@fetch_status = 0)
		begin
			if @IsIncludedColumn = 0
				set @IndexColumns = @IndexColumns + lower((
							case @ColumnName
								when 'order'
									then '"order"'
								when 'Default'
									then '"Default"'
								when 'offset'
									then '"offset"'
								else @ColumnName
								end
							)) + ', ' --+ case when @IsDescendingKey=1  then ' DESC, ' else  ' ASC, ' end
			else
				set @IncludedColumns = @IncludedColumns + lower((
							case @ColumnName
								when 'order'
									then '"order"'
								when 'Default'
									then '"Default"'
								when 'offset'
									then '"offset"'
								else @ColumnName
								end
							)) + ', '

			fetch next
			from CursorIndexColumn
			into @ColumnName
				,@IsDescendingKey
				,@IsIncludedColumn
		end

		close CursorIndexColumn

		deallocate CursorIndexColumn

		set @IndexColumns = substring(@IndexColumns, 1, len(@IndexColumns) - 1)
		set @IncludedColumns = case 
				when len(@IncludedColumns) > 0
					then substring(@IncludedColumns, 1, len(@IncludedColumns) - 1)
				else ''
				end
		--  print @IndexColumns
		--  print @IncludedColumns
		set @TSQLScripCreationIndex = ''
		set @TSQLScripDisableIndex = ''
		set @TSQLScripCreationIndex = ',' + char(13) + char(9) + 'CONSTRAINT ' + replace(replace(lower(replace(replace(replace(replace(@IndexName, 'Registration', 'reg'), 'Patient', 'pat'), 'Additional', 'add'), 'Organisation', '')), 'P_K__', 'pk_'), 'U_Q__', 'uq_') + @is_unique_constraint + @is_primary_key + + '(' + @IndexColumns + ')' + case 
				when len(@IncludedColumns) > 0
					then char(13) + 'INCLUDE (' + @IncludedColumns + ')'
				else ''
				end -- + CHAR(13)+'WITH (' + @IndexOptions+ ') ON ' + QUOTENAME(@FileGroupName) + ';'  
		set @data = @data + replace(lower(@TSQLScripCreationIndex), '__', '_')

		--print 
		--print @TSQLScripDisableIndex
		fetch next
		from CursorIndex
		into @SchemaName
			,@TableName
			,@IndexName
			,@is_unique_constraint
			,@is_primary_key
			,@IndexTypeDesc
			,@IndexOptions
			,@FileGroupName
	end

	close CursorIndex

	deallocate CursorIndex

	--return substring(@data,1,len(@data)-1);
	return @data;
end;
GO
/****** Object:  UserDefinedFunction [dbo].[udf_SpacesForCases]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[udf_SpacesForCases] (@string nvarchar(MAX))
returns nvarchar(MAX)
as
begin
	declare @len int = LEN(@string)
		,@iterator int = 2 --Don't put space to left of first even if it's a capital
		;

	while @iterator <= LEN(@string)
	begin
		if PATINDEX('[ABCDEFGHIJKLMNOPQRSTUVWXYZ]', SUBSTRING(@string, @iterator, 1) COLLATE Latin1_General_CS_AI) <> 0
		begin
			set @string = STUFF(@string, @iterator, 0, '_');
			set @iterator += 1;
		end;

		set @iterator += 1;
	end

	return @string;
end;
GO
/****** Object:  Table [dbo].[admin]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[admin](
	[id] [int] NOT NULL,
	[username] [varchar](50) NOT NULL,
	[password] [varchar](250) NOT NULL,
 CONSTRAINT [pk_admin] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Classroom]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Classroom](
	[Room] [varchar](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Room] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course](
	[id] [varchar](10) NOT NULL,
	[name] [varchar](500) NULL,
	[Hour] [real] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_major]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_major](
	[Major_id] [varchar](10) NOT NULL,
	[Course_id] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Major_id] ASC,
	[Course_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_smemeter]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_smemeter](
	[Course_id] [varchar](10) NOT NULL,
	[Semeter_id] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Course_id] ASC,
	[Semeter_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Course_student]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Course_student](
	[Course_id] [varchar](10) NOT NULL,
	[Student_ID] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Course_id] ASC,
	[Student_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Exam_schedule]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Exam_schedule](
	[id] [varchar](10) NOT NULL,
	[Room_id] [varchar](3) NULL,
	[slot_id] [varchar](10) NULL,
	[lecture_id] [varchar](10) NULL,
	[course_id] [varchar](10) NULL,
	[student_id] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Exam_slot]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Exam_slot](
	[id] [varchar](10) NOT NULL,
	[Date] [varchar](10) NULL,
	[Time] [varchar](11) NULL,
	[Hour] [real] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[include_table_list]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[include_table_list](
	[TableName] [varchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Lecture]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lecture](
	[id] [varchar](10) NOT NULL,
	[Name] [nvarchar](500) NULL,
	[Email] [varchar](250) NULL,
	[Phone] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Major]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Major](
	[id] [varchar](10) NOT NULL,
	[name] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reason]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reason](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[reason] [nvarchar](1000) NULL,
	[lecturerId] [varchar](10) NULL,
	[slotId] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Semeter]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Semeter](
	[id] [varchar](10) NOT NULL,
	[Name] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Student]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Student](
	[id] [varchar](10) NOT NULL,
	[name] [nvarchar](500) NULL,
	[email] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tempQueries]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempQueries](
	[rownum] [bigint] NULL,
	[col1] [nvarchar](376) NULL,
	[col2] [nvarchar](max) NULL,
	[col3] [nvarchar](259) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tempQueriesCopy]    Script Date: 25-Nov-23 9:09:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempQueriesCopy](
	[rownum] [bigint] NULL,
	[col1] [nvarchar](376) NULL,
	[col2] [nvarchar](max) NULL,
	[col3] [nvarchar](259) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Course_major]  WITH CHECK ADD FOREIGN KEY([Course_id])
REFERENCES [dbo].[Course] ([id])
GO
ALTER TABLE [dbo].[Course_major]  WITH CHECK ADD FOREIGN KEY([Major_id])
REFERENCES [dbo].[Major] ([id])
GO
ALTER TABLE [dbo].[Course_smemeter]  WITH CHECK ADD FOREIGN KEY([Course_id])
REFERENCES [dbo].[Course] ([id])
GO
ALTER TABLE [dbo].[Course_smemeter]  WITH CHECK ADD FOREIGN KEY([Semeter_id])
REFERENCES [dbo].[Semeter] ([id])
GO
ALTER TABLE [dbo].[Course_student]  WITH CHECK ADD FOREIGN KEY([Course_id])
REFERENCES [dbo].[Course] ([id])
GO
ALTER TABLE [dbo].[Course_student]  WITH CHECK ADD FOREIGN KEY([Student_ID])
REFERENCES [dbo].[Student] ([id])
GO
ALTER TABLE [dbo].[Exam_schedule]  WITH CHECK ADD  CONSTRAINT [fk_course_student] FOREIGN KEY([course_id], [student_id])
REFERENCES [dbo].[Course_student] ([Course_id], [Student_ID])
GO
ALTER TABLE [dbo].[Exam_schedule] CHECK CONSTRAINT [fk_course_student]
GO
ALTER TABLE [dbo].[Exam_schedule]  WITH CHECK ADD  CONSTRAINT [fk_lecture] FOREIGN KEY([lecture_id])
REFERENCES [dbo].[Lecture] ([id])
GO
ALTER TABLE [dbo].[Exam_schedule] CHECK CONSTRAINT [fk_lecture]
GO
ALTER TABLE [dbo].[Exam_schedule]  WITH CHECK ADD  CONSTRAINT [fk_room] FOREIGN KEY([Room_id])
REFERENCES [dbo].[Classroom] ([Room])
GO
ALTER TABLE [dbo].[Exam_schedule] CHECK CONSTRAINT [fk_room]
GO
ALTER TABLE [dbo].[Exam_schedule]  WITH CHECK ADD  CONSTRAINT [fk_slotid] FOREIGN KEY([slot_id])
REFERENCES [dbo].[Exam_slot] ([id])
GO
ALTER TABLE [dbo].[Exam_schedule] CHECK CONSTRAINT [fk_slotid]
GO
USE [master]
GO
ALTER DATABASE [ESMS_v3] SET  READ_WRITE 
GO

INSERT INTO admin (id, username, password)
VALUES (1, 'conghieu', '$2a$12$/78CnF9snTFrbdXQXKTzNOGJ8GEqKiw22v/qpzjHsiEMCnkVznPG2'),
       (2, 'ambrose', '$2a$12$/78CnF9snTFrbdXQXKTzNOGJ8GEqKiw22v/qpzjHsiEMCnkVznPG2');
