using System;
using System.Data.SqlClient;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace NPMonitor
{
    public class NugetPackageService : BackgroundService
    {
        private readonly INugetOrgClient _noc;
        private readonly ILogger<Worker> _logger;
        private readonly IHostApplicationLifetime _app;

        public NugetPackageService(INugetOrgClient client, ILogger<Worker> logger, IHostApplicationLifetime appLifetime)
        {
            _noc = client;
            _logger = logger;
            _app = appLifetime;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("NugetPackageService running at: {time}", DateTimeOffset.Now);

                // Query NPMonitor database for NugetPackages
                string connectionString = @"Data Source=np:\\.\pipe\LOCALDB#360FA36A\tsql\query;Initial Catalog=NPMonitor;Integrated Security=true;";// @"np:\\.\pipe\LOCALDB#195DB6A4\tsql\query";
                SqlConnection conn = new SqlConnection(connectionString);
                SqlConnection connInsert = new SqlConnection(connectionString);

                try
                {
                    conn.Open();
                    connInsert.Open();

                    string cmdText = @"SELECT DISTINCT ng.NugetPackageID, ng.NugetPackageName
                                        FROM Companies cp
                                        JOIN CompanyPackages pr ON cp.CompanyID=pr.CompanyID
                                        JOIN NugetPackages ng ON ng.NugetPackageID=pr.NugetPackageID
                                        WHERE cp.CompanyName='Telular AMETEK'
                                        ORDER BY ng.NugetPackageName ASC";
                    
                    using SqlCommand cmdSelectNugetPackages = new SqlCommand(cmdText, conn) { CommandType = System.Data.CommandType.Text };
                    using SqlDataReader rdr = cmdSelectNugetPackages.ExecuteReader();
                        
                    // Iterate through NugetPackages querying for latest version
                    while (rdr.Read())
                    {
                        NugetPackageInfo npi = await _noc.GetNugetPackageByName((string)rdr["NugetPackageName"]);

                        if (npi != null)
                        {
                            UpdateNugetPackageVersion(connInsert, npi, (string)rdr["NugetPackageName"], (int)rdr["NugetPackageID"]);
                        }
                    }
                }
                catch(Exception)
                {
                    _logger.LogError("  Exception opening SQL connection.");
                }
                finally
                {
                    conn.Close();
                    connInsert.Close();
                }

                await Task.Delay(2000, stoppingToken);

                _app.StopApplication();
            }
        }

        private void UpdateNugetPackageVersion(SqlConnection conn, NugetPackageInfo npi, string packageName, int npID)
        {
            string npVersion = String.Empty;

            foreach(Datum d in npi.Data)
            {
                if (d.DatumId == packageName)
                {
                    npVersion = d.Version;
                    break;
                }
            }

            SqlCommand cmdUpdateNugetPackageVersion;
            string cmdText = @"UPDATE NugetPackages SET NugetPackageVersion=@npVersion, LastChecked=GETDATE() WHERE NugetPackageID=@npID";
            using (cmdUpdateNugetPackageVersion = new SqlCommand(cmdText, conn))
            {
                cmdUpdateNugetPackageVersion.Parameters.Add(new SqlParameter("@npVersion", System.Data.SqlDbType.VarChar,50));
                cmdUpdateNugetPackageVersion.Parameters["@npVersion"].Value = npVersion;
                cmdUpdateNugetPackageVersion.Parameters.Add(new SqlParameter("@npID", npID));
                //_logger.LogInformation("  {0}  {1}", packageName, npVersion);
                cmdUpdateNugetPackageVersion.ExecuteNonQuery();
            }
        }
    }
}
