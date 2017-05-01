using System;
using System.Linq;
using Apprenda.SaaSGrid.Addons;

namespace Apprenda.ClientServices.LogStash.AddOn
{
    public class LogstashPublisherAddOn : AddonBase, ILogstashPublisherAddOn
    {
       
        public override ProvisionAddOnResult Provision(AddonProvisionRequest request)
        {
            try
            {
                return new ProvisionAddOnResult(GetUdpListenerUrl(request.Manifest), true, "AddOn successfully provisioned!");
            }
            catch (Exception ex)
            {
                return new ProvisionAddOnResult(null, false, $"AddOn provisioning failed with message {ex.Message}.  StackTrace: {ex.StackTrace}");
            }
        }

        public override OperationResult Deprovision(AddonDeprovisionRequest request)
        {
            return new OperationResult()
            {
                EndUserMessage = "AddOn successfully deprovisioned!",
                IsSuccess = true
            };
        }

        public override OperationResult Test(AddonTestRequest request)
        {
            try
            {
                GetUdpListenerUrl(request.Manifest);
                return new OperationResult()
                {
                    EndUserMessage = "AddOn test was successful!",
                    IsSuccess = true
                };
            }
            catch (Exception ex)
            {
                return new OperationResult() {
                    IsSuccess = false,
                    EndUserMessage = $"AddOn test failed with message {ex.Message}.  StackTrace: {ex.StackTrace}"
                };
            }
        }

        private string GetUdpListenerUrl(AddonManifest manifest)
        {
            var hostname = manifest.Properties.Single(p => p.Key == "hostname").Value;
            var port = manifest.Properties.Single(p => p.Key == "port").Value;
            return $"udp://{hostname}:{port}";
        }
    }
}
