using Apprenda.ClientServices.LogStash;
using Apprenda.ClientServices.LogStash.Publishers;
using Machine.Fakes;
using Machine.Specifications;

namespace Apprenda.ClientServices.LogsStash.Tests
{
    public class PublisherFactorySpecs
    {
        [Subject(typeof(PublisherFactory))]
        public class When_given_an_https_connection : WithSubject<PublisherFactory>
        {
            private static ILogPublisher _result;
            private static string _aValidHttpConnectionString;
            Establish context = () => { _aValidHttpConnectionString = "https://localhost:8080"; };

            Because of = () => { _result = Subject.GetPublisherByAddOnConnection(_aValidHttpConnectionString); };

            It should_return_an_http_log_publisher = () => { _result.ShouldBeOfExactType<LogStashHttpLogPublisher>(); };
        }

        [Subject(typeof(PublisherFactory))]
        public class When_given_an_http_connection : WithSubject<PublisherFactory>
        {
            private static ILogPublisher _result;
            private static string _aValidHttpConnectionString;
            Establish context = () => { _aValidHttpConnectionString = "http://aHost:1234"; };

            Because of = () => { _result = Subject.GetPublisherByAddOnConnection(_aValidHttpConnectionString); };

            It should_return_an_http_log_publisher = () => { _result.ShouldBeOfExactType<LogStashHttpLogPublisher>(); };
        }

        [Subject(typeof(PublisherFactory))]
        public class When_given_a_udp_connection : WithSubject<PublisherFactory>
        {
            private static ILogPublisher _result;
            private static string _aValidUdpConnectionString;
            Establish context = () => { _aValidUdpConnectionString = "udp://aUdpHost:8080"; };

            Because of = () => { _result = Subject.GetPublisherByAddOnConnection(_aValidUdpConnectionString); };

            It should_should_return_an_udp_log_publisher = () => { _result.ShouldBeOfExactType<LogStashUdpPublisher>(); };
        }

        [Subject(typeof(PublisherFactory))]
        public class When_given_a_tcp_connection : WithSubject<PublisherFactory>
        {
            private static ILogPublisher _result;
            private static string _aValidTcpConnectionString;
            Establish context = () => { _aValidTcpConnectionString = "tcp://aTcPHost:8080"; };

            Because of = () => { _result = Subject.GetPublisherByAddOnConnection(_aValidTcpConnectionString); };

            It should_should_return_an_tcp_log_publisher = () => { _result.ShouldBeOfExactType<LogStashTcpPublisher>(); };
        }
    }
}