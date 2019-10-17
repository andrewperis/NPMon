using System.IO;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace NPMonitor
{
    public class Program
    {
        private const string EnvironmentVariablePrefix = "NPMON_";

        public static async Task Main(string[] args)
        {
            var host = new HostBuilder()
                .ConfigureHostConfiguration(hostConfig =>
                {
                    hostConfig.SetBasePath(Directory.GetCurrentDirectory());
                    hostConfig.AddJsonFile("hostsettings.json", true);
                    hostConfig.AddEnvironmentVariables(EnvironmentVariablePrefix);
                    hostConfig.AddCommandLine(args);
                })
                .ConfigureAppConfiguration((hostingContext, config) =>
                {
                    config.SetBasePath(hostingContext.HostingEnvironment.ContentRootPath);
                    config.AddJsonFile("appsettings.json", true, true);
                    config.AddJsonFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.json");
                })
                .ConfigureServices((hostingContext, services) =>
                {
                    services.AddLogging();
                    //services.AddHostedService<Worker>();
                    services.AddHostedService<NugetPackageService>();
                    services.AddHttpClient<INugetOrgClient, NugetOrgClient>();
                })
                .ConfigureLogging((hostContext, configLogging) =>
                {
                    configLogging.AddConsole();
                })
                .Build();

            await host.RunAsync();
        }
    }
}
