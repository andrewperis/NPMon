USE [NPMonitor]
GO

/****** Object:  Table [dbo].[CompanyPackages]    Script Date: 10/17/2019 9:24:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CompanyPackages](
	[CompanyPackageID] [int] IDENTITY(1,1) NOT NULL,
	[NugetPackageID] [int] NOT NULL,
	[CompanyProjectID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[CompanyPackageVersion] [varchar](50) NOT NULL,
	[LastChecked] [datetime] NOT NULL,
 CONSTRAINT [PK_CompanyPackages] PRIMARY KEY CLUSTERED 
(
	[CompanyPackageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CompanyPackages] ADD  CONSTRAINT [DF_CompanyPackages_CompanyID]  DEFAULT ((1)) FOR [CompanyID]
GO

ALTER TABLE [dbo].[CompanyPackages]  WITH CHECK ADD  CONSTRAINT [FK_CompanyPackages_Companies] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Companies] ([CompanyID])
GO

ALTER TABLE [dbo].[CompanyPackages] CHECK CONSTRAINT [FK_CompanyPackages_Companies]
GO

ALTER TABLE [dbo].[CompanyPackages]  WITH CHECK ADD  CONSTRAINT [FK_CompanyPackages_CompanyProjects] FOREIGN KEY([CompanyProjectID])
REFERENCES [dbo].[CompanyProjects] ([CompanyProjectID])
GO

ALTER TABLE [dbo].[CompanyPackages] CHECK CONSTRAINT [FK_CompanyPackages_CompanyProjects]
GO

ALTER TABLE [dbo].[CompanyPackages]  WITH CHECK ADD  CONSTRAINT [FK_CompanyPackages_NugetPackages] FOREIGN KEY([NugetPackageID])
REFERENCES [dbo].[NugetPackages] ([NugetPackageID])
GO

ALTER TABLE [dbo].[CompanyPackages] CHECK CONSTRAINT [FK_CompanyPackages_NugetPackages]
GO


