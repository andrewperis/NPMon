USE [NPMonitor]
GO

/****** Object:  Table [dbo].[NugetPackages]    Script Date: 10/17/2019 8:48:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[NugetPackages](
	[NugetPackageID] [int] IDENTITY(1,1) NOT NULL,
	[NugetPackageName] [varchar](256) NOT NULL,
	[NugetPackageVersion] [varchar](50) NULL,
	[LastChecked] [datetime] NULL,
 CONSTRAINT [PK_NugetPackages] PRIMARY KEY CLUSTERED 
(
	[NugetPackageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


