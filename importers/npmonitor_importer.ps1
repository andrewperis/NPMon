<#
.SYNOPSIS
    Name: npmonitor.ps1
    The purpose of this script is to gather and store NuGet package information.

.DESCRIPTION
    The script searches the provided path for packages.json files, correlates extracted nuget package information with
    project, and imports the data into the database.

.PARAMETER Path
    Top-level folder to begin search.

.PARAMETER ConnectionString
    Provides the string to connect to your SQL database. Formatted as "Data Source=<IP:port>;Initial Catalog=NPMonitor;Integrated Security=true;".

.PARAMETER CompanyID
    The ID (integer) assigned to your company in the NPMonitor system.

.NOTES
    Updated: 2019-10-21        Initial version.
    Release Date: 2019-10-21

    Author: Andrew Peris (aperis@telular.com)

.EXAMPLE
    PS> npmonitor.ps1 -Path "C:\Users\username\Documents\GitHub\repo-name\" -ConnectionString "Data Source=myNPMonitorDataSourceAddress; Initial Catalog=NPMonitor; Integrated Security=true; User ID=myUsername; Password=myPassword;" -CompanyID 1
#>

Param([Parameter(Mandatory=$true)][string]$Path,
      [Parameter(Mandatory=$true)][string]$ConnectionString,
      [Parameter(Mandatory=$true)][int]$CompanyID)

# function that connects to an instance of SQL Server / Azure SQL Server and saves the 
# connection object as a global variable for future reuse.
function ConnectToDB {
    param(
        [string]
        $connectionstring
        #[string]
        #$servername,
        #[string]
        #$database,
        #[string]
        #$sqluser,
        #[string]
        #$sqlpassword
    )
    # create connection and save it as global variable
    $global:Connection = New-Object System.Data.SQLClient.SQLConnection
    #$Connection.ConnectionString = "server='$servername';database='$database';trusted_connection=false; user id = '$sqluser'; Password = '$sqlpassword'; integrated security='False'"
    $Connection.ConnectionString = $connectionstring
    $Connection.Open()
    Write-Verbose 'Connection established'
}

# function that executes sql commands against an existing Connection object; the connection
# object is saved by the ConnectToDB function as a global variable.
function ExecuteSqlQuery {
    param(
     
        [string]
        $sqlquery,
        [bool]
        $isreader
    
    )
    
    Begin {
        If (!$Connection) {
            Throw "No connection to the database detected. Run command ConnectToDB first."
        }
        elseif ($Connection.State -eq 'Closed') {
            Write-Verbose 'Connection to the database is closed. Re-opening connection...'
            try {
                # if connection was closed (by an error in the previous script) then try reopen it for this query
                $Connection.Open()
            }
            catch {
                Write-Verbose "Error re-opening connection. Removing connection variable."
                Remove-Variable -Scope Global -Name Connection
                throw "Unable to re-open connection to the database. Please reconnect using the ConnectToDB commandlet. Error is $($_.exception)."
            }
        }
    }
    
    Process {
        $command = $Connection.CreateCommand()
        $command.CommandText = $sqlquery
    
        Write-Verbose "Running SQL query '$sqlquery'"
        try {
            if ($True -eq $isreader)
            {
                $result = $command.ExecuteReader()
            }
            else
            {
                $result = $command.ExecuteNonQuery()
            }
        }
        catch {
            $Connection.Close()
        }
        
        if ($True -eq $isreader)
        {
            $Datatable = New-Object "System.Data.Datatable"
            $Datatable.Load($result)
            return $Datatable
        }
        else
        {
            return $result
        }
    }
    End {
        Write-Verbose "Finished running SQL query."
    }
}

# function that inserts a new CompanyProject record if one does not already exist.
function SafeInsertCompanyProjectSqlQuery {
    param(
     
        [string]
        $tablename,
        [string]
        $companyprojectname
    
    )
    
    $where = "select * from $tablename where CompanyID=$CompanyID and CompanyProjectName='$companyprojectname'"

    $result = ExecuteSqlQuery -sqlquery "$where" -isreader 1

    if ($result.Table.Rows.Count -eq 0)
    {
        # TelularProject doesn't exist, insert it
        $insert = "insert into $tablename (CompanyID, CompanyProjectName) values ($CompanyID, '$companyprojectname')"
        $result = ExecuteSqlQuery -sqlquery "$insert" -isreader 0

        $where = "select * from $tablename where CompanyID=$CompanyID and CompanyProjectName='$companyprojectname'"
        $result = ExecuteSqlQuery -sqlquery "$where" -isreader 1

        Write-Host $result
    }

    return $result
}

