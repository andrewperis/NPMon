USE [NPMonitor]
GO

/****** Object:  Table [dbo].[CompanyProjects]    Script Date: 10/17/2019 9:23:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CompanyProjects](
	[CompanyProjectID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[CompanyProjectName] [varchar](256) NOT NULL,
 CONSTRAINT [PK_CompanyProjects] PRIMARY KEY CLUSTERED 
(
	[CompanyProjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CompanyProjects] ADD  CONSTRAINT [DF_CompanyProjects_CompanyID]  DEFAULT ((1)) FOR [CompanyID]
GO

ALTER TABLE [dbo].[CompanyProjects]  WITH CHECK ADD  CONSTRAINT [FK_CompanyProjects_Companies] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Companies] ([CompanyID])
GO

ALTER TABLE [dbo].[CompanyProjects] CHECK CONSTRAINT [FK_CompanyProjects_Companies]
GO


