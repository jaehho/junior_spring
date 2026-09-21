# %% [markdown]
# # Project 2
# 
# thoughts: using polar coordinates

# %%
from PIL import Image, ImageDraw
import numpy as np
from scipy.special import rel_entr
from util import spike_gen

# %%
# Load the image
image_path = "assets/image.jpg"
raw_image = Image.open(image_path)

raw_image.size, raw_image.mode

# %%
reduce_factor = 10

new_width = raw_image.width // reduce_factor
new_height = raw_image.height // reduce_factor

# Resize image using ANTIALIAS for better quality
resized_image = raw_image.resize((new_width, new_height), Image.LANCZOS)
print("resized image size:", resized_image.size)
image = resized_image.convert("L")
print("image mode:", image.mode)
image



# %% [markdown]
# ## Gabor Function
# 
# $$
# D_s(x, y) = \frac{1}{2\pi\sigma_x\sigma_y} \exp\left( -\frac{x^2}{2\sigma_x^2} - \frac{y^2}{2\sigma_y^2} \right) \cos(kx - \phi).
# $$
# 
# The parameters in this function determine the properties of the spatial receptive field: 
# $\sigma_x$ and $\sigma_y$ determine its extent in the $x$ and $y$ directions, respectively;
# $k$, the preferred spatial frequency, determines the spacing of light and dark bars that produce the maximum response 
# (the preferred spatial wavelength is $2\pi/k$); and $\phi$ is the preferred spatial phase, which determines 
# where the ON-OFF boundaries fall within the receptive field.
# 

# %%
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def gabor_function(x, y, wavelength, orientation, phase, sigma_x, sigma_y):
    """
    Computes the Gabor function.

    Parameters:
    x, y        : Grid coordinates
    wavelength  : Wavelength of the sinusoid
    orientation : Orientation of the Gabor filter in radians
    phase       : Phase offset of the sinusoid
    sigma_x     : Standard deviation of the Gaussian along x
    sigma_y     : Standard deviation of the Gaussian along y

    Returns:
    gabor       : The Gabor function evaluated at (x, y)
    """
    # Rotation of coordinates
    x_theta = x * np.cos(orientation) + y * np.sin(orientation)
    y_theta = -x * np.sin(orientation) + y * np.cos(orientation)

    # Gaussian Envelope
    gaussian_envelope = np.exp(-(x_theta**2 / (2 * sigma_x**2) + y_theta**2 / (2 * sigma_y**2)))

    # Sinusoidal Plane Wave
    sinusoid = np.cos(2 * np.pi * x_theta / wavelength + phase)

    # Gabor function
    gabor = gaussian_envelope * sinusoid

    return gabor

neuron_size = 100 # wavelength of the Gabor filter
wavelength = neuron_size / 2
orientation = np.pi
phase = np.pi / 2
sigma_x = wavelength/5 # arbitrary choice
sigma_y = wavelength/5 # arbitrary choice

x = np.linspace(-wavelength, wavelength, neuron_size)
y = np.linspace(-wavelength, wavelength, neuron_size)
X, Y = np.meshgrid(x, y)

gabor = gabor_function(X, Y, wavelength, orientation, phase, sigma_x, sigma_y)

fig = plt.figure(figsize=(12, 5))

ax1 = fig.add_subplot(1, 2, 1)
im = ax1.imshow(gabor, cmap='gray', extent=[-wavelength, wavelength, -wavelength, wavelength])
fig.colorbar(im, ax=ax1, label="Gabor Response")
ax1.set_xlabel("X")
ax1.set_ylabel("Y")

# 3D Plot
ax2 = fig.add_subplot(1, 2, 2, projection='3d', elev=30, azim=-60)
ax2.plot_surface(X, Y, gabor, cmap='viridis', edgecolor='k', alpha=0.5)
ax2.set_xlabel("X")
ax2.set_ylabel("Y")
ax2.set_zlabel("Gabor Response")

# Show plots
plt.tight_layout()


# %% [markdown]
# ## Estimating Firing Rate
# 
# $$
# r_{est} = r_0 + F(L(t))
# $$
# 
# assuming Linear Estimate and a separable temporal factor, we have
# 
# $$
# F(L(t)) = L_s = \int dxdy \, D(x,y) s(x,y).
# $$
# 
# where $L_s$ is the spatial linear estimate of the firing rate of a single neuron, $D(x,y)$ is the Gabor function, and $s(x,y)$ is the stimulus.

# %%
image_array = np.array(image, dtype=np.float32)
image_array /= 255.0 # Normalize to [0, 1]

