gcc -O3 -std=c11 .\mlp_hex_infer_rowmajor_full.c -o .\mlp_hex_infer_rowmajor_full.exe

./mlp_hex_infer_rowmajor_full ../export_hw_fixed_halfup_rowmajor ../export_hw_fixed_halfup_rowmajor/mnist_inputs_hex_split/mnist_inputs_correct_meta.csv 0 10