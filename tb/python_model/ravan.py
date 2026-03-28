import numpy as np
import sys
import os

class RavanEngine:
    def __init__(self, key_512):
        # Slicing the 512-bit key into 8 x 64-bit chunks (Exact replica of keyslicer.v)
        self.keys = [(key_512 >> (i * 64)) & 0xFFFFFFFFFFFFFFFF for i in range(8)]
        self.MASK_64 = 0xFFFFFFFFFFFFFFFF
        self.MASK_32 = 0xFFFFFFFF
        self.MAGIC = 0xDEADBEEFCAFEBABE

    def _ror(self, val, n):
        n = n % 64
        return ((val >> n) | (val << (64 - n))) & self.MASK_64

    def _rol(self, val, n):
        n = n % 64
        return ((val << n) | (val >> (64 - n))) & self.MASK_64

    def encrypt_block(self, data_in, sel):
        temp = data_in & self.MASK_64
        for _ in range(21): # 21 Rounds
            for k in self.keys: # 8 Key slices
                if sel == 0:   temp = (~(temp ^ k))
                elif sel == 1: temp = (~(temp + k))
                elif sel == 2: temp = (self._rol(temp, 13) ^ k)
                elif sel == 3: temp = (temp ^ k) + self.MAGIC
                elif sel == 4: temp = (temp ^ k) ^ self._ror(k, 7)
                elif sel == 5:
                    low, high = (temp ^ k) & self.MASK_32, ((temp ^ k) >> 32) & self.MASK_32
                    temp = ((~low) << 32) | high
                elif sel == 6: temp = (~(temp ^ k)) + k
                elif sel == 7:
                    p1, p2 = ((temp ^ k) & 0xF0F0F0F0F0F0F0F0) >> 4, ((temp ^ k) & 0x0F0F0F0F0F0F0F0F) << 4
                    temp = p1 | p2
                elif sel == 8: temp = self._rol(temp, k & 0x3F) ^ k
                else:
                    low, high = (temp & self.MASK_32) ^ (k & self.MASK_32), ((temp >> 32) & self.MASK_32) + ((k >> 32) & self.MASK_32)
                    temp = ((high & self.MASK_32) << 32) | low
                temp &= self.MASK_64
        return temp

    def decrypt_block(self, data_in, sel):
        temp = data_in & self.MASK_64
        for _ in range(21):
            for k in reversed(self.keys):
                if sel == 0:   temp = (~temp) ^ k
                elif sel == 1: temp = (~temp - k)
                elif sel == 2: temp = self._ror(temp ^ k, 13)
                elif sel == 3: temp = (temp - self.MAGIC) ^ k
                elif sel == 4: temp = temp ^ self._ror(k, 7) ^ k
                elif sel == 5:
                    high, low = (temp >> 32) & self.MASK_32, temp & self.MASK_32
                    temp = ((low ^ k) << 32) | ((~high ^ k) & self.MASK_32)
                elif sel == 6: temp = (~(temp - k)) ^ k
                elif sel == 7:
                    p1, p2 = (temp & 0xF0F0F0F0F0F0F0F0) >> 4, (temp & 0x0F0F0F0F0F0F0F0F) << 4
                    temp = (p1 | p2) ^ k
                elif sel == 8: temp = self._ror(temp ^ k, k & 0x3F)
                else:
                    low, high = (temp & self.MASK_32) ^ (k & self.MASK_32), ((temp >> 32) & self.MASK_32) - ((k >> 32) & self.MASK_32)
                    temp = ((high & self.MASK_32) << 32) | low
                temp &= self.MASK_64
        return temp

def main():
    if len(sys.argv) < 4:
        print("Usage: python ravan.py <filename> <encrypt/decrypt> <sel_value>")
        return

    filename = sys.argv[1]
    mode = sys.argv[2].lower()
    sel = int(sys.argv[3])
    
    # 512-bit Dummy Key (Match this with your hardware testbench key)
    key_val = 0x0123456789ABCDEF1122334455667788AABBCCDDEE0011225566778899AABBCC998877665544332244556677889900111234123412341234ABCDABCDABCDABCD
    engine = RavanEngine(key_val)

    if not os.path.exists(filename):
        print(f"Error: File {filename} not found!")
        return

    # Read file and pad to 64-bit blocks
    with open(filename, 'rb') as f:
        data = f.read()
    
    padding = (8 - (len(data) % 8)) % 8
    data += b'\x00' * padding
    blocks = np.frombuffer(data, dtype=np.uint64)
    output = np.zeros_like(blocks)

    print(f"--- RAVAN {mode.upper()}ION STARTING ---")
    for i in range(len(blocks)):
        if mode == 'encrypt':
            output[i] = engine.encrypt_block(blocks[i], sel)
        else:
            output[i] = engine.decrypt_block(blocks[i], sel)

    out_name = filename + ".enc" if mode == "encrypt" else filename.replace(".enc", ".dec")
    with open(out_name, 'wb') as f:
        f.write(output.tobytes())
    
    print(f"Process Complete! Output saved as: {out_name}")

if __name__ == "__main__":
    main()
