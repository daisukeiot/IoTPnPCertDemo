// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// Sample IoT Plug and Play device app for X.509 certificate attestation
// Custom HSM module based on <azure-iot-sdk-c/provisioning_client/sample/custom_hsm_example
//
// Daisuke Nakahara 
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hsm_client_data.h"

static const char* COMMON_NAME;
static const char* CERTIFICATE_FILE = "./new-device.cert.pem";
static const char* CERTIFICATE_KEY = "./new-device.key.pem";
typedef struct CUSTOM_HSM_DATA_TAG
{
    const char* certificate;
    const char* common_name;
    const char* deviceKey;
} CUSTOM_HSM_DATA;

static char *certificate_content = NULL; 
static char *deviceKey_content = NULL; 

int hsm_client_x509_init()
{
    FILE * fp;
    int fileSize; 

    (void)printf("hsm_client_x509_init()\r\n");

    if ((COMMON_NAME = getenv("REGISTRATION_ID")) == NULL)
    {
        printf("Cannot read environment variable=REGISTRATION_ID\r\n");
        return -1;
    }

    if (certificate_content == NULL)
    {
        fp = fopen(CERTIFICATE_FILE, "r");

        if (fp ==NULL)
        {
            (void)printf("%s not found\r\n", CERTIFICATE_FILE);
            return -1;
        }

        fseek(fp, 0L, SEEK_END);
        fileSize = ftell(fp);
        (void)printf("File size %d\r\n", fileSize);
        fseek(fp, 0, SEEK_SET);

        certificate_content = malloc(fileSize + 1);

        if (certificate_content == NULL)
        {
            (void)printf("failed to allocate buffer for %s\r\n", CERTIFICATE_FILE);
            return -1;
        }

        fread(certificate_content, fileSize, 1, fp);
        (void)printf("Certificate :\r\n%s\r\n", certificate_content);

        fclose(fp);
    }

    if (deviceKey_content == NULL)
    {
        fp = fopen(CERTIFICATE_KEY, "r");

        if (fp ==NULL)
        {
            (void)printf("%s not found\r\n", CERTIFICATE_KEY);
            return -1;
        }

        fseek(fp, 0L, SEEK_END);
        fileSize = ftell(fp);
        fseek(fp, 0, SEEK_SET);

        deviceKey_content = malloc(fileSize + 1);

        if (deviceKey_content == NULL)
        {
            (void)printf("failed to allocate buffer for %s\r\n", CERTIFICATE_KEY);
            return -1;
        }

        fread(deviceKey_content, fileSize, 1, fp);
        (void)printf("Private Key : \r\n%s\r\n", deviceKey_content);

        fclose(fp);
    }

    return 0;
}

void hsm_client_x509_deinit()
{
    (void)printf("hsm_client_x509_deinit()\r\n");

    if (certificate_content != NULL)
    {
        free(certificate_content);
        certificate_content = NULL;
    }

    if (deviceKey_content != NULL)
    {
        free(deviceKey_content);
        deviceKey_content = NULL;
    }
}


HSM_CLIENT_HANDLE custom_hsm_create()
{
    HSM_CLIENT_HANDLE result;
    CUSTOM_HSM_DATA* hsm_info = malloc(sizeof(CUSTOM_HSM_DATA));
    
    (void)printf("custom_hsm_create()\r\n");

    if (hsm_info == NULL)
    {
        (void)printf("Failued allocating hsm info\r\n");
        result = NULL;
    }
    else
    {
        hsm_info->certificate = certificate_content;
        hsm_info->deviceKey = deviceKey_content;
        hsm_info->common_name = COMMON_NAME;
        result = hsm_info;
    }
    return result;
}

void custom_hsm_destroy(HSM_CLIENT_HANDLE handle)
{
    (void)printf("custom_hsm_destroy()\r\n");

    if (handle != NULL)
    {
        CUSTOM_HSM_DATA* hsm_info = (CUSTOM_HSM_DATA*)handle;
        // Free anything that has been allocated in this module
        free(hsm_info);
    }
}

char* custom_hsm_get_certificate(HSM_CLIENT_HANDLE handle)
{
    char* result = NULL;

    (void)printf("custom_hsm_get_certificate()\r\n");
    if (handle == NULL)
    {
        (void)printf("Invalid handle value specified\r\n");
        result = NULL;
    }
    else
    {
        // TODO: Malloc the certificate for the iothub sdk to free
        // this value will be sent unmodified to the tlsio
        // layer to be processed
        CUSTOM_HSM_DATA* hsm_info = (CUSTOM_HSM_DATA*)handle;
        size_t len = strlen(hsm_info->certificate);
        if ((result = (char*)malloc(len + 1)) == NULL)
        {
            (void)printf("Failure allocating certificate\r\n");
            result = NULL;
        }
        else
        {
            strcpy(result, hsm_info->certificate);
        }
    }
    return result;
}

char* custom_hsm_get_key(HSM_CLIENT_HANDLE handle)
{
    char* result;

    (void)printf("custom_hsm_get_key()\r\n");
    if (handle == NULL)
    {
        (void)printf("Invalid handle value specified\r\n");
        result = NULL;
    }
    else
    {
        // TODO: Malloc the private deviceKey for the iothub sdk to free
        // this value will be sent unmodified to the tlsio
        // layer to be processed
        CUSTOM_HSM_DATA* hsm_info = (CUSTOM_HSM_DATA*)handle;
        size_t len = strlen(hsm_info->deviceKey);
        if ((result = (char*)malloc(len + 1)) == NULL)
        {
            (void)printf("Failure allocating certificate\r\n");
            result = NULL;
        }
        else
        {
            strcpy(result, hsm_info->deviceKey);
        }
    }
    return result;
}

char* custom_hsm_get_common_name(HSM_CLIENT_HANDLE handle)
{
    char* result;
   if (handle == NULL)
    {
        (void)printf("Invalid handle value specified\r\n");
        result = NULL;
    }
    else
    {
        // TODO: Malloc the common name for the iothub sdk to free
        // this value will be sent to dps
        CUSTOM_HSM_DATA* hsm_info = (CUSTOM_HSM_DATA*)handle;
        size_t len = strlen(hsm_info->common_name);
        if ((result = (char*)malloc(len + 1)) == NULL)
        {
            (void)printf("Failure allocating certificate\r\n");
            result = NULL;
        }
        else
        {
            strcpy(result, hsm_info->common_name);
        }
    }

    (void)printf("custom_hsm_get_common_name() : %s\r\n", result);

    return result;
}


// Defining the v-table for the x509 hsm calls
static const HSM_CLIENT_X509_INTERFACE x509_interface =
{
    custom_hsm_create,
    custom_hsm_destroy,
    custom_hsm_get_certificate,
    custom_hsm_get_key,
    custom_hsm_get_common_name
};

const HSM_CLIENT_X509_INTERFACE* hsm_client_x509_interface()
{
    // x509 interface pointer
    printf("hsm_client_x509_interface()\r\n");
    return &x509_interface;
}

const HSM_CLIENT_TPM_INTERFACE* hsm_client_tpm_interface()
{
    return NULL;
}

int hsm_client_tpm_init()
{
    return 0;
}

void hsm_client_tpm_deinit()
{
    return;
}

const HSM_CLIENT_KEY_INTERFACE* hsm_client_key_interface()
{
    return NULL;
}
