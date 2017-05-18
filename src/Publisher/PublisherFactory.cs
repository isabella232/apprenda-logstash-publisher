using System;
using Apprenda.ClientServices.LogStash.Publishers;

namespace Apprenda.ClientServices.LogStash
{
    public class PublisherFactory
    {
        public ILogPublisher GetPublisherByAddOnConnection(string addOnConnection)
        {
            var connectionTokens = addOnConnection.Split(new[] { "://" }, StringSplitOptions.None);
            if (connectionTokens.Length == 0)
            {
                connectionTokens = addOnConnection.Split(new[] {@":\\"}, StringSplitOptions.None);
            }
            var protocolString = connectionTokens[0];
            var hostAndPort = connectionTokens[1];
            var hostAndPortTokens = hostAndPort.Split(':');
            var host = hostAndPortTokens[0];
            var port = hostAndPortTokens[1];

            switch (protocolString.ToLower())
            {
                case "tcp":
                    return new LogStashTcpPublisher(host, Convert.ToInt32(port));
                case "udp":
                    return new LogStashUdpPublisher(host, Convert.ToInt32(port));
                case "http":
                    return new LogStashHttpLogPublisher(host, Convert.ToInt32(port), false);
                case "https":
                    return new LogStashHttpLogPublisher(host, Convert.ToInt32(port), true);
                
                default:
                    throw new ArgumentException($"Protocol '{protocolString}' by connection string {addOnConnection} is not a recognized protocol.  Acceptable protocols are tcp, udp and http");
            }
        }
    }
}