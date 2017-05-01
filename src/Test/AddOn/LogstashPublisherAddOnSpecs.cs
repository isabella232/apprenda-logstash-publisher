using System;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Serialization;
using Apprenda.ClientServices.LogStash.AddOn;
using Apprenda.SaaSGrid.Addons;
using Machine.Fakes;
using Machine.Specifications;

namespace Apprenda.ClientServices.LogsStash.Tests.AddOn
{
    public class LogstashPublisherAddOnSpecs : WithSubject<LogstashPublisherAddOn>
    {
        [Subject(typeof(LogstashPublisherAddOn))]
        public class When_Testing_an_AddOn
        {
            private static AddonTestRequest _addOnTestRequest;
            private static OperationResult _result;
            private static string _expectedHostname;
            private static int _expectedPort;
            private static string _expectedFormattableString;
            private const string HostNameKey = "hostname";
            private const string UdpPortKey = "udpListenerPort";

            Establish context = () =>
                                {
                                    _expectedHostname = "hostnameTest";
                                    _expectedPort = new Random().Next(1, 5000);
                                    
                                    var manifest = ReadTestManifest(@".\AddonManifest.xml");
                                    manifest.Properties.Single(p => p.Key == HostNameKey).Value = _expectedHostname;
                                    manifest.Properties.Single(p => p.Key == UdpPortKey).Value = _expectedPort.ToString();
                                    _expectedFormattableString = $"udp://{_expectedHostname}:{_expectedPort}";
                                    _addOnTestRequest = new AddonTestRequest { Manifest = manifest };
                                };

            Because of = () => _result = Subject.Test(_addOnTestRequest);

            It should_return_a_friendly_message_that_the_test_was_successful = () => _result.EndUserMessage.ShouldEqual("Addon test was successful!");

            It should_return_success = () => _result.IsSuccess.ShouldBeTrue();
        }

        public class When_Provisioning_an_AddOn
        {
            private static AddonProvisionRequest _addOnProvisionRequest;
            private static ProvisionAddOnResult _result;
            private static string _expectedHostname;
            private static int _expectedPort;
            private static string _expectedFormattableString;
            private const string HostNameKey = "hostname";
            private const string UdpPortKey = "udpListenerPort";

            Establish context = () =>
            {
                _expectedHostname = "hostnameTest";
                _expectedPort = new Random().Next(1, 5000);

                var manifest = ReadTestManifest(@".\AddonManifest.xml");
                manifest.Properties.Single(p => p.Key == HostNameKey).Value = _expectedHostname;
                manifest.Properties.Single(p => p.Key == UdpPortKey).Value = _expectedPort.ToString();
                _expectedFormattableString = $"udp://{_expectedHostname}:{_expectedPort}";
                _addOnProvisionRequest = new AddonProvisionRequest() { Manifest = manifest };
            };

            Because of = () => _result = Subject.Provision(_addOnProvisionRequest);

            It should_return_the_hostname_of_the_logstash_server_in_the_result = () => _result.ConnectionData.ShouldEqual(_expectedFormattableString);

            It should_return_the_port_in_the_result = () => _result.ConnectionData.ShouldEqual(_expectedFormattableString);

            It should_return_a_friendly_success_message_to_the_user = () => _result.EndUserMessage.ShouldEqual("AddOn successfully provisioned!");

            It should_return_success = () => _result.IsSuccess.ShouldBeTrue();
        }
        public class When_Deprovisioning_an_AddOn
        {
            private static AddonDeprovisionRequest _addonDeprovisionRequest;
            private static OperationResult _result;
            private static string _expectedHostname;
            private static int _expectedPort;
            private const string HostNameKey = "hostname";
            private const string UdpPortKey = "udpListenerPort";

            Establish context = () =>
            {
                _expectedHostname = "hostnameTest";
                _expectedPort = new Random().Next(1, 5000);

                var manifest = ReadTestManifest(@".\AddonManifest.xml");
                manifest.Properties.Single(p => p.Key == HostNameKey).Value = _expectedHostname;
                manifest.Properties.Single(p => p.Key == UdpPortKey).Value = _expectedPort.ToString();
                _addonDeprovisionRequest = new AddonDeprovisionRequest() { Manifest = manifest };
            };

            Because of = () => _result = Subject.Deprovision(_addonDeprovisionRequest);

            It should_return_a_friendly_message_that_it_was_deprovisioned_successfully = () => _result.EndUserMessage.ShouldEqual("AddOn successfully deprovisioned!");

            It should_return_success = () => _result.IsSuccess.ShouldBeTrue();
        }



        private static AddonManifest ReadTestManifest(string path)
        {
            var xml = File.ReadAllText(path);
            var sr = new StringReader(xml);
            var xmlReader = new XmlTextReader(sr);
            var serializer = new XmlSerializer(typeof(AddonManifest));
            return serializer.Deserialize(xmlReader) as AddonManifest;
        }
    }
    
}