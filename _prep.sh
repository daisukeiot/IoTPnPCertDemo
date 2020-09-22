#
# Script to : 
#  - clone Azure IoT SDK C
#  - Generate self-signed X.509 certificate and device key (./cmake/new-device.cert.pem and ./cmake/new-device.key.pem)
#  - Compile sample device application for dtmi:com:Example:Thermostat;1
#
# Daisuke Nakahara (daisuken@microsoft.com)
#
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

# this becomes SN of the certificate
REGISTRATION_ID='IoTPnPCertDemo'

# Clone Azure IoT SDK C
if [ ! -d "${SCRIPTPATH}/azure-iot-sdk-c" ]; then
    git clone https://github.com/Azure/azure-iot-sdk-c --recursive
fi

if [ ! -d "${SCRIPTPATH}/cmake" ]; then
    mkdir cmake
fi

# Copy scripts to generate a self-signed x.509 certificate
if [ ! -d "${SCRIPTPATH}/certificate" ]; then
    mkdir "${SCRIPTPATH}/certificate"
    cd "${SCRIPTPATH}/certificate"
    cp ${SCRIPTPATH}/azure-iot-sdk-c/tools/CACertificates/*.sh "${SCRIPTPATH}/certificate/"
    cp ${SCRIPTPATH}/azure-iot-sdk-c/tools/CACertificates/*.cnf "${SCRIPTPATH}/certificate/"
    chmod a+x *.sh
    ./certGen.sh create_root_and_intermediate
    ./certGen.sh create_device_certificate ${REGISTRATION_ID}
fi

# Copy certificate and private key files (PEM) to cmake folder
cp ${SCRIPTPATH}/certificate/certs/new-device.cert.pem ${SCRIPTPATH}/cmake/
cp ${SCRIPTPATH}/certificate/private/new-device.key.pem ${SCRIPTPATH}/cmake/
chmod a+w ${SCRIPTPATH}/cmake/*.pem

# Compile the code
cd "${SCRIPTPATH}/cmake"
cmake .. -Duse_prov_client=ON -Dhsm_type_x509:BOOL=ON -Dhsm_type_symm_key:BOOL=OFF -Dhsm_custom_lib=custom_hsm -Dskip_samples:BOOL=ON -Duse_amqp:BOOL=OFF -Dbuild_service_client:BOOL=OFF -Duse_http=:BOOL=OFF -Duse_amqp=:BOOL=OFF -Dbuild_provisioning_service_client=:BOOL=OFF
cmake --build .
