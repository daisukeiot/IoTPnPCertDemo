#
# Script to : 
#  - Set environment variables
#  - REGISTRATION_ID : Subject Name (SN) used to generate X.509 certificate
#  - DPS_IDSCOPE : DPS ID Scope provided by Certification Portal
#  - PNP_MODEL_ID : IoT Plug and Play Digital Twin Model ID
#
# Use ./cmake/new-device.cert.pem to set up X.509 certificate authentication method in the Certification Portal
#
# Daisuke Nakahara (daisuken@microsoft.com)
#
export REGISTRATION_ID="IoTPnPCertDemo"
export DPS_IDSCOPE='0ne000FFA42'
export DPS_X509=1
export PNP_MODEL_ID='dtmi:com:Example:Thermostat;1'

# for Symmetric Key Provisioning (Not used in this sample)
export DPS_REGISTRATIONID=''
export DPS_DEVICEKEY=''

cd cmake
./SimpleThermostat
cd ..