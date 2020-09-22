SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
REGISTRATION_ID='IoTPnPCertDemo'

# Clone Azure IoT SDK C
if [ ! -d "${SCRIPTPATH}/azure-iot-sdk-c" ]; then
    git clone https://github.com/Azure/azure-iot-sdk-c --recursive
fi

rm -r -f ${SCRIPTPATH}/certificate

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

if [ ! -d "${SCRIPTPATH}/cmake" ]; then
    mkdir cmake
fi

# Copy certificate and private key files (PEM) to cmake folder
cp ${SCRIPTPATH}/certificate/certs/new-device.cert.pem ${SCRIPTPATH}/cmake/
cp ${SCRIPTPATH}/certificate/private/new-device.key.pem ${SCRIPTPATH}/cmake/
chmod a+w ${SCRIPTPATH}/cmake/*.pem

# Overwrite custom_hsm_example.c
cp ${SCRIPTPATH}/custom_hsm/custom_hsm_example.c ${SCRIPTPATH}/azure-iot-sdk-c/provisioning_client/samples/custom_hsm_example/custom_hsm_example.c

# Compile the code
cd "${SCRIPTPATH}/cmake"
cmake .. -Duse_prov_client=ON -Dhsm_type_x509:BOOL=ON -Dhsm_type_symm_key:BOOL=OFF -Dhsm_custom_lib=custom_hsm_example -Dskip_samples:BOOL=OFF -Duse_amqp:BOOL=OFF -Dbuild_service_client:BOOL=OFF -Duse_http=:BOOL=OFF -Duse_amqp=:BOOL=OFF -Dbuild_provisioning_service_client=:BOOL=OFF
cmake --build .
