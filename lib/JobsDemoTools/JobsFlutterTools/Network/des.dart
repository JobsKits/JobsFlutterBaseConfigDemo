import 'int32.dart';

List<int> desCreateKeys(String key) {
  // Declaring this locally speeds things up a bit
  List<int> pc2bytes0 = [
    0,
    0x4,
    0x20000000,
    0x20000004,
    0x10000,
    0x10004,
    0x20010000,
    0x20010004,
    0x200,
    0x204,
    0x20000200,
    0x20000204,
    0x10200,
    0x10204,
    0x20010200,
    0x20010204
  ];
  List<int> pc2bytes1 = [
    0,
    0x1,
    0x100000,
    0x100001,
    0x4000000,
    0x4000001,
    0x4100000,
    0x4100001,
    0x100,
    0x101,
    0x100100,
    0x100101,
    0x4000100,
    0x4000101,
    0x4100100,
    0x4100101
  ];
  List<int> pc2bytes2 = [
    0,
    0x8,
    0x800,
    0x808,
    0x1000000,
    0x1000008,
    0x1000800,
    0x1000808,
    0,
    0x8,
    0x800,
    0x808,
    0x1000000,
    0x1000008,
    0x1000800,
    0x1000808
  ];
  List<int> pc2bytes3 = [
    0,
    0x200000,
    0x8000000,
    0x8200000,
    0x2000,
    0x202000,
    0x8002000,
    0x8202000,
    0x20000,
    0x220000,
    0x8020000,
    0x8220000,
    0x22000,
    0x222000,
    0x8022000,
    0x8222000
  ];
  List<int> pc2bytes4 = [
    0,
    0x40000,
    0x10,
    0x40010,
    0,
    0x40000,
    0x10,
    0x40010,
    0x1000,
    0x41000,
    0x1010,
    0x41010,
    0x1000,
    0x41000,
    0x1010,
    0x41010
  ];
  List<int> pc2bytes5 = [
    0,
    0x400,
    0x20,
    0x420,
    0,
    0x400,
    0x20,
    0x420,
    0x2000000,
    0x2000400,
    0x2000020,
    0x2000420,
    0x2000000,
    0x2000400,
    0x2000020,
    0x2000420
  ];
  List<int> pc2bytes6 = [
    0,
    0x10000000,
    0x80000,
    0x10080000,
    0x2,
    0x10000002,
    0x80002,
    0x10080002,
    0,
    0x10000000,
    0x80000,
    0x10080000,
    0x2,
    0x10000002,
    0x80002,
    0x10080002
  ];
  List<int> pc2bytes7 = [
    0,
    0x10000,
    0x800,
    0x10800,
    0x20000000,
    0x20010000,
    0x20000800,
    0x20010800,
    0x20000,
    0x30000,
    0x20800,
    0x30800,
    0x20020000,
    0x20030000,
    0x20020800,
    0x20030800
  ];
  List<int> pc2bytes8 = [
    0,
    0x40000,
    0,
    0x40000,
    0x2,
    0x40002,
    0x2,
    0x40002,
    0x2000000,
    0x2040000,
    0x2000000,
    0x2040000,
    0x2000002,
    0x2040002,
    0x2000002,
    0x2040002
  ];
  List<int> pc2bytes9 = [
    0,
    0x10000000,
    0x8,
    0x10000008,
    0,
    0x10000000,
    0x8,
    0x10000008,
    0x400,
    0x10000400,
    0x408,
    0x10000408,
    0x400,
    0x10000400,
    0x408,
    0x10000408
  ];
  List<int> pc2bytes10 = [
    0,
    0x20,
    0,
    0x20,
    0x100000,
    0x100020,
    0x100000,
    0x100020,
    0x2000,
    0x2020,
    0x2000,
    0x2020,
    0x102000,
    0x102020,
    0x102000,
    0x102020
  ];
  List<int> pc2bytes11 = [
    0,
    0x1000000,
    0x200,
    0x1000200,
    0x200000,
    0x1200000,
    0x200200,
    0x1200200,
    0x4000000,
    0x5000000,
    0x4000200,
    0x5000200,
    0x4200000,
    0x5200000,
    0x4200200,
    0x5200200
  ];
  List<int> pc2bytes12 = [
    0,
    0x1000,
    0x8000000,
    0x8001000,
    0x80000,
    0x81000,
    0x8080000,
    0x8081000,
    0x10,
    0x1010,
    0x8000010,
    0x8001010,
    0x80010,
    0x81010,
    0x8080010,
    0x8081010
  ];
  List<int> pc2bytes13 = [
    0,
    0x4,
    0x100,
    0x104,
    0,
    0x4,
    0x100,
    0x104,
    0x1,
    0x5,
    0x101,
    0x105,
    0x1,
    0x5,
    0x101,
    0x105
  ];

  // How many iterations (1 for DES, 3 for Triple DES)
  int iterations = key.length > 8 ? 3 : 1; // Use Triple DES for 9+ byte keys
  // Stores the return keys
  List<int> keys = List<int>.filled(32 * iterations, 0);
  // Now define the left shifts which need to be done
  List<int> shifts = [0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0];
  // Other variables
  int m = 0, n = 0;
  Int32 leftTemp = Int32(0);
  Int32 rightTemp = Int32(0);
  Int32 temp = Int32(0);
  for (int j = 0; j < iterations; j++) {
    // Either 1 or 3 iterations
    Int32 left = Int32((key.codeUnitAt(m++) << 24) |
        (key.codeUnitAt(m++) << 16) |
        (key.codeUnitAt(m++) << 8) |
        key.codeUnitAt(m++));
    Int32 right = Int32((key.codeUnitAt(m++) << 24) |
        (key.codeUnitAt(m++) << 16) |
        (key.codeUnitAt(m++) << 8) |
        key.codeUnitAt(m++));
    temp = ((left >>> 4) ^ right) & 0x0f0f0f0f;
    right ^= temp;
    left ^= (temp << 4);
    temp = ((right >>> -16) ^ left) & 0x0000ffff;
    left ^= temp;
    right ^= (temp << -16);
    temp = ((left >>> 2) ^ right) & 0x33333333;
    right ^= temp;
    left ^= (temp << 2);
    temp = ((right >>> -16) ^ left) & 0x0000ffff;
    left ^= temp;
    right ^= temp << -16;
    temp = ((left >>> 1) ^ right) & 0x55555555;
    right ^= temp;
    left ^= (temp << 1);
    temp = ((right >>> 8) ^ left) & 0x00ff00ff;
    left ^= temp;
    right ^= (temp << 8);
    temp = ((left >>> 1) ^ right) & 0x55555555;
    right ^= temp;
    left ^= (temp << 1);
    // The right side needs to be shifted and to get the last four bits of the left side
    temp = (left << 8) | ((right >>> 20) & 0x000000f0);
    // Left needs to be put upside down
    left = (right << 24) |
        ((right << 8) & 0xff0000) |
        ((right >>> 8) & 0xff00) |
        ((right >>> 24) & 0xf0);
    right = temp;
    // Now go through and perform these shifts on the left and right keys
    for (int i = 0; i < shifts.length; i++) {
      // Shift the keys either one or two bits to the left
      if (shifts[i] == 1) {
        left = (left << 2) | (left >>> 26);
        // print('right1: $right');
        right = (right << 2) | (right >>> 26);
        // print('right2: $right');
      } else {
        left = (left << 1) | (left >>> 27);
        right = (right << 1) | (right >>> 27);
      }
      left &= -0xf;
      right &= -0xf;

      // Now apply PC-2, in such a way that E is easier when encrypting or decrypting
      // This conversion will look like PC-2 except only the last 6 bits of each byte are used
      // Rather than 48 consecutive bits and the order of lines will be according to
      // How the S selection functions will be applied: S2, S4, S6, S8, S1, S3, S5, S7
      leftTemp = Int32(pc2bytes0[(left >>> 28).value] |
          pc2bytes1[((left >>> 24).value) & 0xf] |
          pc2bytes2[((left >>> 20).value) & 0xf] |
          pc2bytes3[((left >>> 16).value) & 0xf] |
          pc2bytes4[((left >>> 12).value) & 0xf] |
          pc2bytes5[((left >>> 8).value) & 0xf] |
          pc2bytes6[((left >>> 4).value) & 0xf]);

      rightTemp = Int32(pc2bytes7[(right >>> 28).value] |
          pc2bytes8[((right >>> 24).value) & 0xf] |
          pc2bytes9[((right >>> 20).value) & 0xf] |
          pc2bytes10[((right >>> 16).value) & 0xf] |
          pc2bytes11[((right >>> 12).value) & 0xf] |
          pc2bytes12[((right >>> 8).value) & 0xf] |
          pc2bytes13[((right >>> 4).value) & 0xf]);
      temp = ((rightTemp >>> 16) ^ leftTemp) & 0x0000ffff;
      keys[n++] = (leftTemp ^ temp).value;
      keys[n++] = (rightTemp ^ (temp << 16)).value;
    }
  }
  // Return the keys we've created
  return keys;
}

