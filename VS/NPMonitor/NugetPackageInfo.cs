using System;
using System.Globalization;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;


namespace NPMonitor
{
    public class NugetPackageInfo
    {
        [JsonProperty("@context")]
        public Context Context { get; set; }

        [JsonProperty("totalHits")]
        public long TotalHits { get; set; }

        [JsonProperty("lastReopen")]
        public DateTimeOffset LastReopen { get; set; }

        [JsonProperty("index")]
        public string Index { get; set; }

        [JsonProperty("data")]
        public Datum[] Data { get; set; }

        public static NugetPackageInfo FromJson(string json) => JsonConvert.DeserializeObject<NugetPackageInfo>(json, NPMonitor.Converter.Settings);
    }

    public class Context
    {
        [JsonProperty("@vocab")]
        public string Vocab { get; set; }

        [JsonProperty("@base")]
        public string Base { get; set; }
    }

    public class Datum
    {
        [JsonProperty("@id")]
        public string Id { get; set; }

        [JsonProperty("@type")]
        public string Type { get; set; }

        [JsonProperty("registration")]
        public string Registration { get; set; }

        [JsonProperty("id")]
        public string DatumId { get; set; }

        [JsonProperty("version")]
        public string Version { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("summary")]
        public string Summary { get; set; }

        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("iconUrl", NullValueHandling = NullValueHandling.Ignore)]
        public string IconUrl { get; set; }

        [JsonProperty("licenseUrl", NullValueHandling = NullValueHandling.Ignore)]
        public string LicenseUrl { get; set; }

        [JsonProperty("projectUrl", NullValueHandling = NullValueHandling.Ignore)]
        public string ProjectUrl { get; set; }

        [JsonProperty("tags")]
        public string[] Tags { get; set; }

        [JsonProperty("authors")]
        public string[] Authors { get; set; }

        [JsonProperty("totalDownloads")]
        public long TotalDownloads { get; set; }

        [JsonProperty("verified")]
        public bool Verified { get; set; }

        [JsonProperty("versions")]
        public Version[] Versions { get; set; }
    }

    public class Version
    {
        [JsonProperty("version")]
        public string VersionVersion { get; set; }

        [JsonProperty("downloads")]
        public long Downloads { get; set; }

        [JsonProperty("@id")]
        public string Id { get; set; }
    }

    public static class Serialize
    {
        public static string ToJson(this NugetPackageInfo self) => JsonConvert.SerializeObject(self, NPMonitor.Converter.Settings);
    }

    internal static class Converter
    {
        public static readonly JsonSerializerSettings Settings = new JsonSerializerSettings
        {
            MetadataPropertyHandling = MetadataPropertyHandling.Ignore,
            DateParseHandling = DateParseHandling.None,
            Converters = {
                new IsoDateTimeConverter { DateTimeStyles = DateTimeStyles.AssumeUniversal }
            },
        };
    }
}
