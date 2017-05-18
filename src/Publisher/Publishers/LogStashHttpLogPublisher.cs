using System;
using System.Diagnostics;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using Apprenda.ClientServices.LogStash.Services;
using Apprenda.SaaSGrid.Extensions.DTO;
using Newtonsoft.Json;

namespace Apprenda.ClientServices.LogStash.Publishers
{
    public class LogStashHttpLogPublisher : ILogPublisher
    {
        private readonly string _host;
        private readonly int _port;
        private readonly bool _isSecure;
        private HttpClient _client;

        public LogStashHttpLogPublisher(string host, int port, bool isSecure = false)
        {
            _host = host;
            _port = port;
            _isSecure = isSecure;
        }

        public void Publish()
        {
            do
            {
                Action pushLogsToLogstash = () =>
                {
                    LogMessageDTO logMessageObj;
                    while (LogStashForwarderService.LogQueue.TryDequeue(out logMessageObj))
                    {
                        try
                        {
                            var logMessageJson = JsonConvert.SerializeObject(logMessageObj);

                            var client = CreateOrGetHttpClient();
                            client.PostAsync("", new StringContent(logMessageJson)).Wait();
                        }
                        catch
                        {
                            // Don't log here you may create an infinite loop.
                        }
                    }
                };

                // Create one push per logical core.
                var actions = new Action[Environment.ProcessorCount];
                for (var coreIndex = 0; coreIndex < Environment.ProcessorCount; coreIndex++)
                    actions[coreIndex] = pushLogsToLogstash;

                Parallel.Invoke(actions);

                // sleep before getting into another iteration of this loop to look for logs
                Thread.Sleep(1000);
            } while (true);
        }

        private HttpClient CreateOrGetHttpClient()
        {
            if (_client == null)
            {
                _client = new HttpClient();
                _client.BaseAddress = new Uri($"http{(_isSecure ? "s" : "" )}://{_host}:{_port}");
                _client.DefaultRequestHeaders.Accept.Clear();
                _client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            }

            return _client;
        }
    }
}