String unescape(String input) {
  return input.replaceAllMapped(RegExp(r'%([0-9A-Fa-f]{2})'), (match) {
    final hexCode = match.group(1);
    final intValue = int.parse(hexCode!, radix: 16);
    return String.fromCharCode(intValue);
  });
}

String des(String key, String message, bool encrypt, int mode, String iv,
    int padding) {
  if (encrypt) {
    // 如果是加密的话，首先转换编码
    message = unescape(Uri.encodeComponent(message));
  }

  List<int> spfunction1 = [
    0x1010400,
    0,
    0x10000,
    0x1010404,
    0x1010004,
    0x10404,
    0x4,
    0x10000,
    0x400,
    0x1010400,
    0x1010404,
    0x400,
    0x1000404,
    0x1010004,
    0x1000000,
    0x4,
    0x404,
    0x1000400,
    0x1000400,
    0x10400,
    0x10400,
    0x1010000,
    0x1010000,
    0x1000404,
    0x10004,
    0x1000004,
    0x1000004,
    0x10004,
    0,
    0x404,
    0x10404,
    0x1000000,
    0x10000,
    0x1010404,
    0x4,
    0x1010000,
    0x1010400,
    0x1000000,
    0x1000000,
    0x400,
    0x1010004,
    0x10000,
    0x10400,
    0x1000004,
    0x400,
    0x4,
    0x1000404,
    0x10404,
    0x1010404,
    0x10004,
    0x1010000,
    0x1000404,
    0x1000004,
    0x404,
    0x10404,
    0x1010400,
    0x404,
    0x1000400,
    0x1000400,
    0,
    0x10004,
    0x10400,
    0,
    0x1010004
  ];
  List<int> spfunction2 = [
    -0x7fef7fe0,
    -0x7fff8000,
    0x8000,
    0x108020,
    0x100000,
    0x20,
    -0x7fefffe0,
    -0x7fff7fe0,
    -0x7fffffe0,
    -0x7fef7fe0,
    -0x7fef8000,
    -0x80000000,
    -0x7fff8000,
    0x100000,
    0x20,
    -0x7fefffe0,
    0x108000,
    0x100020,
    -0x7fff7fe0,
    0,
    -0x80000000,
    0x8000,
    0x108020,
    -0x7ff00000,
    0x100020,
    -0x7fffffe0,
    0,
    0x108000,
    0x8020,
    -0x7fef8000,
    -0x7ff00000,
    0x8020,
    0,
    0x108020,
    -0x7fefffe0,
    0x100000,
    -0x7fff7fe0,
    -0x7ff00000,
    -0x7fef8000,
    0x8000,
    -0x7ff00000,
    -0x7fff8000,
    0x20,
    -0x7fef7fe0,
    0x108020,
    0x20,
    0x8000,
    -0x80000000,
    0x8020,
    -0x7fef8000,
    0x100000,
    -0x7fffffe0,
    0x100020,
    -0x7fff7fe0,
    -0x7fffffe0,
    0x100020,
    0x108000,
    0,
    -0x7fff8000,
    0x8020,
    -0x80000000,
    -0x7fefffe0,
    -0x7fef7fe0,
    0x108000
  ];
  List<int> spfunction3 = [
    0x208,
    0x8020200,
    0,
    0x8020008,
    0x8000200,
    0,
    0x20208,
    0x8000200,
    0x20008,
    0x8000008,
    0x8000008,
    0x20000,
    0x8020208,
    0x20008,
    0x8020000,
    0x208,
    0x8000000,
    0x8,
    0x8020200,
    0x200,
    0x20200,
    0x8020000,
    0x8020008,
    0x20208,
    0x8000208,
    0x20200,
    0x20000,
    0x8000208,
    0x8,
    0x8020208,
    0x200,
    0x8000000,
    0x8020200,
    0x8000000,
    0x20008,
    0x208,
    0x20000,
    0x8020200,
    0x8000200,
    0,
    0x200,
    0x20008,
    0x8020208,
    0x8000200,
    0x8000008,
    0x200,
    0,
    0x8020008,
    0x8000208,
    0x20000,
    0x8000000,
    0x8020208,
    0x8,
    0x20208,
    0x20200,
    0x8000008,
    0x8020000,
    0x8000208,
    0x208,
    0x8020000,
    0x20208,
    0x8,
    0x8020008,
    0x20200
  ];
  List<int> spfunction4 = [
    0x802001,
    0x2081,
    0x2081,
    0x80,
    0x802080,
    0x800081,
    0x800001,
    0x2001,
    0,
    0x802000,
    0x802000,
    0x802081,
    0x81,
    0,
    0x800080,
    0x800001,
    0x1,
    0x2000,
    0x800000,
    0x802001,
    0x80,
    0x800000,
    0x2001,
    0x2080,
    0x800081,
    0x1,
    0x2080,
    0x800080,
    0x2000,
    0x802080,
    0x802081,
    0x81,
    0x800080,
    0x800001,
    0x802000,
    0x802081,
    0x81,
    0,
    0,
    0x802000,
    0x2080,
    0x800080,
    0x800081,
    0x1,
    0x802001,
    0x2081,
    0x2081,
    0x80,
    0x802081,
    0x81,
    0x1,
    0x2000,
    0x800001,
    0x2001,
    0x802080,
    0x800081,
    0x2001,
    0x2080,
    0x800000,
    0x802001,
    0x80,
    0x800000,
    0x2000,
    0x802080
  ];
  List<int> spfunction5 = [
    0x100,
    0x2080100,
    0x2080000,
    0x42000100,
    0x80000,
    0x100,
    0x40000000,
    0x2080000,
    0x40080100,
    0x80000,
    0x2000100,
    0x40080100,
    0x42000100,
    0x42080000,
    0x80100,
    0x40000000,
    0x2000000,
    0x40080000,
    0x40080000,
    0,
    0x40000100,
    0x42080100,
    0x42080100,
    0x2000100,
    0x42080000,
    0x40000100,
    0,
    0x42000000,
    0x2080100,
    0x2000000,
    0x42000000,
    0x80100,
    0x80000,
    0x42000100,
    0x100,
    0x2000000,
    0x40000000,
    0x2080000,
    0x42000100,
    0x40080100,
    0x2000100,
    0x40000000,
    0x42080000,
    0x2080100,
    0x40080100,
    0x100,
    0x2000000,
    0x42080000,
    0x42080100,
    0x80100,
    0x42000000,
    0x42080100,
    0x2080000,
    0,
    0x40080000,
    0x42000000,
    0x80100,
    0x2000100,
    0x40000100,
    0x80000,
    0,
    0x40080000,
    0x2080100,
    0x40000100
  ];
  List<int> spfunction6 = [
    0x20000010,
    0x20400000,
    0x4000,
    0x20404010,
    0x20400000,
    0x10,
    0x20404010,
    0x400000,
    0x20004000,
    0x404010,
    0x400000,
    0x20000010,
    0x400010,
    0x20004000,
    0x20000000,
    0x4010,
    0,
    0x400010,
    0x20004010,
    0x4000,
    0x404000,
    0x20004010,
    0x10,
    0x20400010,
    0x20400010,
    0,
    0x404010,
    0x20404000,
    0x4010,
    0x404000,
    0x20404000,
    0x20000000,
    0x20004000,
    0x10,
    0x20400010,
    0x404000,
    0x20404010,
    0x400000,
    0x4010,
    0x20000010,
    0x400000,
    0x20004000,
    0x20000000,
    0x4010,
    0x20000010,
    0x20404010,
    0x404000,
    0x20400000,
    0x404010,
    0x20404000,
    0,
    0x20400010,
    0x10,
    0x4000,
    0x20400000,
    0x404010,
    0x4000,
    0x400010,
    0x20004010,
    0,
    0x20404000,
    0x20000000,
    0x400010,
    0x20004010
  ];
  List<int> spfunction7 = [
    0x200000,
    0x4200002,
    0x4000802,
    0,
    0x800,
    0x4000802,
    0x200802,
    0x4200800,
    0x4200802,
    0x200000,
    0,
    0x4000002,
    0x2,
    0x4000000,
    0x4200002,
    0x802,
    0x4000800,
    0x200802,
    0x200002,
    0x4000800,
    0x4000002,
    0x4200000,
    0x4200800,
    0x200002,
    0x4200000,
    0x800,
    0x802,
    0x4200802,
    0x200800,
    0x2,
    0x4000000,
    0x200800,
    0x4000000,
    0x200800,
    0x200000,
    0x4000802,
    0x4000802,
    0x4200002,
    0x4200002,
    0x2,
    0x200002,
    0x4000000,
    0x4000800,
    0x200000,
    0x4200800,
    0x802,
    0x200802,
    0x4200800,
    0x802,
    0x4000002,
    0x4200802,
    0x4200000,
    0x200800,
    0,
    0x2,
    0x4200802,
    0,
    0x200802,
    0x4200000,
    0x800,
    0x4000002,
    0x4000800,
    0x800,
    0x200002
  ];
  List<int> spfunction8 = [
    0x10001040,
    0x1000,
    0x40000,
    0x10041040,
    0x10000000,
    0x10001040,
    0x40,
    0x10000000,
    0x40040,
    0x10040000,
    0x10041040,
    0x41000,
    0x10041000,
    0x41040,
    0x1000,
    0x40,
    0x10040000,
    0x10000040,
    0x10001000,
    0x1040,
    0x41000,
    0x40040,
    0x10040040,
    0x10041000,
    0x1040,
    0,
    0,
    0x10040040,
    0x10000040,
    0x10001000,
    0x41040,
    0x40000,
    0x41040,
    0x40000,
    0x10041000,
    0x1000,
    0x40,
    0x10040040,
    0x1000,
    0x41040,
    0x10001000,
    0x40,
    0x10000040,
    0x10040000,
    0x10040040,
    0x10000000,
    0x40000,
    0x10001040,
    0,
    0x10041040,
    0x40040,
    0x10000040,
    0x10040000,
    0x10001000,
    0x10001040,
    0,
    0x10041040,
    0x41000,
    0x41000,
    0x1040,
    0x1040,
    0x40040,
    0x10000000,
    0x10041000
  ];

  // Create the 16 or 48 subkeys we will need
  List<int> keys = desCreateKeys(key);
  int m = 0;
  int len = message.length;
  int chunk = 0;
  int iterations = keys.length == 32 ? 3 : 9;
  List<int> looping;

  if (iterations == 3) {
    looping = encrypt ? [0, 32, 2] : [30, -2, -2];
  } else {
    looping = encrypt
        ? [0, 32, 2, 62, 30, -2, 64, 96, 2]
        : [94, 62, -2, 32, 64, 2, 30, -2, -2];
  }

  // Pad the message depending on the padding parameter
  if (padding == 2) {
    message += ' ' * 8;
  } else if (padding == 1 && encrypt) {
    int temp = 8 - (len % 8);
    message += String.fromCharCodes(List<int>.filled(temp, temp));
    if (temp == 8) {
      len += 8;
    }
  } else if (padding == 0) {
    message += '0' * 8;
  }
  // print('des len: $len');
  // Store the result here
  StringBuffer result = StringBuffer();
  StringBuffer tempResult = StringBuffer();

  int cbcleft = 0, cbcleft2 = 0, cbcright = 0, cbcright2 = 0;
  if (mode == 1) {
    cbcleft = (iv.codeUnitAt(m++) << 24) |
        (iv.codeUnitAt(m++) << 16) |
        (iv.codeUnitAt(m++) << 8) |
        iv.codeUnitAt(m++);
    cbcright = (iv.codeUnitAt(m++) << 24) |
        (iv.codeUnitAt(m++) << 16) |
        (iv.codeUnitAt(m++) << 8) |
        iv.codeUnitAt(m++);
    m = 0;
  }

  // Loop through each 64-bit chunk of the message
  while (m < len) {
    Int32 left = Int32((message.codeUnitAt(m++) << 24) |
        (message.codeUnitAt(m++) << 16) |
        (message.codeUnitAt(m++) << 8) |
        message.codeUnitAt(m++));
    Int32 right = Int32((message.codeUnitAt(m++) << 24) |
        (message.codeUnitAt(m++) << 16) |
        (message.codeUnitAt(m++) << 8) |
        message.codeUnitAt(m++));

    // For Cipher Block Chaining mode, xor the message with the previous result
    if (mode == 1) {
      if (encrypt) {
        left ^= cbcleft;
        right ^= cbcright;
      } else {
        cbcleft2 = cbcleft;
        cbcright2 = cbcright;
        cbcleft = left.value;
        cbcright = right.value;
      }
    }

    // First, each 64-bit chunk of the message must be permuted according to IP
    Int32 temp = ((left >>> 4) ^ right) & 0x0f0f0f0f;
    right ^= temp;
    left ^= (temp << 4);
    temp = ((left >>> 16) ^ right) & 0x0000ffff;
    right ^= temp;
    left ^= (temp << 16);
    temp = ((right >>> 2) ^ left) & 0x33333333;
    left ^= temp;
    right ^= (temp << 2);
    temp = ((right >>> 8) ^ left) & 0x00ff00ff;
    left ^= temp;
    right ^= (temp << 8);
    temp = ((left >>> 1) ^ right) & 0x55555555;
    right ^= temp;
    left ^= (temp << 1);
    left = ((left << 1) | (left >>> 31));
    right = ((right << 1) | (right >>> 31));

    // Do this either 1 or 3 times for each chunk of the message
    for (int j = 0; j < iterations; j += 3) {
      int endloop = looping[j + 1];
      int loopinc = looping[j + 2];

      // Perform the encryption or decryption
      for (int i = looping[j]; i != endloop; i += loopinc) {
        Int32 right1 = right ^ keys[i];
        Int32 right2 = ((right >>> 4) | (right << 28)) ^ keys[i + 1];
        temp = left;
        left = right;
        right = temp ^
            (spfunction2[((right1 >>> 24) & 0x3f).value] |
                spfunction4[((right1 >>> 16) & 0x3f).value] |
                spfunction6[((right1 >>> 8) & 0x3f).value] |
                spfunction8[(right1 & 0x3f).value] |
                spfunction1[((right2 >>> 24) & 0x3f).value] |
                spfunction3[((right2 >>> 16) & 0x3f).value] |
                spfunction5[((right2 >>> 8) & 0x3f).value] |
                spfunction7[(right2 & 0x3f).value]);
      }

      temp = left;
      left = right;
      right = temp;
    }

    // Move each one bit to the right
    left = ((left >>> 1) | (left << 31));
    right = ((right >>> 1) | (right << 31));

    // Perform IP-1, which is IP in the opposite direction
    temp = ((left >>> 1) ^ right) & 0x55555555;
    right ^= temp;
    left ^= (temp << 1);
    temp = ((right >>> 8) ^ left) & 0x00ff00ff;
    left ^= temp;
    right ^= (temp << 8);
    temp = ((right >>> 2) ^ left) & 0x33333333;
    left ^= temp;
    right ^= (temp << 2);
    temp = ((left >>> 16) ^ right) & 0x0000ffff;
    right ^= temp;
    left ^= (temp << 16);
    temp = ((left >>> 4) ^ right) & 0x0f0f0f0f;
    right ^= temp;
    left ^= (temp << 4);

    // For Cipher Block Chaining mode, xor the message with the previous result
    if (mode == 1) {
      if (encrypt) {
        cbcleft = left.value;
        cbcright = right.value;
      } else {
        left ^= cbcleft2;
        right ^= cbcright2;
      }
    }
    // print('des left:$left right:$right');
    tempResult.writeCharCode(((left >>> 24) & 0xff).value);
    tempResult.writeCharCode(((left >>> 16) & 0xff).value);
    tempResult.writeCharCode(((left >>> 8) & 0xff).value);
    tempResult.writeCharCode((left & 0xff).value);
    tempResult.writeCharCode(((right >>> 24) & 0xff).value);
    tempResult.writeCharCode(((right >>> 16) & 0xff).value);
    tempResult.writeCharCode(((right >>> 8) & 0xff).value);
    tempResult.writeCharCode((right & 0xff).value);

    chunk += 8;
    if (chunk == 512) {
      result.write(tempResult.toString());
      tempResult.clear();
      chunk = 0;
    }
  }

  result.write(tempResult.toString());
  String res = result.toString();
  if (!encrypt) {
    res = res.replaceAll(RegExp(r'\0*$'), '');

    if (padding == 1) {
      int len = res.length;
      int paddingChars = 0;
      if (len > 0) {
        paddingChars = res.codeUnitAt(len - 1);
      }
      if (paddingChars <= 8) {
        res = res.substring(0, len - paddingChars);
      }
    }
    res = Uri.decodeComponent(escape(res));
  }
  // print('des result:$res');
  return res;
}

String escape(String string) {
  final buffer = StringBuffer();
  for (int i = 0; i < string.length; i++) {
    var charCode = string.codeUnitAt(i);
    if (charCode < 0x20 ||
        charCode > 0x7E ||
        charCode == 0x20 ||
        charCode == 0x2C ||
        charCode == 0x2F ||
        charCode == 0x3A ||
        charCode == 0x3B ||
        charCode == 0x3F ||
        charCode == 0x40 ||
        charCode == 0x5B ||
        charCode == 0x5D ||
        charCode == 0x7B ||
        charCode == 0x7D ||
        charCode == 0x7E ||
        charCode == 0x25 ||
        charCode == 0x22 ||
        charCode == 0x27 ||
        charCode == 0x23 ||
        charCode == 0x3C ||
        charCode == 0x3E) {
      buffer.write('%');
      buffer.write(charCode.toRadixString(16).toUpperCase().padLeft(2, '0'));
    } else {
      buffer.writeCharCode(charCode);
    }
  }
  return buffer.toString();
}
