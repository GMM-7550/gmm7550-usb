/* USB CRC-5
 *
 * https://electronics.stackexchange.com/questions/718294/how-is-crc5-calculated-in-detail-for-a-usb-token
 * (with modifications to generate data for testbench)
 */

#include <stdio.h>
#include <stdint.h>

static uint8_t crc5usb(uint16_t input)
{
  uint8_t res = 0x1f;
  uint8_t b;
  int i;

  for (i = 0;  i < 11;  ++i) {
    b = (input ^ res) & 1;
    input >>= 1;
    if (b) {
      res = (res >> 1) ^ 0x14;        /* 10100 */
    } else {
      res = (res >> 1);
    }
  }
  return res ^ 0x1f;
}

int main(int argc, char* argv[])
{
  uint16_t data = 0x710;

  for(data=0; data < 0x800; data++) {
    printf("%04x\n", (crc5usb(data)<<11) | data);
  }
  return 0;
}
