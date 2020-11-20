
#
# Script to : 
#  - Clone Azure IoT SDK C
#  - Generate self-signed X.509 certificate and device key (./cmake/new-device.cert.pem and ./cmake/new-device.key.pem)
#  - Compile sample device application for dtmi:com:Example:Thermostat;1
#
# Daisuke Nakahara (daisuken@microsoft.com)
#

print_usage() {
    # HELP_TEXT="Usage:\n" "-f : Force to create new X509 certificates\n" \
    #      "-c : Clean up.  Removes certificates and Azure IoT SDK C\n" \
    #      "-v : Verbose\n" \
    #      "-h : This help menu\n"
    printf '%s\n' "Usage: $0 [-f] [-v] [-h]" \
                  '  -f : Force to create new X509 certificates' \
                  '  -v : Verbose' \
                  '  -h : This help menu'
}

Log() {
    if [ $VERBOSE = true ]; then
        printf "%s\n" "$1"
    fi
}

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

# this becomes Common Name of the certificate
REGISTRATION_ID="${HOSTNAME}"
FOLDER_SDK=${SCRIPTPATH}/azure-iot-sdk-c
FOLDER_CERTIFICATE=${SCRIPTPATH}/certificate
FOLDER_CMAKE=${SCRIPTPATH}/cmake

DAYS=30
ROOT_CA="rootCA"
ROOT_CA_SUBJECT="/C=US/ST=WA/O=TestOrg/OU=TestOu"

FORCE=false
VERBOSE=false
CLEAN=false

while getopts 'cfvh' flag; do
  case "${flag}" in
    c) CLEAN=true ;;
    f) FORCE=true ;;
    v) VERBOSE=true ;;
    h) print_usage
       exit 1 ;;
    *) print_usage
       exit 1 ;;
  esac
done

echo "Force   $FORCE"
echo "Clean   $CLEAN"
echo "Verbose $VERBOSE"

if [ $CLEAN = true ]; then
    for folder in "${FOLDER_SDK}" "${FOLDER_CERTIFICATE}" "${FOLDER_CMAKE}"
    do
        if [ -d "$folder" ]; then
            Log "Removing $folder"
            rm -r -f "$folder"
        fi
    done
fi

# Clone Azure IoT SDK C
if [ ! -d "${FOLDER_SDK}" ]; then
    if [ $VERBOSE = true ]; then
        git clone https://github.com/Azure/azure-iot-sdk-c --recursive
    else
        printf "%s\n" "Cloning Azure IoT SDK C to ${FOLDER_SDK}"
        git clone https://github.com/Azure/azure-iot-sdk-c --recursive --quiet
    fi    
fi

if [ ! -d "${FOLDER_SDK}" ]; then
    printf "ERROR : %s\n" "Azure IoT SDK C not found"
    exit 1;
else
    printf "%s\n" "Azure IoT SDK C found"
fi

if [ $FORCE = true ]; then
    X509_FOUND=false
else
    X509_FOUND=true
    for certFile in "${FOLDER_CMAKE}/${X509_DEVICE_KEY}" "${FOLDER_CMAKE}/${X509_CERTIFICATE}"
    do
        if [ ! -e "$certFile" ]; then
            Log "$certFile not found"
            X509_FOUND=false
            break
        fi
    done
fi

# Create folders
if [ $X509_FOUND = true ] ; then
    printf "%s\n" "X509 certificate found"
else
    if [ ! -d "${FOLDER_CERTIFICATE}" ]; then
        Log "Creating ${FOLDER_CERTIFICATE}"
        mkdir "${FOLDER_CERTIFICATE}"
    fi

    Log "Generating new X509 certificate..."
    cd "${FOLDER_CERTIFICATE}"

    Log "Generating Root CA..."
    openssl genrsa -out ${ROOT_CA}.key.pem 2048 > /dev/null 2>&1
    openssl req -x509 -new -nodes -key ${ROOT_CA}.key.pem -sha256 -days ${DAYS} -out ${ROOT_CA}.cer.pem -extensions "v3_ca" -subj ${ROOT_CA_SUBJECT} > /dev/null 2>&1
    Log "Root CA generated : ${ROOT_CA}.key.pem / ${ROOT_CA}.cer.pem"

    Log "Generating Device Certificate ($REGISTRATION_ID.cer.pem)"
    if [ -e ${REGISTRATION_ID}.key.pem ]; then
        rm -f ${REGISTRATION_ID}.key.pem
    fi
    openssl genrsa -out ${REGISTRATION_ID}.key.pem 2048 > /dev/null 2>&1

    if [ -e ${REGISTRATION_ID}.csr ]; then
        rm ${REGISTRATION_ID}.csr
    fi
    openssl req -new -key ${REGISTRATION_ID}.key.pem -out ${REGISTRATION_ID}.csr.pem -subj "${ROOT_CA_SUBJECT}/CN=${HOSTNAME}" -days 100 -sha256 -extensions v3_ca > /dev/null 2>&1

    if [ -e ${REGISTRATION_ID}.cer.pem ]; then
        rm -f ${REGISTRATION_ID}.cer.pem
    fi
    openssl x509 -req -in ${REGISTRATION_ID}.csr.pem -CA ${ROOT_CA}.cer.pem -CAkey ${ROOT_CA}.key.pem -CAcreateserial -out ${REGISTRATION_ID}.cer.pem -days ${DAYS} -sha256 > /dev/null 2>&1

    printf "%s\n" "Certificate generated ============================" \
                  "${FOLDER_CERTIFICATE}/${REGISTRATION_ID}.key.pem" \
                  "${FOLDER_CERTIFICATE}/${REGISTRATION_ID}.cer.pem"

fi

# Compile the code
if [ ! -d "${FOLDER_CMAKE}" ]; then
    mkdir "${FOLDER_CMAKE}"
fi

cd "${FOLDER_CMAKE}"
cmake .. -Duse_prov_client=ON -Dhsm_type_x509:BOOL=ON -Dhsm_type_symm_key:BOOL=ON -Dhsm_custom_lib=custom_hsm -Dskip_samples:BOOL=OFF -Duse_amqp:BOOL=OFF -Dbuild_service_client:BOOL=OFF -Duse_http=:BOOL=OFF -Duse_amqp=:BOOL=OFF -Dbuild_provisioning_service_client=:BOOL=OFF -Drun_e2e_tests=OFF
cmake --build .

# copy certificate files
cp "${FOLDER_CERTIFICATE}/${REGISTRATION_ID}.key.pem" ${FOLDER_CMAKE}
cp "${FOLDER_CERTIFICATE}/${REGISTRATION_ID}.cer.pem" ${FOLDER_CMAKE}
chmod a+w ${FOLDER_CMAKE}/*.pem

printf "%s\n" "================================================"
# openssl x509 -in ${FOLDER_CERTIFICATE}/new-device.cert.pem -text -noout
printf "%s\n" "Register ${FOLDER_CMAKE}/${REGISTRATION_ID}.cer.pem to Certification Portal"
printf "%s\n" "Registraion ID ${REGISTRATION_ID}"
