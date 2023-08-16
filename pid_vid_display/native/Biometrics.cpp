#include <Windows.h>
#include <SetupAPI.h>
#include <devguid.h>
#include <initguid.h>
#include <iostream>
#include <string>

// Define the GUID_DEVINTERFACE_USB_DEVICE manually
DEFINE_GUID(GUID_DEVINTERFACE_USB_DEVICE, 0xA5DCBF10L, 0x6530, 0x11D2, 0x90, 0x1F, 0x00, 0xC0, 0x4F, 0xB9, 0x51, 0xED);

#pragma comment(lib, "Setupapi.lib")

int main() {
    HDEVINFO hDevInfo;
    SP_DEVINFO_DATA devInfoData;
    DWORD deviceIndex = 0;

    // Create a handle to the device information set
    hDevInfo = SetupDiGetClassDevs(&GUID_DEVINTERFACE_USB_DEVICE, 0, 0, DIGCF_DEVICEINTERFACE | DIGCF_PRESENT);

    if (hDevInfo == INVALID_HANDLE_VALUE) {
        std::cerr << "Failed to get device information set." << std::endl;
        return 1;
    }

    // Initialize the SP_DEVINFO_DATA structure
    devInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

    // Enumerate devices and retrieve hardware details
    while (SetupDiEnumDeviceInfo(hDevInfo, deviceIndex, &devInfoData)) {
        WCHAR friendlyName[256] = L"";
        WCHAR manufacturerName[256] = L"";
        WCHAR hardwareID[256] = L"";

        // Retrieve friendly name (if available)
        if (!SetupDiGetDeviceRegistryProperty(hDevInfo, &devInfoData, SPDRP_FRIENDLYNAME, NULL, (PBYTE)friendlyName, sizeof(friendlyName), NULL)) {
            friendlyName[0] = L'\0';
        }

        // Retrieve manufacturer name (if available)
        if (!SetupDiGetDeviceRegistryProperty(hDevInfo, &devInfoData, SPDRP_MFG, NULL, (PBYTE)manufacturerName, sizeof(manufacturerName), NULL)) {
            manufacturerName[0] = L'\0';
        }

        // Retrieve hardware ID (including VID and PID)
        if (!SetupDiGetDeviceRegistryProperty(hDevInfo, &devInfoData, SPDRP_HARDWAREID, NULL, (PBYTE)hardwareID, sizeof(hardwareID), NULL)) {
            hardwareID[0] = L'\0';
        }

        // Extract PID from the hardware ID
        std::wstring hwIdString(hardwareID);
        size_t pidPos = hwIdString.find(L"PID_");
        if (pidPos != std::wstring::npos) {
            std::wstring pidString = hwIdString.substr(pidPos + 4, 4);
            unsigned int pid = std::stoi(pidString, nullptr, 16);
            wprintf(L"PID: %04X\n", pid);
        }
        else {
            wprintf(L"PID: Not found\n");
        }

        // Print the information
        wprintf(L"Device Index: %lu\n", deviceIndex);

        // Use wcsncpy_s for safer string copying
        wcsncpy_s(friendlyName, sizeof(friendlyName) / sizeof(friendlyName[0]), friendlyName, _TRUNCATE);
        wprintf(L"Friendly Name: %s\n", friendlyName);

        wcsncpy_s(manufacturerName, sizeof(manufacturerName) / sizeof(manufacturerName[0]), manufacturerName, _TRUNCATE);
        wprintf(L"Manufacturer: %s\n", manufacturerName);

        wcsncpy_s(hardwareID, sizeof(hardwareID) / sizeof(hardwareID[0]), hardwareID, _TRUNCATE);
        wprintf(L"Hardware ID: %s\n", hardwareID);

        wprintf(L"\n");

        deviceIndex++;
    }

    // Clean up
    SetupDiDestroyDeviceInfoList(hDevInfo);

    return 0;
}
