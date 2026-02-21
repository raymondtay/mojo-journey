import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Set parameters
sigma = 2.0  # standard deviation
x = np.linspace(-3, 3, 100)
y = np.linspace(-3, 3, 100)
X, Y = np.meshgrid(x, y)

# Calculate the 2D Gaussian function
Z = (1 / (2 * np.pi * sigma**2)) * np.exp(-(X**2 + Y**2) / (2 * sigma**2))

# Create a figure with subplots
fig = plt.figure(figsize=(15, 5))

# 1. 3D Surface plot
ax1 = fig.add_subplot(131, projection="3d")
surf = ax1.plot_surface(X, Y, Z, cmap="viridis", alpha=0.8)
ax1.set_xlabel("X")
ax1.set_ylabel("Y")
ax1.set_zlabel("G(X,Y)")
ax1.set_title(f"3D Gaussian Surface (σ={sigma})")
fig.colorbar(surf, ax=ax1, shrink=0.5, aspect=5)

# 2. 2D Contour plot
ax2 = fig.add_subplot(132)
contour = ax2.contour(X, Y, Z, levels=20, cmap="viridis")
ax2.set_xlabel("X")
ax2.set_ylabel("Y")
ax2.set_title(f"2D Contour Plot (σ={sigma})")
ax2.set_aspect("equal")
plt.colorbar(contour, ax=ax2)

# 3. 2D Heatmap (imshow)
ax3 = fig.add_subplot(133)
im = ax3.imshow(Z, extent=[-3, 3, -3, 3], origin="lower", cmap="viridis")
ax3.set_xlabel("X")
ax3.set_ylabel("Y")
ax3.set_title(f"2D Heatmap (σ={sigma})")
plt.colorbar(im, ax=ax3)

plt.tight_layout()
plt.show()

# Print some key values
print(f"Maximum value (at center): {Z[50, 50]:.4f}")
print(
    f"Value at one standard deviation (r=1): {(1 / (2 * np.pi * sigma**2)) * np.exp(-1 / (2 * sigma**2)):.4f}"
)
