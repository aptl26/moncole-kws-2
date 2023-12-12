def write_bytes(wf, byte_array):
	wf.write(byte_array)

def start_wav_file(filename, sample_width=1, sample_rate=8000, channels=1):
	with open(filename, 'wb') as wf:
		# Write the WAV header
		wf.write(b'RIFF')
		wf.write((36).to_bytes(4, 'little'))  # Placeholder for file size
		wf.write(b'WAVE')

		# Write the fmt sub-chunk
		wf.write(b'fmt ')
		wf.write((16).to_bytes(4, 'little'))  # Sub-chunk size
		wf.write((1).to_bytes(2, 'little'))   # Audio format (PCM)
		wf.write((channels).to_bytes(2, 'little'))  # Number of channels
		wf.write((sample_rate).to_bytes(4, 'little'))  # Sample rate
		wf.write((sample_rate * channels * sample_width).to_bytes(4, 'little'))  # Byte rate
		wf.write((channels * sample_width).to_bytes(2, 'little'))  # Block align
		wf.write((sample_width * 8).to_bytes(2, 'little'))  # Bits per sample

		# Write the data sub-chunk
		wf.write(b'data')
		wf.write((0).to_bytes(4, 'little'))  # Placeholder for sub-chunk size

	return open(filename, 'ab')

def finish_wav_file(wf):
	# Move back to the beginning of the file and update the placeholders
	wf.seek(4)
	wf.write((wf.tell() - 8).to_bytes(4, 'little'))  # Update RIFF chunk size
	wf.seek(40)
	wf.write((wf.tell() - 44).to_bytes(4, 'little'))  # Update data sub-chunk size

	# Close the file
	wf.close()