# function that inserts a new NugetPackage record if one does not already exist.
function SafeInsertNugetPackageSqlQuery {
    param(
     
        [string]
        $tablename,
        [string]
        $nugetpackagename
    
    )
    
    $where = "select * from $tablename where NugetPackageName='$nugetpackagename'"

    $result = ExecuteSqlQuery -sqlquery "$where" -isreader 1

    if ($result.Table.Rows.Count -eq 0)
    {
        # TelularProject doesn't exist, insert it
        $insert = "insert into $tablename (NugetPackageName) values ('$nugetpackagename')"
        $result = ExecuteSqlQuery -sqlquery "$insert" -isreader 0

        $where = "select * from $tablename where NugetPackageName='$nugetpackagename'"
        $result = ExecuteSqlQuery -sqlquery "$where" -isreader 1

        Write-Host $result
    }

    return $result
}

# function that inserts a new CompanyPackage record if one does not already exist, otherwise
# the existing CompanyPackage record is updated.
function UpdateInsertCompanyPackageSqlQuery {
    param(
     
        [string]
        $tablename,
        [int]
        $nugetpackageid,
        [int]
        $companyprojectid,
        [string]
        $companypackageversion,
        [string]
        $lastchecked
    
    )
    
    $where = "select * from $tablename where CompanyID=$CompanyID and NugetPackageID='$nugetpackageid' and CompanyProjectID='$companyprojectid'"

    $res = (ExecuteSqlQuery -sqlquery "$where" -isreader 1)
    
    if ($res.Table.Rows.Count -eq 0)
    {
        # TelularProject doesn't exist, insert it
        $insert = "insert into $tablename (NugetPackageID, CompanyProjectID, CompanyID, CompanyPackageVersion, LastChecked) values ('$nugetpackageid', '$companyprojectid', $CompanyID, '$companypackageversion', $lastchecked)"
        $result = ExecuteSqlQuery -sqlquery "$insert" -isreader 0
        Write-Host $result
    }
    else
    {
        $update = "update $tablename set CompanyPackageVersion='$companypackageversion', LastChecked=$lastchecked where CompanyID=$CompanyID and NugetPackageID='$nugetpackageid' and CompanyProjectID='$companyprojectid'"
        $result = ExecuteSqlQuery -sqlquery "$update" -isreader 0
        Write-Host $result
    }

    return $result
}

ConnectToDB -connectionstring $ConnectionString
$dt = ExecuteSqlQuery -sqlquery "select * from CompanyPackages where CompanyID='$CompanyID'" -isreader 1

$XMLSearchPath = $Path
$XMLFilename = 'packages.config'
$files = Get-ChildItem -Path $XMLSearchPath -Filter $XMLFilename -Recurse

foreach($file in $files)
{
   $XMLfile = $file.FullName
   Write-Host $XMLfile
   Write-Host $file.Directory.BaseName

   $var = $file.Directory.BaseName
   $result = SafeInsertCompanyProjectSqlQuery -tablename "CompanyProjects" -companyprojectname "$var"
   if ($result.Table.Rows.Count -gt 0)
   {
        $where = "select * from CompanyProjects where CompanyID=$CompanyID and CompanyProjectName='$var'"

        $companyprojectid = (ExecuteSqlQuery -sqlquery "$where" -isreader 1).Table.Rows[0].CompanyProjectID
   }

   [XML] $packageDetails = Get-Content $XMLfile

    foreach($packageDetail in $packageDetails.Packages.Package)
    {
       $pname = $packageDetail.id
       $pversion = $packageDetail.version

       $res = SafeInsertNugetPackageSqlQuery -tablename "NugetPackages" -nugetpackagename "$pname"
       if ($res.Table.Rows.Count -gt 0)
       {
           $whe = "select * from NugetPackages where NugetPackageName='$pname'"
           $res = (ExecuteSqlQuery -sqlquery "$whe" -isreader 1)
           $nugetpackageid = $res.Table.Rows[0].NugetPackageID
       }
              
       $telularpackageid = UpdateInsertCompanyPackageSqlQuery -tablename "CompanyPackages" -nugetpackageid $nugetpackageid -companyprojectid $companyprojectid -companypackageversion "$pversion" -lastchecked "GETDATE()"

       Write-Host "name: " $pname
       Write-Host "version: " $pversion
    }
}

$Connection.Close()
Remove-Variable -Scope Global -Name Connection