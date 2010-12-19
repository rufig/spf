\ libusb 1.0 API wrapper

REQUIRE SO ~ac/lib/ns/so-xt.f
REQUIRE {  lib/ext/locals.f

0
1 -- dev.bLength
1 -- dev.bDescriptorType
2 -- dev.bcdUSB
1 -- dev.bDeviceClass
1 -- dev.bDeviceSubClass
1 -- dev.bDeviceProtocol
1 -- dev.bMaxPacketSize0
2 -- dev.idVendor
2 -- dev.idProduct
2 -- dev.bcdDevice
1 -- dev.iManufacturer
1 -- dev.iProduct
1 -- dev.iSerialNumber
1 -- dev.bNumConfigurations
CONSTANT /device_descriptor

ALSO SO NEW: libusb-1.0.dll
ALSO SO NEW: libusb-1.0.so.0

: TEST { \ ctx devlist }
  ^ ctx 1 libusb_init THROW
  ^ devlist ctx 2 libusb_get_device_list
  0 ?DO
    ." device_" I 1+ . ." : "
    PAD devlist I CELLS + @ 2 libusb_get_device_descriptor THROW
    PAD dev.idVendor W@ .
    PAD dev.idProduct W@ . CR
  LOOP
  1 devlist 2 libusb_free_device_list DROP
  ctx 1 libusb_exit DROP
;

PREVIOUS PREVIOUS

TEST