# %%
def estimate_response(
    image_array: np.ndarray, 
    gabor: np.ndarray, 
    neuron_size: int,
    neuron_center: tuple,
    plot: bool = False,
    ) -> float:
    y_center, x_center = neuron_center

    # Create a zero-padded array of the expected neuron size
    neuron_img_arr = np.zeros((neuron_size, neuron_size), dtype=image_array.dtype)
    
    # Define the expected boundaries in the image
    y_start_img = max(0, y_center - neuron_size // 2)
    y_end_img   = min(image_array.shape[0], y_center + neuron_size // 2)
    x_start_img = max(0, x_center - neuron_size // 2)
    x_end_img   = min(image_array.shape[1], x_center + neuron_size // 2)
    
    # Calculate the corresponding indices in the zero-padded neuron image
    offset_y = y_start_img - (y_center - neuron_size // 2)
    offset_x = x_start_img - (x_center - neuron_size // 2)
    
    neuron_img_arr[offset_y:offset_y + (y_end_img - y_start_img),
                   offset_x:offset_x + (x_end_img - x_start_img)] = image_array[y_start_img:y_end_img,
                                                                               x_start_img:x_end_img]
    r_est = np.sum(gabor * neuron_img_arr)
    
    if plot:
        # Create an overlay on the full image
        overlay = np.zeros_like(image_array)
        # Only update the region that overlaps with the image
        overlay[y_start_img:y_end_img, x_start_img:x_end_img] = gabor[offset_y:offset_y+(y_end_img - y_start_img),
                                                                      offset_x:offset_x+(x_end_img - x_start_img)]
        alpha = 0.5  # (0 = only image, 1 = only Gabor)
        overlayed_image = (1 - alpha) * image_array + alpha * overlay
        
        plt.figure(figsize=(6, 6))
        plt.imshow(overlayed_image, cmap="gray")
        plt.title("Gabor Function Overlayed on Full Image")
        plt.axis("off")
        plt.show()
    return r_est

neuron_center = (500,500)
r_est = estimate_response(image_array, gabor, neuron_size, neuron_center, plot=True)
r_est

# %% [markdown]
# ## Encoding

# %%
def encode(
    image_array: np.ndarray, 
    gabor: np.ndarray, 
    neuron_size: int,
    num_neurons: tuple[int, int],
    plot: bool = False,
    ) -> np.ndarray:

    r_est_array = np.zeros((n, m), dtype=np.float32)
    for i in range(1,n+1):
        for j in range(1,m+1):
            x_center = image_array.shape[0] // n * i
            y_center = image_array.shape[1] // m * j
            neuron_center = (x_center, y_center)
            r_est_array[i-1, j-1] = estimate_response(
                image_array, gabor, neuron_size, neuron_center, plot=False
            )
    r_est_array.max(), r_est_array.min()

    r_est_array /= max(r_est_array.max(), abs(r_est_array.min()))
    
    if plot:
        plt.imshow(r_est_array, cmap="gray")
        plt.axis("off")
    return r_est_array

n = image_array.shape[0] // 5
m = image_array.shape[1] // 5
r_est_array = encode(image_array, gabor, neuron_size, (n, m), plot=True)

# %%
plt.figure(figsize=(8, 6))
plt.hist(r_est_array.flatten(), bins=50, color='blue', alpha=0.7)
plt.title("Histogram of r_est_array")
plt.xlabel("Value")
plt.ylabel("Frequency")
plt.grid(True)
plt.show()

# %%
r_est_array_scaled = ((r_est_array + 2) / 2) * 120
T = 1 # [s]

fig, ax = plt.subplots(1, 1, figsize=(15, 6))
neuron_response = []
for r in r_est_array_scaled.flatten():
    neuron_response.append(spike_gen.fast_spike_generator(r, T=T)["Homogeneous w/ Refractory Effects"])

ax.set_xlim(0, T)
ax.set_title("Homogeneous w/ Refractory Effects")
ax.set_xlabel("Time ($s$)")
ax.get_yaxis().set_visible(False)
ax.eventplot(neuron_response[:10], linelengths=0.8)
fig.tight_layout()

# %% [markdown]
# ## Decoding

# %%
def decode(
    neural_resp_arr: np.ndarray
    ) -> np.ndarray:
    decoded = np.cumsum(neural_resp_arr, axis=1)
    return decoded

# decoded = np.cumsum(r_est_array.transpose(), axis=0)
decoded = decode(r_est_array)

# Plot the images for comparison
plt.figure(figsize=(12, 4))
plt.subplot(1, 3, 1)
plt.title("Original Image")
plt.imshow(image_array, cmap='gray')
plt.axis('off')

plt.subplot(1, 3, 2)
plt.title("Edge Detector Output")
plt.imshow(r_est_array, cmap='gray')
plt.axis('off')

plt.subplot(1, 3, 3)
plt.title("Reconstructed Image")
plt.imshow(decoded, cmap='gray')
plt.axis('off')

plt.tight_layout()
plt.show()
r_est_array.min(), r_est_array.max(), decoded.min(), decoded.max()

# %%
def normalize_to_255(image: np.ndarray) -> np.ndarray:
    # Ensure the image is a float for accurate normalization
    image = image.astype(np.float32)
    
    # Normalize to range 0-1
    image_min = image.min()
    image_max = image.max()
    if image_max - image_min == 0:
        return np.zeros_like(image, dtype=np.uint8)
    
    normalized = (image - image_min) / (image_max - image_min)
    
    # Scale to range 0-255 and convert to uint8
    normalized_255 = (normalized * 255).astype(np.uint8)
    
    return normalized_255
decoded_normalized = normalize_to_255(decoded)

decoded_image = Image.fromarray(decoded_normalized, mode='L')
decoded_image

# %%
image_histogram = np.array(image.histogram())
decoded_histogram = np.array(decoded_image.histogram())

# Normalize
image_histogram = image_histogram / image_histogram.sum()
decoded_histogram = decoded_histogram / decoded_histogram.sum()

fig, ax = plt.subplots(1, 2, figsize=(12, 5))
ax[0].plot(image_histogram, color='blue', label='Original Histogram')
ax[0].set_title('Original Histogram')
ax[1].plot(decoded_histogram, color='red', label='Decoded Histogram')
ax[1].set_title('Decoded Histogram')
plt.tight_layout()
plt.show()

# Compute KL divergence
rel_entropy = np.sum(rel_entr(image_histogram, decoded_histogram))  # rel_entr = P * log(P/Q)

print(f"Relative Entropy: {rel_entropy}")
