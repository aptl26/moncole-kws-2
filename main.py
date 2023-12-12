import microphone, time
import to_wav

output_filename = "output.wav"
bit_depth = 8
sample_rate = 1000 * bit_depth
sample_width = bit_depth // 8
seconds = 3.0

# Starts a new 4 second recording with 8khz sample rate, and signed 8bit output
microphone.record(seconds=seconds, bit_depth=bit_depth, sample_rate=sample_rate)
time.sleep(0.5)  ## A short time is needed to let the FPGA prepare the buffer

samples = 126

# Start the WAV file
wf = to_wav.start_wav_file(output_filename)

while True:
        chunk1 = microphone.read(samples)
        chunk2 = microphone.read(samples)

        time.sleep(0.1)

        if chunk1 == None:
            break
        elif chunk2 == None:
            print(bytearray(chunk1), end = "+")
            # Write the received data
            to_wav.write_bytes(wf, bytearray(chunk1))
        else:
            print(bytearray(chunk1 + chunk2), end = "+")
             # Write the received data
            to_wav.write_bytes(wf, bytearray(chunk1 + chunk2))





# Finish the WAV file
to_wav.finish_wav_file(wf)
