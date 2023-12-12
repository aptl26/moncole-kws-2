# Minimal Spectrogram and Bytes Conversion without Imports

# Python Standard Library Modules
import wave
import struct
import math

# Function to read WAV file and create a basic spectrogram
def create_spectrogram(file_path):
    # Open the WAV file
    with wave.open(file_path, 'rb') as wf:
        framerate = wf.getframerate()
        frames = wf.readframes(wf.getnframes())

    # Convert frames to a list of samples
    samples = struct.unpack(f'{len(frames)//wf.getsampwidth()}h', frames)

    # Parameters for the spectrogram
    window_size = 1024
    hop_size = 512

    # Initialize the spectrogram
    spectrogram = []

    # Calculate the spectrogram
    for i in range(0, len(samples) - window_size, hop_size):
        window = samples[i:i + window_size]
        spectrum = [abs(math.sqrt(x.real**2 + x.imag**2)) for x in fft(window)]
        spectrogram.append(spectrum)

    return spectrogram

# Function to convert the spectrogram to bytes
def spectrogram_to_bytes(spectrogram):
    return bytes([int(min(255, max(0, x))) for row in spectrogram for x in row])

# Fast Fourier Transform (FFT) implementation
def fft(x):
    N = len(x)
    if N <= 1:
        return x
    even = fft(x[0::2])
    odd = fft(x[1::2])
    T = [math.e**(-2j * math.pi * k / N) * odd[k] for k in range(N // 2)]
    return [even[k] + T[k] for k in range(N // 2)] + [even[k] - T[k] for k in range(N // 2)]

# Example usage
file_path = 'path/to/your/file.wav'
spectrogram = create_spectrogram(file_path)
spectrogram_bytes = spectrogram_to_bytes(spectrogram)

# Use spectrogram_bytes as input to your ML model
