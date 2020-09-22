# IoTPnPCertDemo

## Setup Dev Environment

1. Install required libraries  

    ```bash
    sudo apt-get update
    sudo apt-get install -y git cmake build-essential curl libcurl4-openssl-dev libssl-dev uuid-dev
    ```
    
1. Clone this rep  

    ```bash
    git clone https://github.com/daisukeiot/IoTPnPCertDemo.git && \
    cd IoTPnPCertDemo
    ```

1. Clone Azure IoT SDK C and generate self signed X.509 certificate  

    ```bash
    ./_prep.sh
    ```

## Create a new project for Azure Certified Device

<https://certify.azure.com/>

1. Select **Connect & test**
1. Select **X.509 certificate** for Authentication Method
1. Select **./cmake/new-device.cert.pem** for X.509 certificate file
1. Edit ./_run.sh  
    - Set DPS_IDSCOPE to the ID Scope provided by the portal
1. Run the app with  

    ```bash
    ./_run/sh
    ```

1. Continue the certification test