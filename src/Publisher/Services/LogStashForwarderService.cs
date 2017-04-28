using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ServiceModel;
using System.Threading;
using Apprenda.ClientServices.LogStash.Publishers;
using Apprenda.SaaSGrid.Extensions.DTO;

namespace Apprenda.ClientServices.LogStash.Services
{
    [ServiceContract(Namespace = ("Apprenda.ClientServices.LogStash.Services"), Name = "ILogStashForwarderService")]
    public interface ILogStashForwarderService
    {
        [OperationContract]
        void OnLogsPersisted(IEnumerable<LogMessageDTO> logs);
    }

    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
    public class LogStashForwarderService : SaaSGrid.Extensions.LogAggregatorExtensionServiceBase, ILogStashForwarderService
    {
        internal static readonly ConcurrentQueue<LogMessageDTO> LogQueue = new ConcurrentQueue<LogMessageDTO>();

        public LogStashForwarderService()
        {
            var publisher = new LogStashUdpPublisher("localhost", 10000);
            var publisherThread = new Thread(publisher.Publish);
            publisherThread.Start();
        }

        // OnLogsPersisted is called from the platform when log forwarding is enabled
        // Push the logs to the thread safe concurrent queue and let the another thread consume the logs.
        // That thread will push them to Logstash
        public override void OnLogsPersisted(IEnumerable<LogMessageDTO> logs)
        {
            foreach (var logObj in logs)
            {
                LogQueue.Enqueue(logObj);
            }
        }
    }
}
