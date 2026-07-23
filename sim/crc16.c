/* USB CRC-16
 */

#include <stdio.h>
#include <stdint.h>

static uint16_t crc16usb(uint16_t crc, uint8_t data)
{
  uint16_t b;
  uint16_t state = crc;
  int i;

  for (i = 0;  i < 8;  ++i) {
    b = (data ^ state) & 1;
    data >>= 1;
    if (b) {
      state = (state >> 1) ^ 0xa001;
    } else {
      state = (state >> 1);
    }
  }
  return state;
}

int main(int argc, char* argv[])
{
  uint16_t crc;

  crc = 0xffff;
  crc = crc16usb(crc, 0x00);
  crc = crc16usb(crc, 0x01);
  crc = crc16usb(crc, 0x02);
  crc = crc16usb(crc, 0x03);
  crc ^= 0xffff;

  printf("%04x\n", crc);

  crc = 0xffff;
  crc = crc16usb(crc, 0x23);
  crc = crc16usb(crc, 0x45);
  crc = crc16usb(crc, 0x67);
  crc = crc16usb(crc, 0x89);
  crc ^= 0xffff;

  printf("%04x\n", crc);

  return 0;
}
