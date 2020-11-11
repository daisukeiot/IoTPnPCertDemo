#
# Script to : 
#  - Set environment variables
#
# Use ./cmake/new-device.cert.pem to set up X.509 certificate authentication method in the Certification Portal
#
# Daisuke Nakahara (daisuken@microsoft.com)
#
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
FOLDER_CMAKE=${SCRIPTPATH}/cmake

cd "${FOLDER_CMAKE}"
cmake .. -Duse_prov_client=ON -Dhsm_type_x509:BOOL=ON -Dhsm_type_symm_key:BOOL=ON -Dhsm_custom_lib=custom_hsm -Dskip_samples:BOOL=OFF -Duse_amqp:BOOL=OFF -Dbuild_service_client:BOOL=OFF -Duse_http=:BOOL=OFF -Duse_amqp=:BOOL=OFF -Dbuild_provisioning_service_client=:BOOL=OFF -Drun_e2e_tests=OFF
cmake --build .