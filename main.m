#include <Foundation/Foundation.h>
#include <IOKit/IOKitLib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	BOOL poll = NO;
	char c;
	while ((c = getopt(argc, argv, "p")) != -1) {
		switch (c) {
			case 'p':
				poll = YES;
			break;
			default:
				return 1;
		}
	}
	
    io_service_t service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"));
    if (!service) return 0;

	do {
		CFMutableDictionaryRef properties = NULL;
		if (IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
			CFNumberRef currentRef = CFDictionaryGetValue(properties, CFSTR("Amperage"));
			CFNumberRef voltageRef = CFDictionaryGetValue(properties, CFSTR("Voltage"));
			int amperage = 0;
			int voltage = 0;

			if (currentRef) CFNumberGetValue(currentRef, kCFNumberIntType, &amperage);
			if (voltageRef) CFNumberGetValue(voltageRef, kCFNumberIntType, &voltage);

			double power_watts = (voltage / 1000.0) * (amperage / 1000.0);

			printf("%.2f W\n", power_watts);

			CFRelease(properties);
		}
		if (poll) {
			sleep(1);
		}
	} while (poll);

    IOObjectRelease(service);
    return 0;
}
