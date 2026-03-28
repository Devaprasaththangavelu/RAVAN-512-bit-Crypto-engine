import numpy as np
from PIL import Image
import sys
import os
import subprocess
from ravan import RavanEngine

def process_file(input_file, sel=2):
    # 512-bit Key
    key_val = 0x0123456789ABCDEF1122334455667788AABBCCDDEE0011225566778899AABBCC998877665544332244556677889900111234123412341234ABCDABCDABCDABCD
    engine = RavanEngine(key_val)
    
    if not os.path.exists(input_file) or os.path.getsize(input_file) == 0:
        print(f"Error: File '{input_file}' is missing or empty!")
        return

    # --- SMART TOGGLE ---
    # We check if the filename starts with "ENC_" to decide mode
    is_encrypted = os.path.basename(input_file).startswith("ENC_")
    mode = "DECRYPTING" if is_encrypted else "ENCRYPTING"

    print(f"[*] Reading {input_file}...")
    with open(input_file, 'rb') as f:
        data_bytes = f.read()
    
    orig_len = len(data_bytes)
    padding = (8 - (orig_len % 8)) % 8
    blocks = np.frombuffer(data_bytes + b'\x00' * padding, dtype=np.uint64)
    output_blocks = np.zeros_like(blocks)

    print(f"[*] {mode} mode | Blocks: {len(blocks)} | Sel: {sel}")
    
    for i in range(len(blocks)):
        if is_encrypted:
            output_blocks[i] = engine.decrypt_block(blocks[i], sel)
        else:
            output_blocks[i] = engine.encrypt_block(blocks[i], sel)
    
    out_bytes = output_blocks.tobytes()

    if not is_encrypted:
        # --- ENCRYPTION: Save with ENC_ prefix and same extension ---
        dir_name = os.path.dirname(input_file)
        base_name = os.path.basename(input_file)
        output_name = os.path.join(dir_name, "ENC_" + base_name)
        
        with open(output_name, 'wb') as f:
            f.write(out_bytes)
        
        print(f"[+] Encrypted file saved as: {output_name}")
        print(f"[!] Note: Even though it has the same extension, it won't open normally.")

        # Visual Demo
        side = int(len(out_bytes)**0.5)
        if side > 10:
            usable = side * side
            img_array = np.frombuffer(out_bytes[:usable], dtype=np.uint8).reshape((side, side))
            noise_img = Image.fromarray(img_array, mode='L').resize((512, 512), resample=Image.NEAREST)
            noise_img.save("SCRAMBLED_VISUAL.png")
            noise_img.show()
    else:
        # --- DECRYPTION: Save with FIXED_ prefix ---
        dir_name = os.path.dirname(input_file)
        base_name = os.path.basename(input_file).replace("ENC_", "")
        output_name = os.path.join(dir_name, "FIXED_" + base_name)
        
        with open(output_name, 'wb') as f:
            f.write(out_bytes[:orig_len]) 
        
        print(f"[+] File restored: {output_name}")
        
        # Automatically open
        if sys.platform.startswith('linux'):
            subprocess.call(['xdg-open', output_name])
        elif sys.platform.startswith('win'):
            os.startfile(output_name)
        else:
            subprocess.call(['open', output_name])

if __name__ == "__main__":
    args = [a for a in sys.argv if a not in ["encrypt", "decrypt", "python3", sys.argv[0]]]
    if not args:
        print("Usage: python3 ravan_final_same_ext.py <file> <sel>")
    else:
        filename = args[0]
        selection = int(args[1]) if len(args) > 1 else 2
        process_file(filename, selection)
