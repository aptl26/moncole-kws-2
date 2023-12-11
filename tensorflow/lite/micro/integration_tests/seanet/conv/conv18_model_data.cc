#include <cstdint>

#include "/Users/aghyaddeeb/Documents/Coding/cs249/project/harrison-original/tensorflow/lite/micro/integration_tests/seanet/conv/conv18_model_data.h"

const unsigned int g_conv18_model_data_size = 2304;
alignas(16) const unsigned char g_conv18_model_data[] = {0x18,0x0,0x0,0x0,0x54,0x46,0x4c,0x33,0x0,0x0,0xe,0x0,0x14,0x0,0x10,0x0,0xc,0x0,0x8,0x0,0x0,0x0,0x4,0x0,0xe,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0xcc,0x2,0x0,0x0,0xb8,0x8,0x0,0x0,0x3,0x0,0x0,0x0,0x4,0x0,0x0,0x0,0xb8,0x2,0x0,0x0,0xa4,0x0,0x0,0x0,0xc,0x0,0x0,0x0,0x4,0x0,0x0,0x0,0x5c,0xfd,0xff,0xff,0x72,0xff,0xff,0xff,0x4,0x0,0x0,0x0,0x80,0x0,0x0,0x0,0xdf,0x72,0x0,0x0,0x0,0x0,0x0,0x0,0xf4,0xd2,0xff,0xff,0xff,0xff,0xff,0xff,0xac,0x2a,0x0,0x0,0x0,0x0,0x0,0x0,0xd0,0x2c,0xff,0xff,0xff,0xff,0xff,0xff,0x74,0xe,0x1,0x0,0x0,0x0,0x0,0x0,0xf7,0x44,0x8,0x0,0x0,0x0,0x0,0x0,0x62,0xc3,0xff,0xff,0xff,0xff,0xff,0xff,0x77,0x95,0xfd,0xff,0xff,0xff,0xff,0xff,0xb5,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0xd8,0xee,0xff,0xff,0xff,0xff,0xff,0xff,0xad,0x26,0xff,0xff,0xff,0xff,0xff,0xff,0xbb,0xcf,0x7,0x0,0x0,0x0,0x0,0x0,0xf7,0x5d,0x0,0x0,0x0,0x0,0x0,0x0,0x2,0xc8,0xff,0xff,0xff,0xff,0xff,0xff,0x29,0xc3,0xfa,0xff,0xff,0xff,0xff,0xff,0x4f,0x8b,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x6,0x0,0x8,0x0,0x4,0x0,0x6,0x0,0x0,0x0,0x4,0x0,0x0,0x0,0x0,0x2,0x0,0x0,0x3,0xe9,0x67,0x6,0xc,0x34,0x98,0xe,0xd,0x75,0xbf,0x17,0x64,0xed,0x36,0xc7,0xe8,0x62,0xb0,0xd,0xbf,0x7f,0xc1,0x71,0xab,0xaa,0x82,0x13,0x22,0x9,0xa5,0x7a,0xe7,0x44,0x5,0x14,0x2,0x15,0x7a,0x93,0x1a,0x1,0x3,0x95,0x4,0xeb,0x19,0xef,0xae,0xb,0xd8,0xdc,0xc,0x89,0x4,0x1c,0x2,0x7e,0xb4,0xc8,0xc,0xd4,0xdf,0xb3,0xba,0x18,0xf3,0x1d,0x93,0x2c,0x4f,0x11,0x8,0x80,0x90,0x5e,0x6a,0x6c,0xac,0xbb,0x5,0x18,0x19,0xc,0x9f,0xba,0x26,0x84,0x6f,0xd,0x86,0xaa,0xc4,0x6,0x76,0xd8,0xc0,0x9b,0x5c,0xa,0xb,0x49,0x9d,0x5,0x16,0x88,0x99,0xc,0x56,0xf0,0x2f,0xd4,0xe3,0x53,0x78,0xd,0x96,0xd9,0x7b,0x84,0x51,0x3,0xa3,0xa,0x1a,0x7,0x85,0xa8,0x90,0xb1,0x5c,0xb,0x12,0x31,0x82,0x9,0xa,0x9d,0x8c,0x12,0x4c,0xa0,0x31,0x77,0x74,0x53,0x7a,0xe,0x92,0xe0,0xcf,0x61,0x5b,0x3,0xca,0xf,0x1e,0xa,0xbf,0x84,0xb6,0x51,0x6d,0x6b,0x8,0x94,0x7,0x21,0x8,0x21,0x4,0xd,0x48,0x36,0x9e,0x1d,0x83,0x27,0xf2,0x83,0x40,0x53,0x2c,0x45,0x4c,0x30,0xbf,0x4,0xc1,0xdb,0x15,0x1c,0xbb,0x57,0x11,0x18,0xb,0x15,0xb0,0x51,0x1c,0x1,0x0,0xc9,0x4,0x0,0x1a,0xa2,0xcf,0x8,0xa1,0x76,0x1b,0xb5,0xf7,0x21,0x1e,0x2,0x89,0xb5,0x17,0xf3,0xde,0x8a,0xae,0x5c,0x38,0x21,0x8e,0x49,0x30,0x81,0xca,0xcb,0x2,0xa2,0x34,0x29,0x77,0xd5,0x15,0x2a,0x72,0x1a,0x3,0x22,0xbe,0x8e,0x4e,0x82,0x37,0x79,0x92,0x11,0xb2,0x86,0x76,0x37,0xc,0x3d,0x96,0x9f,0x50,0x3,0x69,0xcb,0xa9,0x6a,0x4,0x76,0x6b,0x86,0x24,0x42,0x62,0x17,0x8a,0x1b,0x1f,0x6a,0x93,0xac,0xe7,0xe6,0x5c,0x17,0x9b,0x89,0xe6,0x45,0x3,0x8,0x6,0x25,0xd7,0x71,0x20,0x5,0x0,0x85,0xb1,0xc7,0x1b,0xce,0xca,0x4,0xa5,0x8e,0xa,0x92,0x7,0x21,0x87,0x1,0xce,0x9b,0x12,0x9a,0x8a,0xbc,0xa,0x40,0x30,0x2c,0x79,0x65,0x4a,0x0,0x7c,0x78,0x4,0xa1,0x2f,0x13,0x7d,0x89,0x36,0x30,0x41,0x15,0xd7,0x49,0xbe,0xb1,0x32,0x89,0x53,0xed,0xcd,0x17,0xcd,0xb4,0xc,0x78,0x2a,0x35,0x9a,0x7a,0x64,0xe,0x81,0x77,0x9,0xac,0x28,0x1b,0x96,0xa0,0x2a,0x2e,0x66,0x19,0x7b,0x58,0xa2,0x9b,0x2b,0x68,0x65,0x81,0x6b,0xc,0x95,0xb0,0x81,0x45,0x7,0xf,0x6,0x15,0xa2,0x5b,0x29,0x3,0x0,0xd6,0x2,0xeb,0x20,0xc7,0xac,0x3,0xcd,0xa8,0x11,0x8b,0xde,0x17,0x11,0x3,0xcf,0xc8,0x1f,0x95,0xa6,0x7f,0xee,0x4a,0xa,0x14,0x6,0x11,0xd0,0x6a,0x1a,0x0,0x0,0xd2,0x6,0xd0,0x28,0xe3,0xf2,0xb,0x78,0x7b,0x1a,0x89,0xd9,0x21,0x15,0x0,0xca,0xc3,0x1e,0xf4,0xc8,0x94,0x19,0x3f,0x28,0x4e,0x90,0x58,0x59,0xe9,0x53,0xc2,0xf,0x8d,0x26,0x18,0x94,0xa8,0x30,0x26,0x37,0x11,0xc1,0x63,0xcc,0x6c,0xc1,0xbb,0x4e,0x91,0xbe,0x13,0x76,0xab,0x9,0x43,0x76,0x12,0x70,0x1c,0x95,0x85,0x15,0x5,0x6,0x77,0x1d,0x7f,0x1,0xe2,0x0,0x16,0x6,0xe,0xb5,0x1d,0x2,0xc7,0x71,0x72,0x8e,0xd5,0x8e,0x3,0xa3,0x9b,0x4,0x0,0x4,0x0,0x4,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x4,0x0,0x0,0x0,0xa0,0xfa,0xff,0xff,0x10,0x0,0x0,0x0,0x6c,0x0,0x0,0x0,0x70,0x0,0x0,0x0,0x74,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x14,0x0,0x0,0x0,0x0,0x0,0xe,0x0,0x16,0x0,0x0,0x0,0x10,0x0,0xc,0x0,0xb,0x0,0x4,0x0,0xe,0x0,0x0,0x0,0x1c,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x24,0x0,0x0,0x0,0x28,0x0,0x0,0x0,0x0,0x0,0xa,0x0,0x10,0x0,0xf,0x0,0x8,0x0,0x4,0x0,0xa,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x1,0x0,0x0,0x0,0x3,0x0,0x0,0x0,0x3,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x2,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x3,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x4,0x0,0x0,0x0,0xc0,0x4,0x0,0x0,0xc4,0x2,0x0,0x0,0x4c,0x1,0x0,0x0,0x4,0x0,0x0,0x0,0x5e,0xfd,0xff,0xff,0x0,0x0,0x0,0x1,0x14,0x0,0x0,0x0,0x48,0x0,0x0,0x0,0x3,0x0,0x0,0x0,0x0,0x0,0x0,0x7,0x18,0x1,0x0,0x0,0x54,0xfb,0xff,0xff,0x10,0x0,0x0,0x0,0x18,0x0,0x0,0x0,0x1c,0x0,0x0,0x0,0x20,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0xc9,0x10,0x58,0x3b,0x1,0x0,0x0,0x0,0x19,0xf,0xd8,0x42,0x1,0x0,0x0,0x0,0x55,0xa0,0x85,0xc2,0xd6,0x0,0x0,0x0,0x73,0x74,0x72,0x65,0x61,0x6d,0x61,0x62,0x6c,0x65,0x5f,0x6d,0x6f,0x64,0x65,0x6c,0x5f,0x31,0x30,0x2f,0x75,0x6e,0x65,0x74,0x5f,0x30,0x2f,0x64,0x65,0x63,0x6f,0x64,0x65,0x72,0x5f,0x31,0x2f,0x73,0x68,0x6f,0x72,0x74,0x63,0x75,0x74,0x2f,0x63,0x6f,0x6e,0x76,0x31,0x78,0x31,0x2f,0x63,0x6f,0x6e,0x76,0x2f,0x42,0x69,0x61,0x73,0x41,0x64,0x64,0x3b,0x73,0x74,0x72,0x65,0x61,0x6d,0x61,0x62,0x6c,0x65,0x5f,0x6d,0x6f,0x64,0x65,0x6c,0x5f,0x31,0x30,0x2f,0x75,0x6e,0x65,0x74,0x5f,0x30,0x2f,0x64,0x65,0x63,0x6f,0x64,0x65,0x72,0x5f,0x31,0x2f,0x73,0x68,0x6f,0x72,0x74,0x63,0x75,0x74,0x2f,0x63,0x6f,0x6e,0x76,0x31,0x78,0x31,0x2f,0x63,0x6f,0x6e,0x76,0x2f,0x43,0x6f,0x6e,0x76,0x32,0x44,0x3b,0x73,0x74,0x72,0x65,0x61,0x6d,0x61,0x62,0x6c,0x65,0x5f,0x6d,0x6f,0x64,0x65,0x6c,0x5f,0x31,0x30,0x2f,0x75,0x6e,0x65,0x74,0x5f,0x30,0x2f,0x64,0x65,0x63,0x6f,0x64,0x65,0x72,0x5f,0x31,0x2f,0x73,0x68,0x6f,0x72,0x74,0x63,0x75,0x74,0x2f,0x63,0x6f,0x6e,0x76,0x31,0x78,0x31,0x2f,0x63,0x6f,0x6e,0x76,0x2f,0x42,0x69,0x61,0x73,0x41,0x64,0x64,0x2f,0x52,0x65,0x61,0x64,0x56,0x61,0x72,0x69,0x61,0x62,0x6c,0x65,0x4f,0x70,0x0,0x0,0x4,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x28,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0xa2,0xfe,0xff,0xff,0x0,0x0,0x0,0x1,0x20,0x0,0x0,0x0,0xf0,0x0,0x0,0x0,0x2,0x0,0x0,0x0,0x0,0x0,0x0,0x4,0x3c,0x1,0x0,0x0,0xc,0x0,0xc,0x0,0x0,0x0,0x0,0x0,0x8,0x0,0x4,0x0,0xc,0x0,0x0,0x0,0x8,0x0,0x0,0x0,0x88,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0xd,0x3b,0x1b,0x36,0x91,0x15,0xd6,0x36,0x28,0x8f,0x88,0x37,0xf3,0x78,0x1c,0x36,0x39,0x28,0x35,0x36,0x43,0x4e,0xd7,0x35,0x5a,0xe2,0x13,0x37,0xea,0xb9,0x88,0x36,0xa,0x3b,0x80,0x36,0x24,0xee,0xfc,0x36,0x8e,0xe,0xd8,0x36,0xca,0xe4,0xdb,0x35,0x15,0x81,0x23,0x37,0xe3,0xc3,0x3,0x37,0x84,0xa1,0xba,0x36,0xc3,0x11,0x47,0x37,0x51,0x0,0x0,0x0,0x73,0x74,0x72,0x65,0x61,0x6d,0x61,0x62,0x6c,0x65,0x5f,0x6d,0x6f,0x64,0x65,0x6c,0x5f,0x31,0x30,0x2f,0x75,0x6e,0x65,0x74,0x5f,0x30,0x2f,0x64,0x65,0x63,0x6f,0x64,0x65,0x72,0x5f,0x31,0x2f,0x73,0x68,0x6f,0x72,0x74,0x63,0x75,0x74,0x2f,0x63,0x6f,0x6e,0x76,0x31,0x78,0x31,0x2f,0x63,0x6f,0x6e,0x76,0x2f,0x42,0x69,0x61,0x73,0x41,0x64,0x64,0x2f,0x52,0x65,0x61,0x64,0x56,0x61,0x72,0x69,0x61,0x62,0x6c,0x65,0x4f,0x70,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0x0,0x0,0x16,0x0,0x1c,0x0,0x18,0x0,0x17,0x0,0x10,0x0,0xc,0x0,0x8,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x7,0x0,0x16,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x14,0x0,0x0,0x0,0x78,0x1,0x0,0x0,0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x9,0xb4,0x1,0x0,0x0,0xc,0xfe,0xff,0xff,0x10,0x0,0x0,0x0,0x94,0x0,0x0,0x0,0xd4,0x0,0x0,0x0,0x14,0x1,0x0,0x0,0x10,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0x8a,0x46,0xf2,0x38,0xc4,0x10,0xa7,0x39,0x56,0x22,0x55,0x3a,0xb2,0x36,0xf4,0x38,0xbc,0x5e,0xd,0x39,0xc9,0x4,0xa8,0x38,0x3f,0xcf,0xe6,0x39,0x13,0x65,0x55,0x39,0xa5,0x22,0x48,0x39,0x3d,0x61,0xc5,0x39,0xd8,0x9a,0xa8,0x39,0x5a,0x99,0xab,0x38,0x3e,0x30,0xff,0x39,0xe2,0xa6,0xcd,0x39,0x44,0xa4,0x91,0x39,0x2a,0x59,0x1b,0x3a,0x10,0x0,0x0,0x0,0xe5,0xbe,0x4d,0x3c,0xf3,0x4c,0x51,0x3c,0xa4,0x2c,0xc4,0x3d,0x61,0x50,0x2c,0x3c,0xbc,0xfc,0x5c,0x3c,0xa3,0xf9,0x1b,0x3c,0x9a,0x2b,0xa5,0x3c,0xe,0x77,0xc5,0x3c,0x60,0x92,0xc6,0x3c,0x4a,0x80,0x8f,0x3c,0xa2,0x49,0x27,0x3d,0x27,0x42,0x2a,0x3c,0x5f,0x62,0xb3,0x3c,0x4d,0x89,0x91,0x3c,0xfb,0x80,0x10,0x3d,0xc7,0x53,0xcd,0x3c,0x10,0x0,0x0,0x0,0xfd,0x61,0x70,0xbc,0xa2,0xc2,0x25,0xbd,0x11,0x78,0xd3,0xbd,0x45,0x4e,0x72,0xbc,0xff,0x43,0x8c,0xbc,0xbf,0xb4,0x26,0xbc,0xa1,0x1,0x65,0xbd,0x49,0xba,0xd3,0xbc,0xde,0xfd,0x99,0xbc,0x7b,0xd6,0x43,0xbd,0x22,0xaa,0xf,0xbd,0x76,0x20,0x1e,0xbc,0xde,0x31,0x7d,0xbd,0x94,0xb,0x4c,0xbd,0x28,0x9,0xf7,0xbc,0x78,0x22,0x9a,0xbd,0x41,0x0,0x0,0x0,0x73,0x74,0x72,0x65,0x61,0x6d,0x61,0x62,0x6c,0x65,0x5f,0x6d,0x6f,0x64,0x65,0x6c,0x5f,0x31,0x30,0x2f,0x75,0x6e,0x65,0x74,0x5f,0x30,0x2f,0x64,0x65,0x63,0x6f,0x64,0x65,0x72,0x5f,0x31,0x2f,0x73,0x68,0x6f,0x72,0x74,0x63,0x75,0x74,0x2f,0x63,0x6f,0x6e,0x76,0x31,0x78,0x31,0x2f,0x63,0x6f,0x6e,0x76,0x2f,0x43,0x6f,0x6e,0x76,0x32,0x44,0x0,0x0,0x0,0x4,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x16,0x0,0x18,0x0,0x14,0x0,0x13,0x0,0x0,0x0,0xc,0x0,0x8,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x7,0x0,0x16,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x1c,0x0,0x0,0x0,0x50,0x0,0x0,0x0,0x0,0x0,0x0,0x7,0x78,0x0,0x0,0x0,0xc,0x0,0x14,0x0,0x10,0x0,0xc,0x0,0x8,0x0,0x4,0x0,0xc,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0x18,0x0,0x0,0x0,0x1c,0x0,0x0,0x0,0x20,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x32,0x6,0xa4,0x3c,0x1,0x0,0x0,0x0,0x5a,0xe8,0xc,0x44,0x1,0x0,0x0,0x0,0xea,0x4,0x24,0xc4,0x2b,0x0,0x0,0x0,0x73,0x74,0x72,0x65,0x61,0x6d,0x61,0x62,0x6c,0x65,0x5f,0x6d,0x6f,0x64,0x65,0x6c,0x5f,0x31,0x30,0x2f,0x75,0x6e,0x65,0x74,0x5f,0x30,0x2f,0x75,0x5f,0x73,0x6b,0x69,0x70,0x5f,0x32,0x2f,0x61,0x64,0x64,0x2f,0x61,0x64,0x64,0x0,0x4,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x28,0x0,0x0,0x0,0x20,0x0,0x0,0x0,0x1,0x0,0x0,0x0,0x10,0x0,0x0,0x0,0xc,0x0,0x10,0x0,0xf,0x0,0x0,0x0,0x8,0x0,0x4,0x0,0xc,0x0,0x0,0x0,0x3,0x0,0x0,0x0,0x3,0x0,0x0,0x0,0x0,0x0,0x0,0x3};
