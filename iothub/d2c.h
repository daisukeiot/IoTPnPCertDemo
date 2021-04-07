// Licensed under the MIT license. See LICENSE file in the project root for full license information.
// Sample IoT Plug and Play device app for X.509 certificate attestation
//
// Daisuke Nakahara 
//
#ifndef _IOTHUB_D2C
#define _IOTHUB_D2C

#include "iothub_op.h"

static const char PnP_TelemetryComponentProperty[] = "$.sub";

bool sendMessage(IOTHUB_DEVICE_CLIENT_LL_HANDLE deviceHandle, char* message, char* componentName);

#endif // _IOTHUB_D2C
