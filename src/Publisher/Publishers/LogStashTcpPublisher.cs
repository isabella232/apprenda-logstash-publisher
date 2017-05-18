using System;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Apprenda.ClientServices.LogStash.Services;
using Apprenda.SaaSGrid.Extensions.DTO;
using Newtonsoft.Json;

namespace Apprenda.ClientServices.LogStash.Publishers
{
	public class LogStashTcpPublisher : ILogStashTcpPublisher
	{
		private readonly string _host;
		private readonly int _port;

		public LogStashTcpPublisher(string host, int port)
		{
			_host = host;
			_port = port;
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
							var client = new TcpClient();

							client.Connect(_host, _port);
							var sendBytes = Encoding.Unicode.GetBytes(logMessageJson);

							NetworkStream stream = client.GetStream();

							var data = new Byte[256];

							String responseData = String.Empty;

							stream.Write(sendBytes, 0, sendBytes.Length);

							// Read the first batch of the TcpServer response bytes.
							Int32 bytes = stream.Read(data, 0, data.Length);
							responseData = System.Text.Encoding.ASCII.GetString(data, 0, bytes);
							//client.Send(sendBytes, sendBytes.Length);

							stream.Close();
							client.Close();
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
	}
}
