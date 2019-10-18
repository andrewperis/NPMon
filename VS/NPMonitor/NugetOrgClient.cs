using Newtonsoft.Json;
using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;

namespace NPMonitor
{
    public interface INugetOrgClient
    {
#if true
        public Task<NugetPackageInfo> GetNugetPackageByName(string name);
#endif
    }

    public class NugetOrgClient : INugetOrgClient
    {
        private HttpClient _client;
        private const string _baseUrl = "https://api-v2v3search-0.nuget.org/";

        public NugetOrgClient(HttpClient client)
        {
            _client = client;
            _client.BaseAddress = new Uri(_baseUrl);
        }

        public async Task<NugetPackageInfo> GetNugetPackageByName(string name)
        {
            var result = await _client.GetAsync($"query?q={name}");

            if (!result.IsSuccessStatusCode)
                return default(NugetPackageInfo);

            using (var stream = await result.Content.ReadAsStreamAsync())
            using (var sr = new StreamReader(stream))
            using (var jtr = new JsonTextReader(sr))
            {
                var js = new JsonSerializer();
                var res = js.Deserialize<NugetPackageInfo>(jtr);
                return res;// stream.Deserialize<NugetPackageInfo>();
            }
        }
    }
}
