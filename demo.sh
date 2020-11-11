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

# Set IoT Plug and Play Model ID
export PNP_MODEL_ID='dtmi:com:Example:Thermostat;1'

# Set ID Scope for DPS
export DPS_IDSCOPE='0ne000FFA42'

# Detemines type of DPS attestation
# set DPS_X509 for X.509
# unset DPS_X509 for Symmetric Key
export DPS_X509=1

cd cmake
./SimpleThermostat
cd ..
