# NPMon
NuGet package version monitor service.

Requirements:
  1. Must store NuGet package names user wishes to monitor.
  2. Must store previous NuGet package version number for each monitored NuGet package.
  3. Must store notification email list.
  4. Must provide deployment scripts that create storage and resources that make up this service.

Nice to haves:
  1. Email SMTP credentials for sending notification emails.

Notes:
  - Example NuGet package information query: https://api-v2v3search-0.nuget.org/query?q=Microsoft.Extensions.Caching.Redis
